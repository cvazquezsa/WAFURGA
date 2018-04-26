IF NOT EXISTS (SELECT * FROM SysObjects WHERE Name='ProcesarTransferencias' AND Type='U')
	CREATE TABLE ProcesarTransferencias (
		ID	int IDENTITY,
		Sucursal	int,
		FormaPago varchar(50),
		TipoCambio float,
		ImporteAcumulado	money,
		ImporteTransferencia	money,
		Fecha	datetime,
		FechaTrasnferencia	datetime,
		Concepto varchar(20),
		Estatus	varchar(20),
		Concluir	bit
		)
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE Name='ProcesarTransferenciasFP' AND Type='U')
	CREATE TABLE ProcesarTransferenciasFP (
		Sucursal	int,
		FormaPago varchar(50) NOT NULL,
		Moneda varchar(10) NOT NULL,
		CuentaDinero	varchar(20) NOT NULL,
		CuentaDineroDestino	varchar(20) NOT NULL
		CONSTRAINT PK_ProcesarTransferenciasFP PRIMARY KEY (Sucursal, FormaPago, Moneda)
		)
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE Name='ProcesarTransferenciasSucCta' AND Type='U')
	CREATE TABLE ProcesarTransferenciasSucCta (
		Sucursal	int,
		Moneda varchar(10),
		CuentaDinero	varchar(20)
		CONSTRAINT PK_ProcesarTransferenciasSucCta PRIMARY KEY (Sucursal,Moneda,CuentaDinero)
		)
GO
--DELETE ProcesarTransferencias
INSERT INTO ProcesarTransferencias (Sucursal,FormaPago,TipoCambio,ImporteAcumulado,ImporteTransferencia,Fecha,FechaTrasnferencia,Concepto,Estatus,Concluir)
	SELECT 2, 'Efectivo Pesos',1.0, 2000,2000,'20180110','20180110', 'Operación', 'PENDIENTE',NULL
	INSERT INTO ProcesarTransferencias (Sucursal,FormaPago,TipoCambio,ImporteAcumulado,ImporteTransferencia,Fecha,FechaTrasnferencia,Concepto,Estatus,Concluir)
	SELECT 2, 'BBVA Debito',1.0, 2000,2000,'20180110','20180110', 'Operación', 'PENDIENTE',NULL
--SELECT * FROM ProcesarTransferenciasFP