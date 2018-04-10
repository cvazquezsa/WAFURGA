SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
IF EXISTS(SELECT * FROM SysObjects WHERE Name='spWFGWebServiceHistorialCredito' AND Type='P')
	DROP PROCEDURE spWFGWebServiceHistorialCredito
GO
CREATE PROCEDURE spWFGWebServiceHistorialCredito
	@Cliente	varchar(20),
	@Empresa	varchar(5),
	@LC			varchar(20)
AS
BEGIN
	DECLARE
		--@Cliente		varchar(20),
		@Sucursal		int,
		@Referencia		varchar(255),
		@FechaEmision	datetime,
		@Vencimiento	datetime,
		@Importe		money,
		@Impuestos		money,
		@Saldo			money,
		@CteNombre		varchar(255),
		@ImporteLC		money,
		@Disponible		money,
		@XMLDetalle		xml,
		@XMLEncabezado	xml,
		@XMLTitulo		xml,
		@Ok				int,
		@OkRef			varchar(255)

	DECLARE @HistorialCreditoPaso TABLE
		(
			ID			int,
			Orden		int,
			Sucursal	int,
			Cliente		varchar(20),
			Referencia	varchar(255),
			FechaEmision	datetime,
			Vencimiento		datetime,
			Importe			money,
			Impuestos		money,
			Acreedor		bit
		)
	DECLARE @HistorialCredito TABLE
		(
			--ID			int,
			--Orden		int,
			Sucursal	int,
			--Cliente		varchar(20),
			Referencia	varchar(255),
			FechaEmision	datetime,
			Vencimiento		datetime,
			Importe			money,
			Impuestos		money,
			Saldo			money
		)
	/**** V A L I D A R ****/
	IF NOT EXISTS (SELECT * FROM Empresa WHERE Empresa=@Empresa) AND ISNULL(@Ok,0)=0	SELECT @Ok=26070
	IF NOT EXISTS (SELECT * FROM Cte WHERE Cliente=@Cliente) AND ISNULL(@Ok,0)=0	SELECT @Ok=26060
	IF NOT EXISTS (SELECT * FROM Lc WHERE LineaCredito=@LC AND Acreditado=@Cliente) AND ISNULL(@Ok,0)=0	SELECT @Ok=20073
	
	--SELECT * fROM MensajeLista WHERE Descripcion like '%Línea%' 
	
	IF ISNULL(@Ok,0)=0
	BEGIN--@Ok=0
		INSERT INTO @HistorialCreditoPaso
			SELECT
			c.ID,
			1,
			c.Sucursal,
			c.Cliente,
			ISNULL('Nota a Credito'+' '+v.FolioSBX+' '+RIGHT(c.Referencia,LEN(c.Referencia)-CHARINDEX('(',c.Referencia)+1),RTRIM(LTRIM(v.Mov))+' '+v.MovID) Referencia,
			v.FechaEmision,
			c.Vencimiento,
			c.Importe,
			c.Impuestos,
			0 
			FROM Cxc c
				JOIN Venta v ON v.Mov=c.Origen AND v.MovID=c.OrigenID
				JOIN Cxc c2 ON c2.Mov=c.Origen AND c2.MovID=c.OrigenID
				WHERE c.Mov IN ('Amortizacion        ') AND c.Estatus IN ('CONCLUIDO','PENDIENTE') AND c.Cliente=@Cliente 
					AND c.Empresa=@Empresa AND c.LineaCredito=@LC
			UNION ALL

			--SELECT 
			--	c.ID,2,c.Sucursal,c.Cliente,ISNULL(c.Referencia,c.Mov),c.FechaEmision,c.Vencimiento, 
			--	SUM(ISNULL(cd.Importe,0)+ISNULL(cd.InteresesOrdinarios,0)+ISNULL(cd.InteresesMoratorios,0)), 
			--	SUM(ISNULL(cd.InteresesOrdinariosIVA,0)+ISNULL(cd.InteresesMoratoriosIVA,0)),1 
			--	FROM Cxc c 
			--		JOIN CxcD cd ON c.ID=cd.ID
			--		JOIN Cxc c2 ON cd.Aplica=c2.Mov AND cd.AplicaID=c2.MovID
			--	WHERE c.Mov IN ('Abono Credito') AND c.Estatus IN ('CONCLUIDO') AND c.Cliente=@Cliente AND c.Empresa=@Empresa 
			--		AND c2.LineaCredito=@LC
			--	GROUP BY c.ID,c.Sucursal,c.Cliente,c.FechaEmision,c.Vencimiento,c.Referencia,c.Mov
			--UNION ALL

			SELECT 
				c.ID,
				4,
				c.Sucursal,
				c2.Cliente,
				CONCAT('Intereses Nota a Credito ',RTRIM(LTRIM(c.Mov)),' ', c.MovID),
				c.FechaEmision,
				c.Vencimiento,
				ISNULL(cd.InteresesMoratorios,0),
				ISNULL(cd.InteresesMoratoriosIVA,0),
				0
				FROM Cxc c
					JOIN CxcD cd ON c.ID=cd.ID
					JOIN Cxc c2 ON cd.Aplica=c2.Mov AND cd.AplicaID=c2.MovID 
					JOIN Venta v ON c2.Origen=v.Mov AND c2.OrigenID=v.MovID
				WHERE c.Mov='Intereses Vencidos' AND c.Estatus IN ('CONCLUIDO') AND c2.Cliente=@Cliente AND c.Empresa=@Empresa
					AND c2.LineaCredito=@LC
				--GROUP BY c.Sucursal,c2.Cliente,c2.Mov,c2.MovID
			UNION ALL

			SELECT 
				c.ID,5,c.Sucursal,c.Cliente,CONCAT(c.Mov,' ',c.MovId),c.FechaEmision,c.Vencimiento, 
				c.Importe, 
				c.Impuestos,0 
				FROM Cxc c 
				WHERE c.Mov IN ('Cargo Moratorio') AND c.Estatus IN ('PENDIENTE','CONCLUIDO') AND c.Cliente=@Cliente AND c.Empresa=@Empresa 

	
			UNION ALL

			SELECT 
				c2.ID,
				3,
				c.Sucursal,
				c2.Cliente,
				CONCAT('Intereses ',v.FolioSBX),
				v.FechaEmision,
				c.Vencimiento,
				cd.InteresesOrdinarios,
				cd.InteresesOrdinariosIVA,
				0
				FROM Cxc c
					JOIN CxcD cd ON c.ID=cd.ID
					JOIN Cxc c2 ON cd.Aplica=c2.Mov AND cd.AplicaID=c2.MovID 
					JOIN Venta v ON c2.Origen=v.Mov AND c2.OrigenID=v.MovID
				WHERE c.Mov='Intereses' AND c.Estatus IN ('CONCLUIDO') AND c2.Cliente=@Cliente 
					AND NOT (cd.InteresesOrdinarios=0 AND cd.InteresesOrdinariosIVA=0) AND c.Empresa=@Empresa AND c2.LineaCredito=@LC
				--GROUP BY c.Sucursal,c2.Cliente,c2.Mov,c2.MovID,c2.ID

		
		
		
		DECLARE crWFGEdoCuenta CURSOR FAST_FORWARD FOR
			SELECT 
				Sucursal,Referencia,FechaEmision,Vencimiento,
				CASE 
					WHEN Acreedor=0 THEN Importe
					WHEN Acreedor=1 THEN -Importe
				END,
				CASE 
					WHEN Acreedor=0 THEN  Impuestos
					WHEN Acreedor=1 THEN -Impuestos
				END
				FROM @HistorialCreditoPaso 
				ORDER BY ID,FechaEmision, Orden

		OPEN crWFGEdoCuenta
		FETCH NEXT FROM crWFGEdoCuenta INTO
			@Sucursal,@Referencia,@FechaEmision,@Vencimiento,@Importe,@Impuestos

		WHILE @@FETCH_STATUS=0
		BEGIN
			SET @Saldo=@Impuestos+@Importe+ISNULL(@Saldo,0)
			INSERT INTO @HistorialCredito
				SELECT @Sucursal,@Referencia,@FechaEmision,@Vencimiento,@Importe,@Impuestos,@Saldo

			FETCH NEXT FROM crWFGEdoCuenta INTO
			@Sucursal,@Referencia,@FechaEmision,@Vencimiento,@Importe,@Impuestos
		END
		CLOSE crWFGEdoCuenta
		DEALLOCATE crWFGEdoCuenta
		--SELECT * fROM @HistorialCreditoPaso
		SELECT @CteNombre=Nombre FROM Cte WHERE Cliente=@Cliente
		SELECT @ImporteLC=Importe FROm LC WHERE LineaCredito=@LC AND Acreditado=@Cliente
		SELECT @Disponible=@ImporteLC-@Saldo
		--SELECT @Cliente,@CteNombre, @ImporteLC,@Saldo,@Disponible
	
		SELECT @XMLDetalle=(
			SELECT * FROM @HistorialCredito FOR XML RAW('Detalle'))
		SELECT @XMLEncabezado=(
			SELECT @Cliente Cliente,@CteNombre Nombre,@ImporteLC LineaCredito,@Saldo Saldo,@Disponible Disponible,@XMLDetalle
				FOR XML RAW('Cliente'))
	END--@Ok=0
	ELSE
	BEGIN--@Ok<>0
		SELECT @OkRef=Descripcion FROM MensajeLista WHERE Mensaje=@Ok
		
		SELECT @XMLEncabezado=(
			SELECT	@Ok Ok,	@OkRef OkRef
				FOR XML RAW ('Error'))
	END--@Ok<>0
	
	SELECT @XMLTitulo=(
					SELECT	'Intelisis' Sistema, 'Historial de Credito' Contenido, 'WebService' Referencia, 'HistorialCredito' SubReferencia,@XMLEncabezado
						FOR XML RAW ('Intelisis'))
	INSERT INTO WFGHistSpWebServiceHistCredito SELECT @Cliente,@Empresa,@LC,GETDATE(),@XMLTitulo
	SELECT @XMLTitulo
END
GO
EXEC spWFGWebServiceHistorialCredito 'C00007', 'E001', 'C00007'