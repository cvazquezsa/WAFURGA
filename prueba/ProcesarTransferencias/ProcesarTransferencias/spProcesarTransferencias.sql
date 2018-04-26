
/********** spProcesarTransferencias **********/
IF EXISTS (SELECT * FROM SysObjects WHERE Name='spProcesarTransferencias' AND Type='P')
	DROP PROCEDURE spProcesarTransferencias
GO
CREATE PROCEDURE spProcesarTransferencias
	@Empresa varchar(5),
	@Usuario varchar(20)
AS
BEGIN
	DECLARE
		@ID int,
		@Sucursal	int,
		@FormaPago varchar(50),
		@TipoCambio float,
		@ImporteAcumulado money,
		@ImporteTransferencia money,
		@FechaTransferencia datetime,
		@Concepto varchar(20),
		@ImporteDiferencia money,
		@MovCargo varchar(20) = 'Cargo Bancario',
		@MovAbono varchar(20) = 'Abono Bancario',
		@MovAjuste varchar(20),
		@MovTransferencia varchar(20),
		@MonedaFormaPago varchar(10),
		@Observaciones varchar(100),
		@Estatus varchar(20),
		@CtaDinero varchar(20),
		@CtaDineroDestino varchar(20),
		@IDDin int,
		@Ok	int,
		@OkRef varchar(255),
		@nCargos	int = 0,
		@nAbonos	int = 0,
		@nTransferencias	int = 0,
		@Mensaje varchar(max)
	
	SELECT @Observaciones = 'Herramienta Transferencias'
	SELECT @Estatus = 'SINAFECTAR'
	SELECT @MovTransferencia = BancoTransferencia FROM EmpresaCfgMov WHERE Empresa = @Empresa
	
	BEGIN TRANSACTION
		
		DECLARE crProcesar CURSOR FAST_FORWARD FOR
			SELECT ID,Sucursal, FormaPago, ImporteAcumulado, ImporteTransferencia, FechaTrasnferencia, Concepto, TipoCambio 
				FROM ProcesarTransferencias
				WHERE Estatus = 'PENDIENTE'
					AND Concluir = 1
		
		OPEN crProcesar
		FETCH NEXT FROM crProcesar INTO
			@ID, @Sucursal, @FormaPago, @ImporteAcumulado, @ImporteTransferencia, @FechaTransferencia, @Concepto, @TipoCambio

		WHILE @@FETCH_STATUS = 0 AND ISNULL(@OK,0) = 0
		BEGIN
		
			SELECT @ImporteDiferencia = @ImporteTransferencia - @ImporteAcumulado
			SELECT @MonedaFormaPago = Moneda FROM FormaPago WHERE FormaPago = @FormaPago
			SELECT @CtaDinero = CuentaDinero, @CtaDineroDestino = CuentaDineroDestino 
				FROM ProcesarTransferenciasFP 
				WHERE Sucursal = @Sucursal AND Moneda = @MonedaFormaPago AND FormaPago = @FormaPago
			
			SELECT @IDDin = NULL
		
			--Insertar Cargo o Abono Bancario
			IF NOT @ImporteDiferencia = 0
			BEGIN--@ImporteDiferencia > 0
				IF @ImporteDiferencia > 0
					SELECT @MovAjuste = @MovCargo
				IF @ImporteDiferencia < 0
					SELECT @MovAjuste = @MovAbono, @ImporteDiferencia = ABS(@ImporteDiferencia)
			
				--Inserta Abono
				IF @Concepto = 'Operación'
				BEGIN
					INSERT INTO Dinero(
						Empresa,	Mov,				FechaEmision,					UltimoCambio,					Moneda,						TipoCambio,		Observaciones, 
						Usuario,	Estatus,	Directo,	CtaDinero, ConDesglose, Importe,						FechaProgramada,		Sucursal, 
						SucursalOrigen, FormaPago)
					SELECT
						@Empresa, @MovAjuste,	@FechaTransferencia,	@FechaTransferencia,	@MonedaFormaPago, @TipoCambio,	@Observaciones,
						@Usuario,	@Estatus,	1,				@CtaDinero,	0,					@ImporteDiferencia,	@FechaTransferencia,@Sucursal,
						@Sucursal,			@FormaPago
					
					SELECT @IDDin = SCOPE_IDENTITY()
				END
			END--@ImporteDiferencia > 0
			IF @Concepto IN ('Sobrante','Faltante')
			BEGIN
				IF @Concepto = 'Sobrante' SELECT @MovAjuste = @MovCargo
				IF @Concepto = 'Faltante' SELECT @MovAjuste = @MovAbono

				INSERT INTO Dinero(
					Empresa,	Mov,				FechaEmision,					UltimoCambio,					Moneda,						TipoCambio,		Observaciones, 
					Usuario,	Estatus,	Directo,	CtaDinero,					ConDesglose, Importe,								FechaProgramada,		Sucursal, 
					SucursalOrigen, FormaPago)
				SELECT
					@Empresa, @MovAjuste,	@FechaTransferencia,	@FechaTransferencia,	@MonedaFormaPago, @TipoCambio,	@Observaciones,
					@Usuario,	@Estatus,	1,				@CtaDineroDestino,	0,						@ImporteTransferencia,	@FechaTransferencia,@Sucursal,
					@Sucursal,			@FormaPago

				SELECT @IDDin = SCOPE_IDENTITY()
			END  

				--SELECT @IDDin = SCOPE_IDENTITY()
				
				IF ISNULL(@IDDin,0) <> 0
				BEGIN
					EXEC spAfectar 'DIN', @IDDin, 'AFECTAR', 'Todo', NULL, 'INTELISIS', 0, 1, @Ok OUTPUT, @OkRef OUTPUT
				--SELECT @Ok
					IF ISNULL(@OK,0) = 0 AND @MovAjuste = @MovCargo
						SELECT @nCargos +=1
					IF ISNULL(@OK,0) = 0 AND @MovAjuste = @MovAbono
						SELECT @nAbonos +=1
				END
				
			--Insertar Transferencia
			IF ISNULL(@OK,0)=0
			BEGIN
				SELECT @IDDin = NULL
				
				IF @Concepto = 'Operación'
				BEGIN
					INSERT INTO Dinero(
							Empresa,	Mov,								FechaEmision,					UltimoCambio,					Moneda,						TipoCambio,		Observaciones, 
							Usuario,	Estatus,	Directo,	CtaDinero,	CtaDineroDestino,		ConDesglose, Importe,						FechaProgramada,		Sucursal, 
							SucursalOrigen, FormaPago)
						SELECT
							@Empresa, @MovTransferencia,	@FechaTransferencia,	@FechaTransferencia,	@MonedaFormaPago, @TipoCambio,	@Observaciones,
							@Usuario,	@Estatus,	1,				@CtaDinero,	@CtaDineroDestino,	0,					@ImporteTransferencia,	@FechaTransferencia,@Sucursal,
							@Sucursal,			@FormaPago
					SELECT @IDDin = SCOPE_IDENTITY()
				
					IF ISNULL(@IDDin,0) <> 0
					BEGIN
						--SELECT * FROM Dinero WHERE ID=@IDDin
						EXEC spAfectar 'DIN', @IDDin, 'AFECTAR', 'Todo', NULL, 'INTELISIS', 0, 1, @Ok OUTPUT, @OkRef OUTPUT
						IF ISNULL(@OK,0) = 0
							SELECT @nTransferencias += 1
					END
				END	
			END
			--SELECT * FROM Dinero WHERE ID = @IDDin
		
			IF ISNULL(@OK,0)=0
				UPDATE pt SET Estatus = 'CONCLUIDO' FROM ProcesarTransferencias pt WHERE ID=@ID
		
			FETCH NEXT FROM crProcesar INTO
			@ID, @Sucursal, @FormaPago, @ImporteAcumulado, @ImporteTransferencia, @FechaTransferencia, @Concepto, @TipoCambio
		END
		CLOSE crProcesar
		DEALLOCATE crProcesar

	IF ISNULL(@OK,0)=0
	BEGIN
		COMMIT
		IF ISNULL(@nTransferencias,0) > 0
			SELECT @Mensaje = CONCAT(@Mensaje,'Se Generaron ',@nTransferencias,' Transferencia')
		IF ISNULL(@nCargos,0) > 0
			SELECT @Mensaje = CONCAT(@Mensaje,'<BR>Se Generaron ',@nCargos,' Cargos Bancario')
		IF ISNULL(@nAbonos,0) > 0
			SELECT @Mensaje = CONCAT(@Mensaje,'<BR>Se Generaron ',@nAbonos,' Abono Bancario')
		SELECT @Mensaje

		RETURN
	END
	ELSE IF @@TRANCOUNT > 0
		ROLLBACK
