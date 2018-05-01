/****** Object:  StoredProcedure [dbo].[xp_RevaluacionCont]    Script Date: 11/06/2015 10:57:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xp_RevaluacionCont]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[xp_RevaluacionCont]
GO

CREATE PROCEDURE [dbo].[xp_RevaluacionCont]
	@Empresa VARCHAR(5), @Sucursal INT, @Usuario VARCHAR(15)
AS BEGIN
	DECLARE @CtaUtilidad   VARCHAR(20),
			@CtaPerdida    VARCHAR(20),
			@GenerarPoliza BIT,
			@TipoCambio    FLOAT,
			@Ejercicio     INT,
			@Periodo       INT,
			@UP            FLOAT

	SELECT  @CtaUtilidad   = CtaUtilidad,
			@CtaPerdida    = CtaPerdida ,
			@GenerarPoliza = GenerarPoliza,
			@TipoCambio    = TipoCambio,
			@Ejercicio     = Ejercicio,
			@Periodo       = Periodo
	FROM RevaluacionDolaresCtasUP
	WHERE Empresa = @Empresa
	  AND Sucursal = @Sucursal

	DELETE RevaluacionDolaresCalc
	WHERE Empresa = @Empresa
	  AND Sucursal = @Sucursal

	INSERT RevaluacionDolaresCalc -- Inserta las cuentas complementarias
	SELECT @Empresa, @Sucursal, CtaComp, 0,0, 0,0, 0,0, 0
	FROM RevaluacionDolares
	WHERE Empresa = @Empresa
	  AND Sucursal = @Sucursal
	GROUP BY CtaComp

	UPDATE RevaluacionDolaresCalc -- Identifica si es Acreedora o Deudora
	SET RevaluacionDolaresCalc.EsAcreedora = Cta.EsAcreedora
	FROM Cta
	WHERE RevaluacionDolaresCalc.CtaComp = Cta.Cuenta
	  AND Empresa = @Empresa
	  AND Sucursal = @Sucursal

	UPDATE RevaluacionDolaresCalc -- Actualiza en saldo de las complementarias
	SET SaldoCtaComp = dbo.fn_SaldoCont(@Empresa,@Sucursal,@Ejercicio,@Periodo,CtaComp)
	WHERE Empresa = @Empresa
	  AND Sucursal = @Sucursal

	UPDATE RevaluacionDolaresCalc -- Actualiza en saldo valor absoluto
	SET SaldoCtaComp = ABS(SaldoCtaComp)
	WHERE Empresa = @Empresa
	  AND Sucursal = @Sucursal

	SELECT RevaluacionDolares.CtaComp, SUM(ISNULL(Acum.Cargos,0)-ISNULL(Acum.Abonos,0)) Saldo
	INTO #tSaldoDolar -- Tabla temporal para obtener la suma de los saldos en dólar (en caso de una complementaria para varias ctas)
	FROM Acum JOIN RevaluacionDolares ON Acum.Cuenta = RevaluacionDolares.CtaDolar
	WHERE Acum.Rama      = 'CONT'
	  AND Acum.Empresa   = @Empresa
	  AND Acum.Sucursal       = @Sucursal 
	  AND Acum.Ejercicio = @Ejercicio
	  AND Acum.Periodo   <= @Periodo
	  AND Acum.Moneda    = 'Pesos'
	  AND RevaluacionDolares.Empresa = @Empresa
	GROUP BY RevaluacionDolares.CtaComp

	UPDATE RevaluacionDolaresCalc -- Actualiza el saldo en dólar para la complementaria
	SET RevaluacionDolaresCalc.SaldoCtaDolar = ABS(#tSaldoDolar.Saldo)
	FROM #tSaldoDolar
	WHERE #tSaldoDolar.CtaComp = RevaluacionDolaresCalc.CtaComp
	  AND Empresa = @Empresa
	  AND Sucursal = @Sucursal

	DROP TABLE #tSaldoDolar

	UPDATE RevaluacionDolaresCalc -- Calcula el valor de la complementaria y su diferencia con la actual
	SET AjusteComp  = (SaldoCtaDolar*(@TipoCambio-1))-SaldoCtaComp,
		CalcCtaComp = SaldoCtaDolar*(@TipoCambio-1)
	WHERE Empresa = @Empresa
	  AND Sucursal = @Sucursal
/*
	UPDATE RevaluacionDolaresCalc
	SET Cargo = ABS(CASE WHEN AjusteComp < 0 AND EsAcreedora = 1 THEN AjusteComp 
						 WHEN AjusteComp > 0 AND EsAcreedora = 0 THEN AjusteComp 
						 ELSE 0 END),
		Abono = ABS(CASE WHEN AjusteComp < 0 AND EsAcreedora = 0 THEN AjusteComp 
						 WHEN AjusteComp > 0 AND EsAcreedora = 1 THEN AjusteComp 
						 ELSE 0 END)
	WHERE Empresa = @Empresa
	  AND Sucursal = @Sucursal
*/

	UPDATE RevaluacionDolaresCalc -- Identifica si es Cargo o Abono para el ajuste
	SET Cargo = ABS(CASE WHEN (SaldoCtaDolar*(@TipoCambio-1)) < SaldoCtaComp AND EsAcreedora = 1 THEN AjusteComp 
						 WHEN (SaldoCtaDolar*(@TipoCambio-1)) > SaldoCtaComp AND EsAcreedora = 0 THEN AjusteComp 
						 ELSE 0 END),
		Abono = ABS(CASE WHEN (SaldoCtaDolar*(@TipoCambio-1)) < SaldoCtaComp AND EsAcreedora = 0 THEN AjusteComp 
						 WHEN (SaldoCtaDolar*(@TipoCambio-1)) > SaldoCtaComp AND EsAcreedora = 1 THEN AjusteComp 
						 ELSE 0 END)
	WHERE Empresa = @Empresa
	  AND Sucursal = @Sucursal

	SELECT @UP = SUM(Cargo-Abono)
	FROM RevaluacionDolaresCalc
	WHERE Empresa = @Empresa
	  AND Sucursal = @Sucursal

	UPDATE RevaluacionDolaresCtasUP
	SET Utilidad = CASE WHEN @UP > 0 THEN @UP ELSE 0 END,
		Perdida  = CASE WHEN @UP < 0 THEN ABS(@UP) ELSE 0 END
	WHERE Empresa = @Empresa
	  AND Sucursal = @Sucursal

	IF @GenerarPoliza = 1 BEGIN
		DECLARE @Fecha   DATETIME,
				@Ref     VARCHAR(50),
				@IDCont  BIGINT,
				@Renglon FLOAT,
				@CtaComp VARCHAR(20),
				@Cargo   FLOAT,
				@Abono   FLOAT,
				@SCargo  FLOAT,
				@SAbono  FLOAT

		SELECT 	@Fecha    = dbo.fnFechaSinHora(GETDATE()),
				@Ref     = 'Revaluación ' + dbo.fnMesNumeroNombre(@Periodo) +' '+ LTRIM(STR(@Ejercicio)) + ' TC ' + CAST(@TipoCambio AS VARCHAR(20)),
				@Renglon = 0
	 
		INSERT Cont (
			Empresa,
			Mov,
			MovID,
			FechaEmision,
			FechaContable,
			Concepto,
			Moneda,
			TipoCambio,
			Usuario,
			Referencia,
			Observaciones,
			Estatus,
			Ejercicio,
			Periodo,
			FechaRegistro,
			Sucursal,
			Importe,
			SucursalOrigen,
			SucursalDestino
		) VALUES (@Empresa, 'Diario', NULL, @Fecha, @Fecha, @Ref, 'Pesos', 1, @Usuario, @Ref, NULL, 'SINAFECTAR', @Ejercicio, @Periodo, GETDATE(), @Sucursal, 0, @Sucursal, @Sucursal)
					
		SELECT @IDCont = SCOPE_IDENTITY(), @SCargo = 0, @SAbono = 0
		
		DECLARE qPoliza CURSOR FOR
		SELECT CtaComp, Cargo, Abono
		FROM RevaluacionDolaresCalc
		WHERE Empresa = @Empresa
		  AND Sucursal = @Sucursal
		
		OPEN qPoliza
		
		FETCH NEXT FROM qPoliza INTO @CtaComp, @Cargo, @Abono 
		WHILE @@FETCH_STATUS = 0 BEGIN
			SELECT @Renglon = @Renglon + 2048,  @SCargo =  @SCargo + @Cargo, @SAbono = @SAbono + @Abono
			
			IF @Cargo <> 0 OR @Abono <> 0 BEGIN
				INSERT ContD (ID,Renglon,RenglonSub,Cuenta,SubCuenta,Concepto,Debe,Haber,Empresa,Ejercicio,Periodo,FechaContable,Sucursal,SucursalContable,	SucursalOrigen) 
				VALUES ( @IDCont, @Renglon, 0, @CtaComp, NULL, @Ref, @Cargo, @Abono, @Empresa, @Ejercicio, @Periodo, @Fecha, @Sucursal, @Sucursal, @Sucursal)
			END
			FETCH NEXT FROM qPoliza INTO @CtaComp, @Cargo, @Abono
		END
		
		CLOSE qPoliza
		DEALLOCATE qPoliza
		
		INSERT ContD (ID,Renglon,RenglonSub,Cuenta,SubCuenta,Concepto,Debe,Haber,Empresa,Ejercicio,Periodo,FechaContable,Sucursal,SucursalContable,	SucursalOrigen) 
		VALUES (@IDCont, @Renglon+ 2048, 0, CASE WHEN @UP < 0 THEN @CtaPerdida ELSE @CtaUtilidad END, NULL, @Ref, CASE WHEN @UP < 0 THEN ABS(@UP) ELSE 0 END, CASE WHEN @UP > 0 THEN ABS(@UP) ELSE 0 END, @Empresa, @Ejercicio, @Periodo, @Fecha, @Sucursal, @Sucursal, @Sucursal)

		UPDATE ContD
		SET Debe = CASE WHEN Debe = 0 THEN NULL ELSE Debe END, Haber = CASE WHEN Haber = 0 THEN NULL ELSE Haber END
		WHERE [ID] = @IDCont

		UPDATE Cont
		SET Importe = (SELECT SUM(ISNULL(Debe,0)) FROM ContD WHERE [ID] = @IDCont)
		WHERE [ID] = @IDCont

		SELECT @IDCont --'Se generó una póliza en estatus Sin Afectar con los cargos y abonos calculados'
	END
	ELSE BEGIN
		SELECT NULL
	END

END


GO


