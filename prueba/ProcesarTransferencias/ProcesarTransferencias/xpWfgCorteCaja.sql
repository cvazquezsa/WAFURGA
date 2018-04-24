IF EXISTS (SELECT * FROM sysObjects WHERE Name='xpWfgCorteCaja' AND Type='P')
	DROP PROCEDURE xpWfgCorteCaja
GO
/*********** xpWfgCorteCaja **********/
CREATE PROCEDURE xpWfgCorteCaja  
	@ID                 int,  
	@Accion     char(20),  
	@Empresa            char(5),  
	@Usuario    char(10),  
	@Modulo          char(5),  
	@Mov                char(20),  
	@MovID     varchar(20),  
	@MovTipo         char(20),  
	@MovMoneda    char(10),  
	@MovTipoCambio   float,  
	@Estatus    char(15),  
	@EstatusNuevo        char(15),  
	@CtaDinero    char(10),  
	@CtaDineroTipo   char(20),  
	@CtaDineroDestino  char(10),  
	@CtaDineroFactor  float,  
	@CtaDineroTipoCambio float,  
	@CtaDineroMoneda  char(10),  
	@Cajero     char(10),  
	@Importe    money,  
	@Impuestos    money,  
	@Saldo     money,  
	@Directo             bit,  
	@CfgContX    bit,  
	@CfgContXGenerar  char(20),  
	@Conexion    bit,  
	@SincroFinal   bit,  
	@Sucursal    int,  
	@Ok                 int          OUTPUT,  
	@OkRef              varchar(255) OUTPUT  
  
