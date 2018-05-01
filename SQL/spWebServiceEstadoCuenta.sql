SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE dbo.spWebServiceEstadoCuenta
		@Cliente	VARCHAR(10),
		@tarjeta	VARCHAR(30),
		@Empresa	VARCHAR(5),
		@Op				VARCHAR(10)				
			
AS 
BEGIN    
	DECLARE
		@resp								VARCHAR(10),
		@movimiento							VARCHAR(30),
		@idmov								VARCHAR(10),
		@id									VARCHAR(10),
		@amov								VARCHAR(30),
		@vencimiento						DATETIME,
		@importe							MONEY,
		@impuestos							MONEY,
		@InteresesOrdinarios				MONEY,
		@SaldoInteresesOrdinarios			MONEY,
		@SaldoInteresesMoratorios			MONEY,
		@SaldoInteresesOrdinariosIVA		MONEY,	
		@SaldoInteresesMoratoriosIVA		MONEY,
		@credito							MONEY,
		@Saldo								MONEY,
		@OrigenID							VARCHAR(20),
		@ImporteOrigen						MONEY,
		@ImporteTotalOrigen					MONEY,
		@ImpuestosOrigen					MONEY,
		@FechaOrigen						DATETIME


  CREATE TABLE #CuentaEncabezado(
  								 Cliente			VARCHAR(10) COLLATE Database_Default NULL,	
  								 Empresa			VARCHAR(20) COLLATE Database_Default NULL,	
								 Credito			MONEY								 NULL,
								 Saldo				MONEY								 NULL,
								 Tarjeta			VARCHAR(20)	COLLATE Database_Default NULL,
								 LimiteCredito		MONEY								 NULL,
								 
								 ------------D A T O S  P E R S O N A L E S-------------------
								 
								 Estado				VARCHAR(30)	COLLATE Database_Default NULL,
								 Delegacion			VARCHAR(100)COLLATE Database_Default NULL,
								 Pais				VARCHAR(30)	COLLATE Database_Default NULL,
								 CodigoPostal		VARCHAR(15)	COLLATE Database_Default NULL,
								 Telefono			VARCHAR(50)	COLLATE Database_Default NULL,
								 RFC				VARCHAR(15)	COLLATE Database_Default NULL
								)


  CREATE TABLE #CuentaMov(
    							 Cliente			VARCHAR(10) COLLATE Database_Default NULL,	
    							 Empresa			VARCHAR(20) COLLATE Database_Default NULL,	
  								 Mov				VARCHAR(20) COLLATE Database_Default NULL,
  								 ID					INT									 NULL,
  								 MovID				VARCHAR(10)							 NULL,	
								 Importe			MONEY								 NULL,
								 Impuestos			MONEY								 NULL,
								 Saldo				MONEY								 NULL,
								 Intereses			MONEY								 NULL,
								 InteresesMoratorios MONEY								 NULL,
								 FechaVencimiento	VARCHAR(10) COLLATE Database_Default NULL,
								 DocFuente			INT,
								 OrigenId			VARCHAR(20),
								 ImporteOrigen		MONEY,
								 Impuestosorigen	MONEY,
								 ImporteTotalOrigen MONEY,
								 FechaOrigen        VARCHAR(10) COLLATE Database_Default NULL
								
								 
								 
								 
								)

  --select @saldo=(s.Saldo*m.TipoCambio) FROM CxcSaldo s, Mon m 
  -- WHERE s.Moneda = m.Moneda  
  --   AND Empresa=@Empresa 
  --   AND Cliente=@Cliente
  
  SELECT @credito= importe  
	FROM lc 
   WHERE Acreditado=@Cliente 
	 AND LineaCredito=@tarjeta 
	 AND Empresa=@Empresa
  
  SELECT @Saldo = SUM(ISNULL(saldo,0)+ISNULL(SaldoInteresesOrdinarios,0)+ISNULL(SaldoInteresesMoratorios,0)+ISNULL(SaldoInteresesOrdinariosIVA,0)+ISNULL(SaldoInteresesMoratoriosIVA,0)) 
	FROM Cxc c 
	JOIN movtipo m 
	  ON c.Mov=m.Mov  
   WHERE c.empresa=@Empresa 
	 AND c.cliente=@Cliente 
	 AND Estatus='PENDIENTE' 
	 AND m.Clave='CXC.D' OR m.Clave='CXC.f'
	 AND c.LineaCredito=@tarjeta

	 SELECT @Saldo = @Saldo + ISNULL(c.Saldo,0) 
		FROM CXC c
		WHERE c.Mov='Cargo Moratorio'
			AND c.Cliente = @Cliente 
			AND c.Estatus = 'PENDIENTE'
	 
 ----------------------------------------------
 -- T A B L A   P A R A  E N C A B E Z A D O --
 ----------------------------------------------
   
  INSERT INTO #CuentaEncabezado	(Cliente,				Credito,				Saldo,					Tarjeta,
								 LimiteCredito,			Estado,					Delegacion,				CodigoPostal,
								 Pais,					Telefono,				RFC						
								)
						SELECT   @Cliente,				Credito,				ISNULL(@saldo,0),		Cuenta,
								 @credito,				Estado,					Delegacion,				CodigoPostal,
								 Pais,					Telefonos,				RFC					  
						  FROM	 Cte 
						 WHERE	Cliente=@Cliente

 ---------------------->CURSOR  MOVIMIENTOS
 
 
 
  DECLARE CurEstadoCuenta CURSOR FAST_FORWARD FOR   
	  SELECT 		Cliente,						Empresa,						mov,						Importe,	impuestos,		
					Saldo,							InteresesOrdinarios,			vencimiento,				id,			movid,					
					LineaCredito,					OrigenID,						SaldoInteresesOrdinarios,	SaldoInteresesMoratorios,
					SaldoInteresesOrdinariosIVA,	SaldoInteresesMoratoriosIVA
		FROM Cxc 
	   WHERE Cliente=@Cliente 
	     AND Empresa=@Empresa 
	     AND Estatus='PENDIENTE'
	     --AND LineaCredito = @tarjeta
		OPEN CurEstadoCuenta   
  FETCH NEXT FROM CurEstadoCuenta INTO	@Cliente,						@Empresa,							@movimiento,				@Importe,	@impuestos,		
										@Saldo,							@InteresesOrdinarios,				@vencimiento,				@id,		@idmov, 
										@tarjeta,						@OrigenID,							@SaldoInteresesOrdinarios,	@SaldoInteresesMoratorios,
										@SaldoInteresesOrdinariosIVA,	@SaldoInteresesMoratoriosIVA
	   WHILE @@FETCH_STATUS <> -1  
	   BEGIN      

  SELECT @movimiento=omov,		@idmov=MovFlujo.OID,		@amov= MovFlujo.DMovID
    FROM MovFlujo 
    JOIN cxc 
      ON MovFlujo.DMovID=cxc.MovID 
   WHERE MovFlujo.DModulo='VTAS'

