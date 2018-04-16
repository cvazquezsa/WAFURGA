SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF NOT object_id('dbo.xpMovFinal', 'P') IS NULL DROP PROCEDURE dbo.xpMovFinal
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
  IF @MovTipo='COMS.O' AND @EstatusNuevo='PENDIENTE'
  BEGIN
    EXEC spWFGUpdateArtSubLinea @ID

  END


END

 
RETURN  
END  
GO







