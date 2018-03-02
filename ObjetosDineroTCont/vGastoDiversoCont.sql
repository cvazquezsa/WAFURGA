/****** Object:  View [dbo].[vGastoDiversoCont]    Script Date: 10/06/2015 12:01:14 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vGastoDiversoCont]'))
DROP VIEW [dbo].[vGastoDiversoCont]
GO


CREATE VIEW [dbo].[vGastoDiversoCont]
AS
SELECT GD.ID, GD.Concepto, GD.Acreedor, GD.Importe, 
		UPPER(SUBSTRING(GD.Moneda,1,1))+LOWER(SUBSTRING(GD.Moneda,2,20)) Moneda, 
		GD.TipoCambio, GD.Prorrateo, GD.FechaEmision, GD.Impuestos * ISNULL(GD.TipoCambio,1) Impuestos,
		CASE WHEN Moneda =  'Pesos' THEN GD.Importe ELSE GD.Importe*GD.TipoCambio END ImportePesos,
		CASE WHEN Moneda =  'Pesos' THEN GD.Importe ELSE GD.Importe END ProvPesos,
		CASE WHEN Moneda <> 'Pesos' THEN GD.Importe ELSE GD.Importe END ProvDolares,
		--ISNULL(Z.Porcentaje,0) PorcImpuestos,
		ISNULL(C.Impuestos,0) PorcImpuestos,
		C.Cuenta, P.Nombre NombreAcreedor, 1 as Registros, --(SELECT COUNT(CompraD.ID) FROM CompraD WHERE CompraD.ID = GD.ID) Registros,
		P.Tipo TipoProveedor,
		GD.Retencion  Retencion_ISR,
		GD.Retencion2 Retencion_IVA,
		GD.Retencion3 Retencion_3,
		GD.Importe + ISNULL(GD.Impuestos,0) - (ISNULL(GD.Retencion,0) + ISNULL(GD.Retencion2,0) + ISNULL(GD.Retencion3,0)) ImporteNeto,
		GD.Referencia
FROM CompraGastoDiverso GD
		 JOIN Concepto C ON GD.Concepto    = C.Concepto AND C.Modulo = 'COMSG'
		 JOIN Prov     P ON GD.Acreedor    = P.Proveedor
	LEFT JOIN ZonaImp  Z ON P.ZonaImpuesto = Z.Zona

GO


