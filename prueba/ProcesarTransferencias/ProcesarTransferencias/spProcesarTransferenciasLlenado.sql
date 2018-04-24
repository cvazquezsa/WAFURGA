/*********** spProcesarTransferenciasLlenado **********/
/* Este sp sirve para alimentar la tabla ProcesarTrasnferencias cuadno se concluye un deposito*/
IF EXISTS (SELECT * FROM sysObjects WHERE Name='spProcesarTransferenciasLlenado' AND Type='P')
	DROP PROCEDURE spProcesarTransferenciasLlenado
GO
CREATE PROCEDURE spProcesarTransferenciasLlenado    
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
  
AS 
BEGIN--spProcesarTransferenciasLlenado
	DECLARE
		@FormaPago varchar(50),
		@ImporteAcumulado money,
		@Fecha datetime,
		@Concepto varchar(20) = 'Operación',
		@EstatusPT varchar(20) = 'PENDIENTE',
		@Concluir	bit = 0,
		@IDPT int,
		@IDSD	int,
		@IDCC	int,
		@ImporteAC money,
		@FormaPagoAC varchar(50)
	
	----
	SELECT TOP 1 @FormaPago = dd.FormaPago, @ImporteAcumulado = dd.Importe, @Fecha = d.FechaEmision
		FROM Dinero d
			JOIN DineroD dd ON d.ID = dd.ID
			WHERE d.ID = @ID
	SELECT @IDSD = OID FROM MovFlujo WHERE DID = @ID AND DModulo = 'DIN' AND OModulo = 'DIN' ANd OMov = 'Solicitud Deposito'
	SELECT @IDCC = OID FROM MovFlujo WHERE DID = @IDSD AND DModulo = 'DIN' AND OModulo = 'DIN' ANd OMov = 'Corte Caja'
	IF ISNULL(@IDCC,0) <> 0
		SELECT @ImporteAC = Importe, @FormaPagoAC = FormaPago FROM Dinero WHERE CorteDestino = @IDCC
	IF @FormaPagoAC = @FormaPago
		SELECT @ImporteAcumulado = CASE WHEN @ImporteAcumulado - @ImporteAC > 0 THEN  @ImporteAcumulado - @ImporteAC ELSE 0 END
	----

	IF @MovTipo = 'DIN.D' AND @Accion = 'AFECTAR'
	BEGIN--AFECTAR

		IF NOT EXISTS (
			SELECT * 
				FROM ProcesarTransferencias
				WHERE Sucursal = @Sucursal AND FormaPago = @FormaPago AND TipoCambio = @MovTipoCambio AND Fecha = @Fecha AND Concepto = @Concepto AND Estatus = @EstatusPT
				)
		BEGIN--Inserta ProcesarTransferencias
			INSERT INTO ProcesarTransferencias
				SELECT @Sucursal, @FormaPago, @MovTipoCambio, @ImporteAcumulado, @ImporteAcumulado, @Fecha, @Fecha, @Concepto, @EstatusPT, @Concluir
		END--Inserta ProcesarTransferencias
		ELSE
		BEGIN--Suma ProcesarTransferencias
			SELECT TOP 1 @IDPT = ID 
				FROM ProcesarTransferencias 
				WHERE Sucursal = @Sucursal AND FormaPago = @FormaPago AND TipoCambio = @MovTipoCambio AND Fecha = @Fecha AND Concepto = @Concepto AND Estatus = @EstatusPT

			UPDATE pt SET 
				pt.ImporteAcumulado = ISNULL(pt.ImporteAcumulado,0) + ISNULL(@ImporteAcumulado,0), 
				pt.ImporteTransferencia = ISNULL(pt.ImporteTransferencia,0) + ISNULL(@ImporteAcumulado,0)
				FROM ProcesarTransferencias pt 
				WHERE pt.Id = @IDPT
		END--Suma ProcesarTransferencias
	END--AFECTAR
	IF @MovTipo = 'DIN.D' AND @Accion = 'CANCELAR'
	BEGIN--CANCELAR
		SELECT TOP 1 @IDPT = ID 
			FROM ProcesarTransferencias 
			WHERE Sucursal = @Sucursal AND FormaPago = @FormaPago AND TipoCambio = @MovTipoCambio AND Fecha = @Fecha AND Concepto = @Concepto AND Estatus = @EstatusPT
		
		UPDATE pt SET 
			pt.ImporteAcumulado = ISNULL(pt.ImporteAcumulado,0) - ISNULL(@ImporteAcumulado,0), 
			pt.ImporteTransferencia = ISNULL(pt.ImporteTransferencia,0) - ISNULL(@ImporteAcumulado,0)
			FROM ProcesarTransferencias pt 
			WHERE pt.Id = @IDPT
	END--CANCELAR
END--spProcesarTransferenciasLlenado
GO 