AS BEGIN --INICIA xpWfgCorteCaja  
 DECLARE  
  @MovGeneradoSD varchar(20), --Solicitud de Deposito  
  @MovGenerarBD varchar(20),--Deposito  
  @IDGenerar  int,  
  @Accion2  varchar(20), --accion para spAfectar  
  @DID   int,  
  @FormaPago  varchar(50),  
  @MensajeTipo varchar(20),  
  @SubClave  varchar(50),  
  @CorteEST  varchar(20),  
  @FechaEmision datetime,  
  @Moneda   varchar(20),  
  @TipoCambio  money,  
  @Referencia  varchar(255),  
  @Observaciones varchar(255),  
  @EstatusEST  varchar(20),  
  @Contacto  varchar(20),  
  @ContactoTipo varchar(20),  
  @Ejercicio  int,  
  @Periodo  int,  
  @SucursalOrigen int,  
  @SucursalDestino int,  
  @IDEST   int,  
  @RenglonEST  int,  
  @RenglonSubEST  int,  
  @ImporteDEST money,  
  @FormaPagoDEST varchar(50),  
  @SucursalDEST int,  
  @CtaDineroDEST varchar(20),  
  @TipoCambioDEST float,  
  @MonedaDEST  varchar(20),  
  @CtaDineroDestinoDEST varchar(10),  
  @SucursalOrigenDEST int,
  @MovIDEst	varchar(20)
  
 ---  
 SELECT @MovGeneradoSD=BancoSolicitudDeposito,@MovGenerarBD=BancoDeposito FROM EmpresaCfgMov WHERE Empresa=@Empresa  
 SELECT @Accion2='GENERAR'  
 SELECT @FormaPago=FormaPago FROM DineroD WHERE ID=@ID  
 SELECT @CorteEST='Corte Estadistico'  
 SELECT @SubClave=SubClave FROM MovTipo WHERE Mov=@Mov AND Modulo=@Modulo  
 ---  
 --AFECTACION DE DEPOSITOS  
 IF ISNULL(@Ok,0)=0 AND @Accion='AFECTAR'  
 BEGIN --Validado 
 --SELECT * FROM MovFlujo   
 --   WHERE Sucursal=@Sucursal AND Empresa=@Empresa AND OModulo=@Modulo AND OMov=@Mov AND DMov=@MovGeneradoSD AND OID=@ID   
  DECLARE crWfgDID CURSOR FAST_FORWARD FOR  
   SELECT DID FROM MovFlujo   
    WHERE Sucursal=@Sucursal AND Empresa=@Empresa AND OModulo=@Modulo AND OMov=@Mov AND DMov=@MovGeneradoSD AND OID=@ID  
  
  OPEN crWfgDID  
  FETCH NEXT FROM crWfgDID INTO  
   @DID--solicitud de deposito  
  
  WHILE @@FETCH_STATUS=0 AND ISNULL(@Ok,0)=0  
  BEGIN --crWfgDID  
   --AFECTAMOS SOLICITUD DE DEPOSITO Y GENERAMOS DEPOSITO  
  
    --AFECTAMOS DEPOSITO  
    --SELECT 'P1'+ @FormaPago
		--SELECT Importe, FormaPago 
		--		FROM DineroD WHERE ID=@ID  
	
		DECLARE crWfgDepositos CURSOR FOR
			SELECT Importe, FormaPago 
				FROM DineroD WHERE ID=@DID

		OPEN crWfgDepositos
		FETCH NEXT FROM crWfgDepositos INTO
			@ImporteDEST,@FormaPago
	
		WHILE @@FETCH_STATUS=0
		BEGIN
			--SELECT @FormaPago
			--Generamos deposito
			SELECT @CtaDineroDestinoDEST = CtaDineroDestino FROM Dinero WHERE ID=@ID
			SELECT @TipoCambioDEST=TipoCambio FROM Dinero WHERE ID=@DID
			UPDATE Dinero SET CtaDinero=@CtaDineroDestinoDEST WHERE ID=@DID
			--SELECT @TipoCambioDEST
			EXEC @IDGenerar=spAfectar @Modulo, @DID, @Accion2, 'Todo', @MovGenerarBD, @Usuario, @SincroFinal = @SincroFinal,@EnSilencio=1, @Ok=@Ok OUTPUT, @OkRef=@OkRef OUTPUT, @Conexion=@Conexion   
			SELECT @MensajeTipo=Tipo FROM MensajeLista WHERE Mensaje=@Ok  
			IF @MensajeTipo<>'Error' 
				SELECT @Ok=NULL  
			IF ISNULL(@Ok,0)=0  
			BEGIN --UPDATE  
				--SELECT @Importe
				UPDATE DineroD SET FormaPago=@FormaPago/*,Importe=@Importe*/ WHERE ID=@IDGenerar
				UPDATE Dinero SET /*Importe=@Importe,*/TipoCambio=@TipoCambioDEST WHERE ID=@IDGenerar
				EXEC spAfectar @Modulo, @IDGenerar, @Accion, 'Todo', NULL, @Usuario,@SincroFinal = @SincroFinal, @EnSilencio=1, @Ok=@Ok OUTPUT, @OkRef=@OkRef OUTPUT, @Conexion=@Conexion   
				--SELECT * FROM Dinero WHERE ID=@IDGenerar
				 SELECT @MensajeTipo=Tipo FROM MensajeLista WHERE Mensaje=@Ok  
				IF @MensajeTipo<>'Error'  
					SELECT @Ok=NULL  
				END --UPDATE  
			
			FETCH NEXT FROM crWfgDepositos INTO
				@ImporteDEST,@FormaPago
		END
		CLOSE crWfgDepositos
		DEALLOCATE crWfgDepositos
	 
  FETCH NEXT FROM crWfgDID INTO  
   @DID  
  END --crWfgDID  
  CLOSE crWfgDID  
  DEALLOCATE crWfgDID  
 END --Validado  
   
 --/*GENERACION DE ESTADISTICO*/  
 --IF ISNULL(@Ok,0)=0 AND @Accion='AFECTAR' AND @MovTipo='DIN.C' AND @SubClave='DIN.CMULTIMONEDA'  
 --BEGIN--GENERACION DE ESTADISTICO  
 -- ---  
 -- SELECT @FechaEmision=FechaEmision, @Moneda=Moneda, @TipoCambio=TipoCambio, @Referencia=Referencia,@Observaciones=Observaciones,@Contacto=Contacto,  
 --   @ContactoTipo=ContactoTipo,@Ejercicio=Ejercicio,@Periodo=Periodo,@SucursalOrigen=SucursalOrigen,@SucursalDestino=SucursalDestino,  
 --   @CtaDinero=CtaDinero   
 --  FROM Dinero WHERE ID=@ID  
 -- SELECT @EstatusEST='SINAFECTAR'  
 -- --SELECT * FROM Dinero WHERE ID=1978955  
 -- --SELECT * FROM DineroD WHERE ID=1978955  
 -- ---  
 -- INSERT INTO Dinero (Empresa, Mov,  FechaEmision, Moneda,  TipoCambio,  Referencia,  Observaciones, Usuario, Estatus,   
 --      Directo, CtaDinero, ConDesglose, Contacto, ContactoTipo, Importe, Cajero, OrigenTipo, Origen, OrigenID,  
 --      GenerarPoliza, Ejercicio, Periodo, Sucursal, SucursalOrigen, SucursalDestino)  
 --    VALUES( @Empresa, @CorteEST, @FechaEmision, @Moneda, @TipoCambio, @Referencia, @Observaciones, @Usuario, @EstatusEST,  
 --      1,   @CtaDinero, 1,    @Contacto, @ContactoTipo, NULL,  @Cajero,'DIN',  @Mov, @MovID,  
 --      1,    @Ejercicio, @Periodo, @Sucursal, @SucursalOrigen,@SucursalDestino)  
 -- SELECT @IDEST=SCOPE_IDENTITY()       
 -- DECLARE crWfgDineroD CURSOR FAST_FORWARD FOR  
 --  SELECT Renglon, RenglonSub,Importe,FormaPago,Sucursal,CtaDinero,Moneda,CtaDineroDestino,TipoCambio,SucursalOrigen   
 --   FROM DineroD WHERE ID=@ID  
 -- OPEN crWfgDineroD  
 -- FETCH NEXT FROM crWfgDineroD INTO  
 --  @RenglonEST,@RenglonSubEST,@ImporteDEST,@FormaPagoDEST,@SucursalDEST,@CtaDineroDEST,@MonedaDEST,@CtaDineroDestinoDEST,@TipoCambioDEST,  
 --  @SucursalOrigenDEST  
 -- WHILE @@FETCH_STATUS=0  
 -- BEGIN--crWfgDineroD  
 --  INSERT INTO DineroD(ID,  Renglon, RenglonSub,  Importe,  FormaPago,  Sucursal,  CtaDinero,  Moneda,  
 --       CtaDineroDestino,  TipoCambio,  SucursalOrigen)  
 --     VALUES( @IDEST, @RenglonEST,@RenglonSubEST, @ImporteDEST, @FormaPagoDEST, @SucursalDEST, @CtaDineroDEST, @MonedaDEST,  
 --       @CtaDineroDestinoDEST, @TipoCambioDEST,@SucursalOrigenDEST)  
 --  FETCH NEXT FROM crWfgDineroD INTO  
 --   @RenglonEST,@RenglonSubEST,@ImporteDEST,@FormaPagoDEST,@SucursalDEST,@CtaDineroDEST,@MonedaDEST,@CtaDineroDestinoDEST,@TipoCambioDEST,  
 --   @SucursalOrigenDEST   
 -- END--crWfgDineroD  
 -- CLOSE crWfgDineroD  
 -- DEALLOCATE crWfgDineroD

	--IF ISNULL(@Ok,0)=0--asigna MovID al movimiento insertado.
	--BEGIN--Consecutivo y MovFlujo
	--	EXEC spAfectar @Modulo, @IDEST, 'CONSECUTIVO', 'Todo', NULL, @Usuario,@EnSilencio=1, @Ok=@Ok OUTPUT, @OkRef=@OkRef OUTPUT, @Conexion=1   
		
	--	SELECT @MovIDEst=MovID FROM Dinero WHERE ID=@IDEST
		
	--	INSERT INTO MovFlujo (	Sucursal,	Empresa,	OModulo,	OID,	OMov,	OMovID,	DModulo,	DID,	DMov,		DMovID,		Cancelado)
	--					SELECT	@Sucursal,	@Empresa,	@Modulo,	@ID,	@Mov,	@MovID,	@Modulo,	@IDEST,	@CorteEST,	@MovIDEst,	0
								
			
	--	--SELECT * FROM MovFlujo WHERe OModulo='DIN'
		
	--	SELECT @MensajeTipo=Tipo FROM MensajeLista WHERE Mensaje=@Ok  
	--	IF @MensajeTipo='INFO'  
	--		SELECT @Ok=NULL
	--END--Consecutivo y MovFlujo
         
 --END--GENERACION DE ESTADISTICO  
END --TERMINA xpWfgCorteCaja
GO

--BEGIN TRANSACTION
--DECLARE @Ok int, @OkRef varchar(255)
--	--SELECT * FROM Dinero ORDER BY ID DESC
--	--SELECT * FROM DineroD WHERE ID=2044577
--	--UPDATE DineroD SET Moneda='Pesos',TipoCambio=1 WHERE ID=2044528 AND Renglon=4096
--	EXEC spAfectar 'DIN', 2341243, 'AFECTAR', 'Todo', NULL, 'INTELISIS',@EnSilencio=1, @Ok=@Ok OUTPUT, @OkRef=@OkRef OUTPUT, @Conexion=1
--	--SELECT @Ok,@OkRef
	
--	IF @@TRANCOUNT>0   
--		ROLLBACK
		
		--SELECT * fROM DineroD WHERE Id=2045195    