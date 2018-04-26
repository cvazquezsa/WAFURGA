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
	@Empresa				char(5),
	@Sucursal				int,
	@Modulo					char(5),
	@ID							int, 			
	@Estatus				char(15),
	@EstatusNuevo		char(15),
	@Usuario				char(10),
	@FechaEmision		datetime, 	
	@FechaRegistro	datetime,
	@Mov						char(20),
	@MovID					varchar(20),
	@MovTipo				char(20),
	@IDGenerar			int,
	@Ok							int		OUTPUT,
	@OkRef					varchar(255)	OUTPUT
AS BEGIN

	DECLARE @SubClave  varchar(20)

  IF @EstatusNuevo IN ('PENDIENTE', 'CONCLUIDO', 'PROCESAR') AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000)
    EXEC spReconstruirMovImpuesto @Modulo,@ID


  IF @Modulo IN ('DIN') AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000)
  BEGIN
    EXEC xpActualizarContSATComprobante @Modulo, @ID
  END
  IF EXISTS(SELECT ContX FROM EMPRESAGRAL WHERE Empresa = @Empresa AND ContX = 1) AND @Modulo = 'CONT' AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000)
  BEGIN
    EXEC spContSATConexionContable @Empresa,@Modulo,@ID
	
  END
  IF @Modulo IN('CXC','VTAS') AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000)
    EXEC xpContSAT @Empresa,@Modulo,@ID
  IF @Modulo IN('GAS','CXP','DIN')
    EXEC spAsociacionRetroactiva @Modulo, @ID, @Empresa
  EXEC spContSATMovFlujo @Empresa, @Sucursal, @Modulo, @ID, @Mov, @MovID, @Estatus
	
  IF @Modulo IN ('VTAS','DIN')
    EXEC xpAsociarNotasCorte @ID, @Mov, @Modulo, @Empresa, @Sucursal, @Estatus
  --IF @Modulo = 'DIN' AND (SELECT dbo.fnMovTipo(@Modulo, @Mov)) IN ('DIN.D','DIN.DE')

	--SELECT @Modulo
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
		--SELECT @MovTipo
		IF @MovTipo='COMS.O' AND @EstatusNuevo='PENDIENTE'
		BEGIN
			EXEC spWFGUpdateArtSubLinea @ID
		END
	END

	EXEC xpAsociarCFDICobro @ID, @Empresa
RETURN
END
GO






