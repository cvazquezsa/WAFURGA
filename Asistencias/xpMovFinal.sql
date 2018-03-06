SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
/************** xpMovFinal *************/
if exists (select * from sysobjects where id = object_id('dbo.xpMovFinal') and type = 'P') drop procedure dbo.xpMovFinal
GO
CREATE PROCEDURE xpMovFinal  
@Empresa       char(5),  
@Sucursal      int,  
@Modulo        char(5),  
@ID            int,  
@Estatus       char(15),  
@EstatusNuevo  char(15),  
@Usuario       char(10),  
@FechaEmision  datetime,  
@FechaRegistro datetime,  
@Mov           char(20),  
@MovID         varchar(20),  
@MovTipo       char(20),  
@IDGenerar     int,  
@Ok            int  OUTPUT,  
@OkRef         varchar(255) OUTPUT  

AS BEGIN
  IF @EstatusNuevo IN ('PENDIENTE', 'CONCLUIDO', 'PROCESAR') AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000)
    EXEC spReconstruirMovImpuesto @Modulo,@ID
/*FIN ContaSAT*/
   DECLARE @SubClave  varchar(20)

IF @Modulo='COMS'  
BEGIN
  IF @MovTipo='COMS.PR'
  BEGIN
    SELECT @SubClave=SubClave FROM Movtipo WHERE Mov=@Mov and Modulo=@Modulo
    IF @SubClave='COMS.PRAUM'
    BEGIN
      EXEC spWFGAumentaPresupuesto @ID
    END
    IF @SubClave='COMS.PRDIS'
    BEGIN
      EXEC spWFGDisminuyePresupuesto @ID
    END
  END
END

/*INICIO ContaSAT Colocar al Final del Script*/
/*Este bloque sirve para regenerar el registro de MovImpuesto */

  IF @Modulo IN ('DIN') AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000)
  BEGIN
    EXEC xpActualizarContSATComprobante @Modulo, @ID    
  END

  IF EXISTS(SELECT ContX FROM EMPRESAGRAL WHERE Empresa = @Empresa AND ContX = 1) AND @Modulo = 'CONT' AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000)
  BEGIN
    EXEC spContSATConexionContable @Empresa,@Modulo,@ID
	/*  BUG 2544 Descomentar la siguiente línea en caso de que se tengan movimientos de Amortización con generación de UUID's.
		y las pólizas se generen con la herramienta Conexión Contable.	
		Se deberá contar con el Stored Procedure spObtenerUUIDAnterior */
	--EXEC spObtenerUUIDAnterior @Empresa,@Modulo,@ID
  END

  -- Bug 2638 Se agrega Módulo de CXP para poder asociar comprobante a las pólizas que se generan en CXP
  -- IF @Modulo IN('CXC','CXP','VTAS') AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000)
  IF @Modulo IN('CXC','VTAS') AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000)
    EXEC xpContSAT @Empresa,@Modulo,@ID

  IF @Modulo IN('GAS','CXP','DIN')  
    EXEC spAsociacionRetroactiva @Modulo, @ID, @Empresa 

  EXEC spContSATMovFlujo @Empresa, @Sucursal, @Modulo, @ID, @Mov, @MovID, @Estatus
/*FIN ContaSAT*/
--User Story 9085
  IF @Modulo IN ('VTAS','DIN') 
    EXEC xpAsociarNotasCorte @ID, @Mov, @Modulo, @Empresa, @Sucursal, @Estatus

--User Story 14313
  IF @Modulo = 'DIN' AND (SELECT dbo.fnMovTipo(@Modulo, @Mov)) IN ('DIN.D','DIN.DE')
	EXEC xpAsociarCFDICobro @ID, @Empresa

--WAFURGA
  IF @Modulo = 'ASIS' AND @EstatusNuevo='CONCLUIDO' AND (SELECT dbo.fnMovTipo(@Modulo, @Mov)) IN ('ASIS.C')
	EXEC spWfgHorasExtra @Empresa,@Sucursal,@Modulo,@ID,@Estatus,@EstatusNuevo,@Usuario,@FechaEmision,@FechaRegistro,@Mov,@MovID,@MovTipo,@IDGenerar,
					@Ok OUTPUT,@OkRef OUTPUT  
  

--RETURN  

END 
GO 
--SELECT * FROM ASISTE ORDER BY ID DESC