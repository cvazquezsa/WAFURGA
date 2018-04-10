SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO

/*********** spACDevengarIntereses **********/
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'spACDevengarIntereses' ANd Type='P') DROP PROCEDURE spACDevengarIntereses
GO
CREATE PROCEDURE spACDevengarIntereses
	           @Empresa		char(5),
		   @Sucursal		int,
        	   @Usuario		char(10),
    		   @Modulo		char(5),
		   @Hoy			datetime,
    		   @FechaRegistro	datetime,
		   @Vencidos		bit,
		   @Conteo		int		OUTPUT,
		   @Ok			int		OUTPUT,
		   @OkRef		varchar(255)	OUTPUT
--//WITH ENCRYPTION
AS BEGIN
  -- SET nocount ON
  DECLARE
    @InteresesID		int,
    @InteresesMov		varchar(20),
    @InteresesMovID		varchar(20),
    @Moneda			char(10),
    @TipoCambio			float,
    @RamaID			int,
    @ID				int,
    @Mov			varchar(20),
    @MovID			varchar(20),
    @Contacto			char(10),
    @Ordinarios			money,
    @Saldo			money,
    @Moratorios			money,
    @MoratoriosFactor		float,
    @InteresesFijos		money,
    @InteresesAcumulados	money,
    @Metodo			int,
    @TasaDiaria			float,
    @SumaIntereses		money,
    @Renglon			float,
    @FactorMes			float,
    @Retencion			money,
    @RamaEmision		datetime,
    @DiasIntereses		float,
    @Inflacion			float, --MEJORA10041
    @AcCobroIntereses					varchar(20), --MEJORA10041
    @AcConsiderarInflacionIVA			bit, --MEJORA10041
    @AcMonedaCalculoInflacionIVA		varchar(10), --MEJORA10041
    @CobroIntereses						varchar(20), --MEJORA10041
    @TipoTasa							varchar(20), --MEJORA10041
    @TieneTasaEsp						bit, --MEJORA10041
    @TasaEsp							float, --MEJORA10041							
    @IVAInteresPorcentaje				float, --MEJORA10041
    @InteresIVAImporte					float --MEJORA10041

  EXEC xpACDevengarInteresesFactorMes @Hoy, @FactorMes OUTPUT
  SELECT @Moneda = m.Moneda, @TipoCambio = m.TipoCambio
    FROM EmpresaCfg cfg, Mon m
   WHERE cfg.Empresa = @Empresa AND m.Moneda = cfg.ContMoneda

  SELECT --MEJORA10041
    @AcCobroIntereses = UPPER(RTRIM(ISNULL(ACCobroIntereses,''))),
    @ACConsiderarInflacionIVA = ISNULL(ACConsiderarInflacionIVA,0),
    @ACMonedaCalculoInflacionIVA = NULLIF(LTRIM(RTRIM(ACMonedaCalculoInflacionIVA)),'')
    FROM EmpresaCfg
   WHERE Empresa = @Empresa 

  IF @ACConsiderarInflacionIVA = 1 --MEJORA10041
  BEGIN
    SELECT @Inflacion = dbo.fnInflacionActualDiaria(@Empresa, @Sucursal)
      
    IF @Inflacion = -1.0
    BEGIN
      SELECT @Ok = 30075, @OkRef = dbo.fnIdiomaTraducir(@Usuario,'Verifique la moneda utilizada para el cálculo de inflación.')
      RETURN    
    END
  END ELSE
  BEGIN
    SELECT @Inflacion = 0.0
  END  

  SELECT @Contacto = CASE WHEN @Modulo = 'CXC' THEN ACClienteDevengados ELSE ACProveedorDevengados END
    FROM EmpresaCfg
   WHERE Empresa = @Empresa

  IF @Modulo = 'CXC' AND @Vencidos = 1
    SELECT @InteresesMov = CxcInteresesVencidos FROM EmpresaCfgMov WHERE Empresa = @Empresa
  ELSE
  IF @Modulo = 'CXC' AND @Vencidos = 0
    SELECT @InteresesMov = CxcIntereses FROM EmpresaCfgMov WHERE Empresa = @Empresa
  ELSE
  IF @Modulo = 'CXP' AND @Vencidos = 0 --MEJORA10015
    SELECT @InteresesMov = CxpIntereses FROM EmpresaCfgMov WHERE Empresa = @Empresa
  ELSE --MEJORA10015 
  IF @Modulo = 'CXP' AND @Vencidos = 1
    SELECT @InteresesMov = CxpInteresMoratorio FROM EmpresaCfgMovCxp WHERE Empresa = @Empresa --MEJORA10015

  -- Cancelar Anterior
  SELECT @InteresesID = NULL
  IF @Modulo = 'CXC'
    SELECT @InteresesID = ID FROM Cxc WHERE Empresa = @Empresa AND Mov = @InteresesMov AND FechaEmision = @Hoy AND Moneda = @Moneda AND Estatus IN ('CONCLUIDO', 'PENDIENTE') AND ISNULL(EsInteresFijo,0) = 0
  ELSE
    SELECT @InteresesID = ID FROM Cxp WHERE Empresa = @Empresa AND Mov = @InteresesMov AND FechaEmision = @Hoy AND Moneda = @Moneda AND Estatus IN ('CONCLUIDO', 'PENDIENTE') AND ISNULL(EsInteresFijo,0) = 0
  IF @InteresesID IS NOT NULL
    EXEC spCx @InteresesID, @Modulo, 'CANCELAR', 'TODO', @FechaRegistro, NULL, @Usuario, 0, 0, @InteresesMov OUTPUT, @InteresesMovID OUTPUT, NULL, @Ok OUTPUT, @OkRef OUTPUT
  
  IF @Modulo = 'CXC'
    INSERT Cxc (Sucursal,  Empresa,  Mov,           FechaEmision,  Moneda,  TipoCambio,  Usuario, Estatus,      Cliente,   ClienteMoneda, ClienteTipoCambio)
        VALUES (@Sucursal, @Empresa, @InteresesMov, @Hoy,          @Moneda, @TipoCambio, @Usuario, 'SINAFECTAR', @Contacto, @Moneda,       @TipoCambio)
  ELSE
    INSERT Cxp (Sucursal,  Empresa,  Mov,           FechaEmision,  Moneda,  TipoCambio,  Usuario,  Estatus,      Proveedor, ProveedorMoneda, ProveedorTipoCambio)
        VALUES (@Sucursal, @Empresa, @InteresesMov, @Hoy,          @Moneda, @TipoCambio, @Usuario, 'SINAFECTAR', @Contacto, @Moneda,         @TipoCambio)

  SELECT @InteresesID = SCOPE_IDENTITY()

  SELECT @Renglon = 0.0, @SumaIntereses = 0.0
  IF @InteresesID IS NOT NULL AND @Ok IS NULL
  BEGIN
    IF @Vencidos = 0 --MEJORA10015
    BEGIN
      -- Intereses Ordinarios
      IF @Modulo = 'CXC'
        DECLARE crInteresesOrdinarios CURSOR FOR
         SELECT c.RamaID, r.FechaEmision, lc.CobroIntereses, c.TipoTasa, c.TieneTasaEsp, c.TasaEsp, c.IVAInteresPorcentaje, SUM(c.Saldo*(c.TasaDiaria/100.0)*c.TipoCambio), SUM(c.Saldo*c.TipoCambio) --MEJORA10041
           FROM Cxc c
           JOIN Cxc r ON r.ID = c.RamaID AND r.CarteraVencidaCNBV = @Vencidos
           JOIN TipoAmortizacion ta ON ta.TipoAmortizacion = c.TipoAmortizacion AND ta.Metodo <> 50
           JOIN LC ON lc.LineaCredito = r.LineaCredito AND lc.MinistracionHipotecaria = 0 --AND UPPER(lc.CobroIntereses) = 'DEVENGADOS'
          WHERE c.Empresa = @Empresa AND c.Estatus = 'PENDIENTE' AND c.Vencimiento > @Hoy AND r.FechaEmision <= @Hoy
          GROUP BY c.RamaID, r.FechaEmision, lc.CobroIntereses, c.TipoTasa, c.TieneTasaEsp, c.TasaEsp, c.IVAInteresPorcentaje --MEJORA10041
          ORDER BY c.RamaID, r.FechaEmision, lc.CobroIntereses, c.TipoTasa, c.TieneTasaEsp, c.TasaEsp, c.IVAInteresPorcentaje --MEJORA10041
      ELSE
        DECLARE crInteresesOrdinarios CURSOR FOR
         SELECT c.RamaID, r.FechaEmision, lc.CobroIntereses, c.TipoTasa, c.TieneTasaEsp, c.TasaEsp, c.IVAInteresPorcentaje, SUM(c.Saldo*(c.TasaDiaria/100.0)*c.TipoCambio), SUM(c.Saldo*c.TipoCambio) --MEJORA10041
           FROM Cxp c
           JOIN Cxp r ON r.ID = c.RamaID 
           JOIN LC ON lc.LineaCredito = r.LineaCredito --MEJORA10041
          WHERE c.Empresa = @Empresa AND c.Estatus = 'PENDIENTE' AND c.Vencimiento > @Hoy AND r.FechaEmision <= @Hoy
          GROUP BY c.RamaID, r.FechaEmision, lc.CobroIntereses, c.TipoTasa, c.TieneTasaEsp, c.TasaEsp, c.IVAInteresPorcentaje --MEJORA10041
          ORDER BY c.RamaID, r.FechaEmision, lc.CobroIntereses, c.TipoTasa, c.TieneTasaEsp, c.TasaEsp, c.IVAInteresPorcentaje --MEJORA10041

      OPEN crInteresesOrdinarios
      FETCH NEXT FROM crInteresesOrdinarios INTO @RamaID, @RamaEmision, @CobroIntereses, @TipoTasa, @TieneTasaEsp, @TasaEsp, @IVAInteresPorcentaje, @Ordinarios, @Saldo --MEJORA10041
      WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
      BEGIN                         
        IF @@FETCH_STATUS <> -2 AND @Ok IS NULL 
        BEGIN
         IF @Modulo = 'CXC'
           SELECT @Retencion = @Saldo*(t.RetencionPuntos/360.0/100.0)
             FROM Cxc c
             JOIN TipoTasa t ON t.TipoTasa = c.TipoTasa
            WHERE c.ID = @RamaID
         ELSE
           SELECT @Retencion = @Saldo*(t.RetencionPuntos/360.0/100.0)
             FROM Cxp c
             JOIN TipoTasa t ON t.TipoTasa = c.TipoTasa
            WHERE c.ID = @RamaID

         IF @RamaID IS NOT NULL AND ISNULL(@Ordinarios, 0.0) <> 0.0 
          BEGIN
            SELECT @ID = NULL, @InteresesAcumulados = NULL
            IF @Modulo = 'CXC'
            BEGIN
              SELECT @InteresesAcumulados = SUM(InteresesOrdinarios) FROM Cxc WHERE RamaID  = @RamaID
              SELECT @ID = MAX(ID) FROM Cxc WHERE RamaID = @RamaID AND Estatus = 'PENDIENTE' AND @Hoy BETWEEN FechaEmision AND Vencimiento-1
              IF @ID IS NULL
                SELECT @ID = MIN(ID) FROM Cxc WHERE RamaID = @RamaID AND Estatus = 'PENDIENTE' 
            END ELSE
  BEGIN
              SELECT @InteresesAcumulados = SUM(InteresesOrdinarios) FROM Cxp WHERE RamaID  = @RamaID
              SELECT @ID = MAX(ID) FROM Cxp WHERE RamaID = @RamaID AND Estatus = 'PENDIENTE' AND @Hoy BETWEEN FechaEmision AND Vencimiento-1
              IF @ID IS NULL
                SELECT @ID = MIN(ID) FROM Cxp WHERE RamaID = @RamaID AND Estatus = 'PENDIENTE' 
            END

           IF NULLIF(@InteresesAcumulados, 0.0) IS NULL
             SELECT @DiasIntereses = DATEDIFF(day, @RamaEmision, @Hoy) + 1.0
           ELSE
             SELECT @DiasIntereses = 1.0

           SELECT @Ordinarios = @Ordinarios * @FactorMes * @DiasIntereses

           IF UPPER(@CobroIntereses) = 'DEVENGADOS' --MEJORA10041
           BEGIN
             SET @InteresIVAImporte = dbo.fnInteresIVAImporte(@TipoTasa, @TieneTasaEsp, @TasaEsp, @Inflacion, @Ordinarios, @IVAInteresPorcentaje, 0.0, 0)            
           END ELSE
             SELECT @InteresIVAImporte = NULL, @Ordinarios = NULL
             
            SELECT @Renglon = @Renglon + 2048.0, @SumaIntereses = @SumaIntereses + ISNULL(@Ordinarios, 0.0)
            IF @Modulo = 'CXC' AND @Ordinarios IS NOT NULL --MEJORA10041
              INSERT CxcD (ID,          Sucursal,  Renglon,  Aplica, AplicaID, InteresesOrdinarios,      Retencion,               InteresesOrdinariosIVA) --MEJORA10041
                   SELECT @InteresesID, @Sucursal, @Renglon, Mov,    MovID,    NULLIF(@Ordinarios, 0.0), NULLIF(@Retencion, 0.0), @InteresIVAImporte --MEJORA10041
                     FROM Cxc
                    WHERE ID = @ID
            ELSE IF @Modulo = 'CXP' AND @Ordinarios IS NOT NULL --MEJORA10041
              INSERT CxpD (ID,          Sucursal,  Renglon,  Aplica, AplicaID, InteresesOrdinarios,      Retencion,               InteresesOrdinariosIVA) --MEJORA10041
                   SELECT @InteresesID, @Sucursal, @Renglon, Mov,    MovID,    NULLIF(@Ordinarios, 0.0), NULLIF(@Retencion, 0.0), @InteresIVAImporte --MEJORA10041
                     FROM Cxp
                    WHERE ID = @ID
          END
          EXEC xpACDevengarInteresesOrdinarios @Modulo, @ID, @Ordinarios OUTPUT, @Ok OUTPUT, @OkRef OUTPUT

        END
        FETCH NEXT FROM crInteresesOrdinarios INTO @RamaID, @RamaEmision, @CobroIntereses, @TipoTasa, @TieneTasaEsp, @TasaEsp, @IVAInteresPorcentaje, @Ordinarios, @Saldo --MEJORA10041
      END  -- While
      CLOSE crInteresesOrdinarios
      DEALLOCATE crInteresesOrdinarios
    END
    
    -- Intereses Arrendamiento
    IF @Modulo = 'CXC' AND @Vencidos = 0
    BEGIN
      DECLARE crInteresesArrendamiento CURSOR FOR
       SELECT c.ID, c.InteresesFijos/NULLIF(DATEDIFF(day, c.FechaEmision, c.Vencimiento), 0)
         FROM Cxc c
         JOIN TipoAmortizacion ta ON ta.TipoAmortizacion = c.TipoAmortizacion AND ta.Metodo = 50
         JOIN LC ON lc.LineaCredito = c.LineaCredito AND lc.MinistracionHipotecaria = 0 AND UPPER(lc.CobroIntereses) = 'DEVENGADOS'
        WHERE c.Empresa = @Empresa AND c.Estatus = 'PENDIENTE' AND @Hoy BETWEEN c.FechaEmision AND c.Vencimiento
 
      OPEN crInteresesArrendamiento
      FETCH NEXT FROM crInteresesArrendamiento INTO @ID, @Ordinarios
      WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
      BEGIN                         
        IF @@FETCH_STATUS <> -2 AND @Ok IS NULL 
        BEGIN
          SELECT @Ordinarios = @Ordinarios * @FactorMes
          EXEC xpACDevengarInteresesArrendamiento @Modulo, @ID, @Ordinarios OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
          IF ISNULL(@Ordinarios, 0.0) <> 0.0 
          BEGIN
            SELECT @Renglon = @Renglon + 2048.0, @SumaIntereses = @SumaIntereses + ISNULL(@Ordinarios, 0.0)
            INSERT CxcD (ID,          Sucursal,  Renglon,  Aplica, AplicaID, InteresesOrdinarios)  
                 SELECT @InteresesID, @Sucursal, @Renglon, Mov,    MovID,    NULLIF(@Ordinarios, 0.0)
                   FROM Cxc
                  WHERE ID = @ID
 END
        END
        FETCH NEXT FROM crInteresesArrendamiento INTO @ID, @Ordinarios
      END  -- While
      CLOSE crInteresesArrendamiento
      DEALLOCATE crInteresesArrendamiento
    END

    --IF @Vencidos = 0 --MEJORA10015
    IF @Vencidos = 1 --MEJORA10015
    BEGIN
      -- Intereses Moratorios
      IF @Modulo = 'CXC'
        DECLARE crInteresesMoratorios CURSOR FOR
         SELECT c.ID, lc.CobroIntereses, c.TipoTasa, c.TieneTasaEsp, c.TasaEsp, c.IVAInteresPorcentaje, c.Saldo*c.TipoCambio, c.InteresesFijos*c.TipoCambio, c.TasaDiaria, tt.MoratoriosFactor, ta.Metodo --MEJORA10041
           FROM Cxc c
           JOIN TipoTasa tt ON tt.TipoTasa = c.TipoTasa
           JOIN TipoAmortizacion ta ON ta.TipoAmortizacion = c.TipoAmortizacion
           JOIN LC ON lc.LineaCredito = c.LineaCredito AND lc.MinistracionHipotecaria = 0
          WHERE c.Empresa = @Empresa AND c.Estatus = 'PENDIENTE' AND c.Vencimiento <= @Hoy
      ELSE
        DECLARE crInteresesMoratorios CURSOR FOR
         SELECT c.ID, lc.CobroIntereses, c.TipoTasa, c.TieneTasaEsp, c.TasaEsp, c.IVAInteresPorcentaje, c.Saldo*c.TipoCambio, c.InteresesFijos*c.TipoCambio, c.TasaDiaria, tt.MoratoriosFactor, ta.Metodo --MEJORA10041
           FROM Cxp c
           JOIN TipoTasa tt ON tt.TipoTasa = c.TipoTasa
           JOIN TipoAmortizacion ta ON ta.TipoAmortizacion = c.TipoAmortizacion
           JOIN LC ON lc.LineaCredito = c.LineaCredito --MEJORA10041
          WHERE c.Empresa = @Empresa AND c.Estatus = 'PENDIENTE' AND c.Vencimiento <= @Hoy
 
      OPEN crInteresesMoratorios
      FETCH NEXT FROM crInteresesMoratorios INTO @ID, @CobroIntereses, @TipoTasa, @TieneTasaEsp, @TasaEsp, @IVAInteresPorcentaje, @Saldo, @InteresesFijos, @TasaDiaria, @MoratoriosFactor, @Metodo --MEJORA10041
      WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
      BEGIN                         
        IF @@FETCH_STATUS <> -2 AND @Ok IS NULL 
        BEGIN
          /*IF @Metodo = 50*/
            SELECT @Moratorios = (ISNULL(@Saldo, 0.0)+ISNULL(@InteresesFijos, 0.0))*(@TasaDiaria/100.0)*@MoratoriosFactor

          /*ELSE
            SELECT @Moratorios = @Saldo*(@TasaDiaria/100.0)*@MoratoriosFactor*/

          SELECT @Moratorios = @Moratorios * @FactorMes
					EXEC xpACDevengarInteresesMoratorios @Modulo, @ID, @Moratorios OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
					
					IF @ID IS NOT NULL AND ISNULL(@Moratorios, 0.0) <> 0.0
          BEGIN
             IF UPPER(@CobroIntereses) = 'DEVENGADOS' --MEJORA10041
             BEGIN
						 BEGIN TRY
							 SET @InteresIVAImporte = dbo.fnInteresIVAImporte(@TipoTasa, @TieneTasaEsp, @TasaEsp, @Inflacion, @Moratorios, @IVAInteresPorcentaje, 0.0, 0)
							END TRY
							BEGIN CATCH
								SET @InteresIVAImporte=NULL
							END CATCH         
             END ELSE
               SET @InteresIVAImporte = NULL
            /*INICIA: modificacion calculo del importe de iva de los intereses, cvazquez*/
		  EXEC xpACDevengarInteresesMoratoriosIVA @Modulo, @ID, @Moratorios, @InteresIVAImporte OUTPUT,@Ok OUTPUT, @OkRef OUTPUT        
            /*Termina: modificacion calculo del importe de iva de los intereses, cvazquez*/
		  SELECT @Renglon = @Renglon + 2048.0, @SumaIntereses = @SumaIntereses + ISNULL(@Moratorios, 0.0)
            IF @Modulo = 'CXC'          
              INSERT CxcD (ID,          Sucursal,  Renglon,  Aplica, AplicaID, InteresesMoratorios,      InteresesMoratoriosIVA) --MEJORA10041
                   SELECT @InteresesID, @Sucursal, @Renglon, Mov,    MovID,    NULLIF(@Moratorios, 0.0), @InteresIVAImporte --MEJORA10041
                     FROM Cxc
                    WHERE ID = @ID
            ELSE
              INSERT CxpD (ID,          Sucursal,  Renglon,  Aplica, AplicaID, InteresesMoratorios,      InteresesMoratoriosIVA) --MEJORA10041
                   SELECT @InteresesID, @Sucursal, @Renglon, Mov,    MovID,    NULLIF(@Moratorios, 0.0), @InteresIVAImporte --MEJORA10041
                     FROM Cxp
                    WHERE ID = @ID
          END
        END
   FETCH NEXT FROM crInteresesMoratorios INTO @ID, @CobroIntereses, @TipoTasa, @TieneTasaEsp, @TasaEsp, @IVAInteresPorcentaje, @Saldo, @InteresesFijos, @TasaDiaria, @MoratoriosFactor, @Metodo --MEJORA10041
      END  -- While
      CLOSE crInteresesMoratorios
      DEALLOCATE crInteresesMoratorios
    END

    IF @Modulo = 'CXC'
    BEGIN
      IF EXISTS(SELECT * FROM CxcD WHERE ID = @InteresesID)
        UPDATE Cxc SET Importe = @SumaIntereses WHERE ID = @InteresesID
      ELSE 
      BEGIN
        DELETE Cxc WHERE ID = @InteresesID
        SELECT @InteresesID = NULL
      END
    END ELSE
    BEGIN
      IF EXISTS(SELECT * FROM CxpD WHERE ID = @InteresesID)
        UPDATE Cxp SET Importe = @SumaIntereses WHERE ID = @InteresesID
      ELSE 
      BEGIN
        DELETE Cxp WHERE ID = @InteresesID
        SELECT @InteresesID = NULL
      END
    END

    IF @InteresesID IS NOT NULL
      EXEC spCx @InteresesID, @Modulo, 'AFECTAR', 'TODO', @FechaRegistro, NULL, @Usuario, 0, 0, @InteresesMov OUTPUT, @InteresesMovID OUTPUT, NULL, @Ok OUTPUT, @OkRef OUTPUT
  END
  RETURN
END