SELECT @ImporteOrigen= importe, @ImporteTotalOrigen = (Importe+Impuestos), @ImpuestosOrigen=Impuestos,@FechaOrigen=FechaEmision
FROM cxc
WHERE movid=@OrigenID


  INSERT INTO #CuentaMov (Cliente,								Empresa,		Mov,							Importe,							impuestos,				
						  FechaVencimiento,		 			    ID,				MovId,							ImporteTotalOrigen,					FechaOrigen,						
						  OrigenId,								
						  Intereses,		
						  InteresesMoratorios
						
						  )	
				SELECT	 @Cliente,								@Empresa,		Mov,							
				ISNULL(Saldo,0)+ISNULL(@SaldoInteresesOrdinarios,0)+ISNULL(@SaldoInteresesOrdinariosIVA,0) 
				+ ISNULL(@SaldoInteresesMoratorios,0)+ISNULL(@SaldoInteresesMoratoriosIVA,0),					ISNULL(impuestos,0),	
						 CONVERT(VARCHAR,@vencimiento,103),		@id,			movid,							ISNULL(@ImporteTotalOrigen,0),		CONVERT(VARCHAR,@FechaOrigen,103),	
						 @OrigenID,								
						 ISNULL(@SaldoInteresesOrdinarios,0)+ISNULL(@SaldoInteresesOrdinariosIVA,0),
						 ISNULL(@SaldoInteresesMoratorios,0)+ISNULL(@SaldoInteresesMoratoriosIVA,0)
					
				FROM Cxc 
				WHERE Cliente=@Cliente 
				AND Empresa=@Empresa 
				AND Estatus='PENDIENTE'
				--AND @tarjeta=LineaCredito
				AND @id=id

  FETCH NEXT FROM CurEstadoCuenta INTO  @Cliente,						@Empresa,							@movimiento,				@Importe,	@impuestos,		
										@Saldo,							@InteresesOrdinarios,				@vencimiento,				@id,		@idmov, 
										@tarjeta,						@OrigenID,							@SaldoInteresesOrdinarios,	@SaldoInteresesMoratorios,
										@SaldoInteresesOrdinariosIVA,	@SaldoInteresesMoratoriosIVA
	   END   
	   CLOSE CurEstadoCuenta  
	   DEALLOCATE CurEstadoCuenta				
-------------------------> CURSORs FIN
--SELECT omov FROM movflujo WHERE dmodulo='VTAS' AND dmovid=19
--SELECT * FROM MovFlujo mf
  IF(@Op='Encabezado')
  SELECT * FROM #CuentaEncabezado FOR XML RAW ('Cliente')
  
  
  ELSE	
   SELECT ISNULL((SELECT * from #CuentaMov FOR XML RAW ('Movimiento'), ROOT ('Movimientos')),'<Movimientos></Movimientos>')




RETURN 
END
