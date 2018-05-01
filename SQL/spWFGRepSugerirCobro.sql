SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE spWFGRepSugerirCobro
		    @SugerirPago	varchar(20),		    
		    @Estacion			int,
    		@ImporteTotal	money = 0,
			@Empresa	varchar(5),
			@Contacto	char(10) --cliente
--//WITH ENCRYPTION
AS BEGIN
  DECLARE
    
    @Sucursal			int,
    @Hoy			datetime,
    @Vencimiento		datetime,
    @DiasCredito		int,
    @DiasVencido		int,
    @TasaDiaria			float,
    @Moneda			char(10)='pesos',
    @TipoCambio			float=1,
    @Modulo		char(5)='CXC',
    @Renglon			float,
    @Aplica			varchar(20),
    @AplicaID			varchar(20),
    @AplicaMovTipo		varchar(20),
    @Capital			money,
    @SaldoInteresesOrdinarios		money,
    @SaldoInteresesOrdinariosIVA	float, --MEJORA10041    
    @SaldoInteresesMoratorios		money,
    @SaldoInteresesMoratoriosIVA	float, --MEJORA10041        
    @ImpuestoAdicional		float,
    @Importe			money,
    @SumaImporte		money,
    @Impuestos			money,
    @DesglosarImpuestos 			bit,
    @LineaCredito					varchar(20),
    @Metodo							int,
    @InteresesOrdinariosConIVAFactor	float, --MEJORA10041
    @InteresesMoratoriosConIVAFactor	float,  --MEJORA10041,
		@ID	int

  DECLARE @CxcD TABLE (
	ID	int,
	Estacion	int,
	Sucursal	int,
	Renglon	int,
	Aplica varchar(20),
	AplicaID varchar(20),
	Importe money,
	InteresesOrdinarios money,
	InteresesOrdinariosIVA money,
	InteresesMoratorios	money,
	InteresesMoratoriosIVA	money,
	ImpuestoAdicional	money,
	Vencimiento datetime
	)
 -- INSERT CxcD (ID,Sucursal,Renglon,Aplica,AplicaID,Importe,InteresesOrdinarios,InteresesOrdinariosIVA,InteresesMoratorios,
	--InteresesMoratoriosIVA,ImpuestoAdicional) --MEJORA10041

  SELECT @DesglosarImpuestos = 0 , @Renglon = 0.0, @SumaImporte = 0.0, @ImporteTotal = NULLIF(@ImporteTotal, 0.0), @SugerirPago = UPPER(@SugerirPago)
  IF @SugerirPago <> 'IMPORTE ESPECIFICO' SELECT @ImporteTotal = NULL

  IF @Modulo = 'CXC'
  BEGIN
    SELECT @Hoy = GETDATE()
    

	
	
	DECLARE crAplica CURSOR FOR
     SELECT p.ID, p.Mov, p.MovID, p.Vencimiento, mt.Clave, ISNULL(p.Saldo*mt.Factor*p.MovTipoCambio/@TipoCambio, 0.0), ISNULL(p.SaldoInteresesOrdinarios*mt.Factor*p.MovTipoCambio/@TipoCambio, 0.0), 
		 ISNULL(p.SaldoInteresesOrdinariosIVA*mt.Factor*p.MovTipoCambio/@TipoCambio, 0.0), ISNULL(p.SaldoInteresesMoratorios*mt.Factor*p.MovTipoCambio/@TipoCambio, 0.0), ISNULL(p.SaldoInteresesMoratoriosIVA*mt.Factor*p.MovTipoCambio/@TipoCambio, 0.0), ta.Metodo, p.LineaCredito --MEJORA10041
       FROM CxcPendiente p
       JOIN MovTipo mt ON mt.Modulo = @Modulo AND mt.Mov = p.Mov
       LEFT OUTER JOIN CfgAplicaOrden a ON a.Modulo = @Modulo AND a.Mov = p.Mov
       LEFT OUTER JOIN Cxc r ON r.ID = p.RamaID
       LEFT OUTER JOIN TipoAmortizacion ta ON ta.TipoAmortizacion = r.TipoAmortizacion
      WHERE p.Empresa = @Empresa AND p.Cliente = @Contacto AND mt.Clave NOT IN ('CXC.SCH','CXC.SD')
      ORDER BY a.Orden, p.Vencimiento, p.Mov, p.MovID
    SELECT @DesglosarImpuestos = ISNULL(CxcCobroImpuestos, 0) FROM EmpresaCfg2 WHERE Empresa = @Empresa
  END 

  OPEN crAplica
  FETCH NEXT FROM crAplica INTO @ID, @Aplica, @AplicaID, @Vencimiento, @AplicaMovTipo, @Capital, @SaldoInteresesOrdinarios, @SaldoInteresesOrdinariosIVA, @SaldoInteresesMoratorios, @SaldoInteresesMoratoriosIVA, @Metodo, @LineaCredito --MEJORA10041
  WHILE @@FETCH_STATUS <> -1 AND ((@SugerirPago = 'SALDO VENCIDO' AND @Vencimiento<=@Hoy) OR (@SugerirPago = 'IMPORTE ESPECIFICO' AND @ImporteTotal > @SumaImporte) OR @SugerirPago = 'SALDO TOTAL')
  BEGIN
    IF @@FETCH_STATUS <> -2 
    BEGIN
	--select @Aplica, @AplicaID, @Vencimiento, @AplicaMovTipo, @Capital, @SaldoInteresesOrdinarios, @SaldoInteresesOrdinariosIVA, @SaldoInteresesMoratorios, @SaldoInteresesMoratoriosIVA, @Metodo, @LineaCredito       
