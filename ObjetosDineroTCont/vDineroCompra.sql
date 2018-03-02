/****** Object:  View [dbo].[vDineroCompra]    Script Date: 10/06/2015 12:20:16 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vDineroCompra]'))
DROP VIEW [dbo].[vDineroCompra]
GO


CREATE VIEW [dbo].[vDineroCompra]
AS
SELECT  C.ID Coms_ID, MAX(C.Mov) Coms_Mov, MAX(C.MovID) Coms_MovID, MAX(C.Moneda) Coms_Moneda, MAX(C.Referencia) Coms_Referencia,
		CONVERT(VARCHAR(20),NULL) Coms_FacturaCompra, CONVERT(VARCHAR(20),NULL) Coms_FechaFactura,
		MAX(C.Importe+ISNULL(C.Impuestos,0)) Coms_ImpTotal,
		ROUND(SUM(CASE WHEN D.Impuesto2 = 20 THEN ROUND(((D.Cantidad*D.Costo)-ISNULL((D.DescuentoLinea/100)*(D.Cantidad*D.Costo),0))*(D.Impuesto2/100),2) ELSE 0 END),2) Coms_IEPS_20,
		ROUND(SUM(CASE WHEN D.Impuesto2 = 25 THEN ROUND(((D.Cantidad*D.Costo)-ISNULL((D.DescuentoLinea/100)*(D.Cantidad*D.Costo),0))*(D.Impuesto2/100),2) ELSE 0 END),2) Coms_IEPS_25,
		ROUND(SUM(CASE WHEN D.Impuesto2 = 26.5 THEN ROUND(((D.Cantidad*D.Costo)-ISNULL((D.DescuentoLinea/100)*(D.Cantidad*D.Costo),0))*(D.Impuesto2/100),2) ELSE 0 END),2) Coms_IEPS_26_5,
		ROUND(SUM(CASE WHEN D.Impuesto2 = 30 THEN ROUND(((D.Cantidad*D.Costo)-ISNULL((D.DescuentoLinea/100)*(D.Cantidad*D.Costo),0))*(D.Impuesto2/100),2) ELSE 0 END),2) Coms_IEPS_30,
		ROUND(SUM(CASE WHEN D.Impuesto2 = 50 THEN ROUND(((D.Cantidad*D.Costo)-ISNULL((D.DescuentoLinea/100)*(D.Cantidad*D.Costo),0))*(D.Impuesto2/100),2) ELSE 0 END),2) Coms_IEPS_50,
		ROUND(SUM(CASE WHEN D.Impuesto2 = 53 THEN ROUND(((D.Cantidad*D.Costo)-ISNULL((D.DescuentoLinea/100)*(D.Cantidad*D.Costo),0))*(D.Impuesto2/100),2) ELSE 0 END),2) Coms_IEPS_53,
		ROUND(SUM(CASE WHEN D.Impuesto1 IN (10,11) THEN ROUND(((D.Cantidad*D.Costo)-ISNULL((D.DescuentoLinea/100)*(D.Cantidad*D.Costo),0)+(((D.Cantidad*D.Costo)-ISNULL(D.DescuentoImporte,0))*(ISNULL(D.Impuesto2,0)/100)))*(ISNULL(D.Impuesto1,0)/100) * C.TipoCambio,2) ELSE 0 END),2) Coms_IVA_11,
		ROUND(SUM(CASE WHEN D.Impuesto1 IN (15,16) THEN ROUND(((D.Cantidad*D.Costo)-ISNULL((D.DescuentoLinea/100)*(D.Cantidad*D.Costo),0)+(((D.Cantidad*D.Costo)-ISNULL(D.DescuentoImporte,0))*(ISNULL(D.Impuesto2,0)/100)))*(ISNULL(D.Impuesto1,0)/100) * C.TipoCambio,2) ELSE 0 END),2) Coms_IVA_16,
		ROUND(SUM(CASE WHEN D.Impuesto1 IN (10,11) THEN ROUND(((D.Cantidad*D.Costo)-ISNULL((D.DescuentoLinea/100)*(D.Cantidad*D.Costo),0)) * C.TipoCambio,2) ELSE 0 END),2) Coms_Base_10_11,
		ROUND(SUM(CASE WHEN D.Impuesto1 IN (15,16) THEN ROUND(((D.Cantidad*D.Costo)-ISNULL((D.DescuentoLinea/100)*(D.Cantidad*D.Costo),0)) * C.TipoCambio,2) ELSE 0 END),2) Coms_BASE_15_16,
		ROUND(SUM(CASE WHEN D.Impuesto1 = 0 THEN ROUND(((D.Cantidad*D.Costo)-ISNULL(D.DescuentoImporte,0)) * C.TipoCambio,2) ELSE 0 END),2) Coms_BASE_Cero,
		CASE WHEN MAX(C.ZonaImpuesto) LIKE '%FRONTERA%' THEN 'F'
			 WHEN MAX(C.ZonaImpuesto) LIKE '%NACIONAL%' OR MAX(C.ZonaImpuesto) LIKE '%CENTRO%' THEN 'C'
			 ELSE '0' END		Coms_ZonaImp,
		MAX(C.TipoCambio)		Coms_TipoCambio,
		MAX(P.Proveedor)		Coms_Proveedor,
		MAX(P.Nombre)			Coms_Prov_Nombre,
		MAX(P.Tipo)				Coms_Prov_Tipo,
		MAX(P.Cuenta)			Coms_Prov_Cuenta,
		MAX(P.CuentaRetencion)	Coms_Prov_CuentaRetencion,
		CONVERT(VARCHAR(20),NULL)			Coms_Prov_Cuenta2,
		CONVERT(VARCHAR(20),NULL)			Coms_Prov_Cuenta3,
		CONVERT(VARCHAR(20),NULL)			Coms_Prov_Cuenta4,
		MAX(P.RFC)				Coms_Prov_RFC,
		CASE WHEN MAX(P.ZonaImpuesto) LIKE '%FRONTERA%' THEN 'F'
			 WHEN MAX(P.ZonaImpuesto) LIKE '%NACIONAL%' OR MAX(P.ZonaImpuesto) LIKE '%CENTRO%' THEN 'C'
			 ELSE '0' END		Coms_Prov_ZonaImp,
		MAX(NC.ImporteD)		NC_ImporteD,
		MAX(NC.ImporteIVA)		NC_ImporteIVA,
		ISNULL(MAX(R.ImporteD),0) NC_Redondeo
FROM Compra       C
	 JOIN CompraD D ON D.ID = C.ID
	 JOIN Prov    P ON C.Proveedor = P.Proveedor
	 LEFT JOIN vCxP_NC_T NC ON C.Empresa = NC.Empresa AND NC.Aplica = C.Mov AND NC.AplicaID = C.MovID
	 LEFT JOIN vCxP_NC_T R  ON R.ID = NC.ID AND NC.Aplica = 'REDONDEO'
GROUP BY C.ID

GO


