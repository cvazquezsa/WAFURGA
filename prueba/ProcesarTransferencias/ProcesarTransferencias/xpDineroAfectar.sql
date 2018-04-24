IF EXISTS (SELECT * FROM sysObjects WHERE Name='xpDineroAfectar' AND Type='P')
	DROP PROCEDURE xpDineroAfectar
GO

/*********** xpDineroAfectar **********/
CREATE PROCEDURE xpDineroAfectar  
  
@ID                 int,  
@Accion   char(20),  
@Empresa            char(5),  
@Usuario   char(10),  
@Modulo         char(5),  
@Mov                char(20),  
@MovID   varchar(20),  
@MovTipo         char(20),  
@MovMoneda   char(10),  
@MovTipoCambio  float,  
@Estatus   char(15),  
@EstatusNuevo        char(15),  
@CtaDinero   char(10),  
@CtaDineroTipo  char(20),  
@CtaDineroDestino  char(10),  
@CtaDineroFactor  float,  
@CtaDineroTipoCambio float,  
@CtaDineroMoneda  char(10),  
@Cajero   char(10),  
@Importe   money,  
@Impuestos   money,  
@Saldo   money,  
@Directo                 bit,  
@CfgContX   bit,  
@CfgContXGenerar  char(20),  
@Conexion   bit,  
@SincroFinal  bit,  
@Sucursal   int,  
@Ok                 int          OUTPUT,  
@OkRef              varchar(255) OUTPUT  
  
AS BEGIN  
 DECLARE  
  @Cliente varchar(20),  
  @MovGeneradoSD varchar(20), --Solicitud de Deposito
  @SubClave	varchar(20)  
  
 ---  
 SELECT @MovGeneradoSD=BancoSolicitudDeposito FROM EmpresaCfgMov WHERE Empresa=@Empresa  
 ---  
 /****INICIA CONTACTO EN CORTE DE CAJA. CARLOS VAZQUEZ 10/03/2017****/  
 IF @MovTipo IN ('DIN.C','DIN.CP') AND @Accion='AFECTAR'--DIN.C,DIN.CP  
 BEGIN --contacto  
  ---  
  SELECT @Cliente=ClienteFacturaVMOS FROM EmpresaCFG WHERE Empresa=@Empresa  
  ---  
  --VALIDAR  
  IF ISNULL(@Cliente,'')='' SELECT @Ok=10580  
  ---  
  IF ISNULL(@Ok,0)=0  
  BEGIN--@OK=0  
   UPDATE Dinero SET Contacto=@Cliente WHERE ID=@ID  
   IF EXISTS(SELECT * FROM MovFlujo   
    WHERE Sucursal=@Sucursal AND Empresa=@Empresa AND OModulo=@Modulo AND OMov=@Mov AND OID=@ID AND DMov=@MovGeneradoSD)  
   UPDATE Dinero SET Contacto=@Cliente WHERE ID in (SELECT DID FROM MovFlujo   
            WHERE Sucursal=@Sucursal AND Empresa=@Empresa AND OModulo=@Modulo AND OMov=@Mov AND OID=@ID   
            AND DMov=@MovGeneradoSD)  
  END--@Ok=0  
 END--contacto  
 /****TERMINA CONTACTO EN CORTE DE CAJA. CARLOS VAZQUEZ 10/03/2017****/  
 IF @MovTipo IN ('DIN.C','DIN.CP') AND @Accion='AFECTAR'--DIN.C,DIN.CP  
  EXEC xpWfgCorteCaja @ID,@Accion,@Empresa,@Usuario,@Modulo,@Mov,@MovID,@MovTipo,@MovMoneda,@MovTipoCambio,@Estatus,@EstatusNuevo,  
       CtaDinero,@CtaDineroTipo,@CtaDineroDestino,@CtaDineroFactor,@CtaDineroTipoCambio,@CtaDineroMoneda,@Cajero,  
       @Importe,@Impuestos,@Saldo,@Directo,@CfgContX,@CfgContXGenerar,@Conexion,@SincroFinal,@Sucursal,@Ok OUTPUT,@OkRef OUTPUT 
	   
--/****INICIA AFECTACION DE CORTE ESTADISTICO. CARLOS VAZQUEZ 15/05/2017****/ 
--/*Este proceso genera cargos y abonos banacarios resultado de comparar el corte estadistico contra el corte multimoneda*/
--IF @MovTipo IN ('DIN.EST') AND @Accion='AFECTAR'
--BEGIN
--	SELECT @SubClave=SubClave FROM MovTipo WHERE Mov=@Mov AND Modulo=@Modulo--DIN.CEMULTIMONEDA
--	IF ISNULL(@SubClave,'')='DIN.CEMULTIMONEDA'
--		EXEC xpWfgCorteEst @ID,@Accion,@Empresa,@Usuario,@Modulo,@Mov,@MovID,@MovTipo,@MovMoneda,@MovTipoCambio,@Estatus,@EstatusNuevo,  
--			CtaDinero,@CtaDineroTipo,@CtaDineroDestino,@CtaDineroFactor,@CtaDineroTipoCambio,@CtaDineroMoneda,@Cajero,  
--			@Importe,@Impuestos,@Saldo,@Directo,@CfgContX,@CfgContXGenerar,@Conexion,@SincroFinal,@Sucursal,@Ok OUTPUT,@OkRef OUTPUT   
--/****TERMINA AFECTACION DE CORTE ESTADISTICO. CARLOS VAZQUEZ 15/05/2017****/    
--END

	/****INICIA LLENADO DE PROCESAR TRANSFERENCIAS. CARLOS VAZQUEZ 25/04/2018****/ 
	/* Este sp sirve para alimentar la tabla ProcesarTrasnferencias cuadno se concluye un deposito*/
	IF @MovTipo IN ('DIN.D') AND @Accion IN ('AFECTAR', 'CANCELAR')
	BEGIN
			EXEC spProcesarTransferenciasLlenado @ID,@Accion,@Empresa,@Usuario,@Modulo,@Mov,@MovID,@MovTipo,@MovMoneda,@MovTipoCambio,@Estatus,@EstatusNuevo,  
				CtaDinero,@CtaDineroTipo,@CtaDineroDestino,@CtaDineroFactor,@CtaDineroTipoCambio,@CtaDineroMoneda,@Cajero,  
				@Importe,@Impuestos,@Saldo,@Directo,@CfgContX,@CfgContXGenerar,@Conexion,@SincroFinal,@Sucursal,@Ok OUTPUT,@OkRef OUTPUT      
	END
	/****TERMINA LLENADO DE PROCESAR TRANSFERENCIAS. CARLOS VAZQUEZ 25/04/2018****/ 
  
RETURN  
  
END 
GO 