/*
      IF @Modulo = 'CXC' AND (SELECT CobroIntereses FROM LC WHERE LineaCredito = @LineaCredito) = 'FIJOS' 
         SELECT @Intereses = @InteresesFijos 
      ELSE SELECT @Intereses = @InteresesOrdinarios
*/
      -- Borrar Intereses Ordinarios cuando son por Anticipado
      IF @Metodo IN (12, 22) SELECT @SaldoInteresesOrdinarios = 0.0, @SaldoInteresesOrdinariosIVA = 0.0 --MEJORA10041
      IF @Metodo = 50 SELECT @ImpuestoAdicional = DefImpuesto FROM EmpresaGral WHERE Empresa = @Empresa ELSE SELECT @ImpuestoAdicional = NULL
      -- Intereses Moratorios
	  IF @SumaImporte + @SaldoInteresesMoratorios + @SaldoInteresesMoratoriosIVA > @ImporteTotal --MEJORA10041
      BEGIN --MEJORA10041
        SELECT @InteresesMoratoriosConIVAFactor = @ImporteTotal - @SumaImporte --MEJORA10041
        SELECT @InteresesMoratoriosConIVAFactor = @InteresesMoratoriosConIVAFactor / (@SaldoInteresesMoratorios + @SaldoInteresesMoratoriosIVA) --MEJORA10041
        SELECT @SaldoInteresesMoratorios = @SaldoInteresesMoratorios * @InteresesMoratoriosConIVAFactor --MEJORA10041
        SELECT @SaldoInteresesMoratoriosIVA = @SaldoInteresesMoratoriosIVA * @InteresesMoratoriosConIVAFactor --MEJORA10041        
      END --MEJORA10041        
      SELECT @SumaImporte = @SumaImporte + @SaldoInteresesMoratorios + @SaldoInteresesMoratoriosIVA --MEJORA10041

      -- Intereses Ordinarios
      IF @SumaImporte + @SaldoInteresesOrdinarios + @SaldoInteresesOrdinariosIVA > @ImporteTotal --MEJORA10041
      BEGIN --MEJORA10041
        SELECT @InteresesOrdinariosConIVAFactor = @ImporteTotal - @SumaImporte --MEJORA10041
        SELECT @InteresesOrdinariosConIVAFactor = @InteresesOrdinariosConIVAFactor / (@SaldoInteresesOrdinarios + @SaldoInteresesOrdinariosIVA) --MEJORA10041
        SELECT @SaldoInteresesOrdinarios = @SaldoInteresesOrdinarios * @InteresesOrdinariosConIVAFactor --MEJORA10041
        SELECT @SaldoInteresesOrdinariosIVA = @SaldoInteresesOrdinariosIVA * @InteresesOrdinariosConIVAFactor --MEJORA10041        
      END        
      SELECT @SumaImporte = @SumaImporte + @SaldoInteresesOrdinarios + @SaldoInteresesOrdinariosIVA --MEJORA10041

      -- Capital
      IF @SumaImporte + @Capital > @ImporteTotal SELECT @Capital = @ImporteTotal - @SumaImporte
      SELECT @SumaImporte = @SumaImporte + @Capital

	  IF @SaldoInteresesMoratorios <> 0.0 OR @SaldoInteresesOrdinarios <> 0.0 OR @Capital <> 0.0
      BEGIN
        SELECT @Renglon = @Renglon + 2048.0
        
		IF @Modulo = 'CXC'
          INSERT @CxcD (ID,	Estacion,  Sucursal,  Renglon,  Aplica,  AplicaID,  Importe,               InteresesOrdinarios,		            InteresesOrdinariosIVA,                    InteresesMoratorios,                    InteresesMoratoriosIVA,                
    ImpuestoAdicional, Vencimiento) --MEJORA10041
               VALUES (@ID,	@Estacion, @Sucursal, @Renglon, @Aplica, @AplicaID, ISNULL(@Capital, 0.0), ISNULL(@SaldoInteresesOrdinarios, 0.0), ISNULL(@SaldoInteresesOrdinariosIVA, 0.0), ISNULL(@SaldoInteresesMoratorios, 0.0), ISNULL(@SaldoInteresesMoratoriosIVA, 0.0), 
							 ISNULL(@ImpuestoAdicional,0), @Vencimiento) --MEJORA10041
               
      END
      FETCH NEXT FROM crAplica INTO @ID, @Aplica, @AplicaID, @Vencimiento, @AplicaMovTipo, @Capital, @SaldoInteresesOrdinarios, @SaldoInteresesOrdinariosIVA, @SaldoInteresesMoratorios, @SaldoInteresesMoratoriosIVA, @Metodo, @LineaCredito --MEJORA10041
    END
  END
  CLOSE crAplica
  DEALLOCATE crAplica
  SELECT * FROM @CxcD ORDER BY Vencimiento, ID
  RETURN
END
GO