END
GO
--BEGIN TRANSACTION
--	EXEC spProcesarTransferencias 'E001', 'INTELISIS'
--IF @@TRANCOUNT > 0 
--	ROLLBACK

/********** spProcesarTransA **********/
IF EXISTS (SELECT * FROM SysObjects WHERE Name='spProcesarTransA' AND Type='P')
	DROP PROCEDURE spProcesarTransA
GO
CREATE PROCEDURE spProcesarTransA
	@ID int,
	@Concepto varchar(20)
AS
BEGIN
	DECLARE
		@Sucursal int,
		@FormaPago varchar(50),
		@TipoCambio float,
		@Fecha datetime

	INSERT INTO ProcesarTransferencias(
			Sucursal, FormaPago, TipoCambio, Fecha, FechaTrasnferencia, Concepto,		Estatus,			Concluir)
		SELECT 
			Sucursal, FormaPago, TipoCambio, Fecha, FechaTrasnferencia, @Concepto,	'PENDIENTE',	0  
		FROM ProcesarTransferencias
		WHERE ID = @ID
	--RETURN
END
GO

/********** spProcesarTransferenciaEliminar **********/
IF EXISTS (SELECT * FROM SysObjects WHERE Name='spProcesarTransferenciaEliminar' AND Type='P')
	DROP PROCEDURE spProcesarTransferenciaEliminar
GO
CREATE PROCEDURE spProcesarTransferenciaEliminar
	@ID int
AS
BEGIN
	DELETE ProcesarTransferencias WHERE ID=@ID AND Concepto <> 'Operación'
END
GO
--BEGIN TRANSACTION
--EXEC spProcesarTransferenciasAjuste 14, 'Sobrante'
----SELECT * fROM ProcesarTransferencias
--ROLLBACK
--DELETE  FROM ProcesarTransferencias wHERE Concepto='Sobrante'