
/****** Object:  View [dbo].[vDineroGasto]    Script Date: 11/30/2016 18:34:14 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vDineroGasto]'))
DROP VIEW [dbo].[vDineroGasto]
GO



CREATE VIEW [dbo].[vDineroGasto]
AS
SELECT  G.ID Gas_ID, MAX(G.Mov) Gas_Mov, MAX(G.MovID) Gas_MovID, MAX(G.Moneda) Gas_Moneda, --MAX(G.Referencia) Gas_Referencia,
		MAX(G.Importe) Gas_Importe,
		MAX(G.Impuestos) Gas_Impuestos,
		MAX(G.Retencion) Gas_Retencion,
		SUM(D.Retencion) Gas_RetencionISR,
		SUM(D.Retencion2) Gas_RetencionIVA,
		SUM(D.Retencion3) Gas_Retencion3,
		MAX(D.Concepto) Gas_Concepto,
		MAX(D.TipoImpuesto1) Gas_TipoImpuesto1,
		SUM(CASE WHEN D.Impuesto1 IN (10,11) THEN D.Impuestos * G.TipoCambio ELSE 0 END) Gas_IVA_11,
		SUM(CASE WHEN D.Impuesto1 IN (15,16) THEN D.Impuestos * G.TipoCambio ELSE 0 END) Gas_IVA_16,
--		CASE WHEN MAX(G.ZonaImpuesto) LIKE '%FRONTERA%' THEN 'F'
--			 WHEN MAX(G.ZonaImpuesto) LIKE '%NACIONAL%' OR MAX(C.ZonaImpuesto) LIKE '%CENTRO%' THEN 'C'
--			 ELSE '0' END		Gas_ZonaImp,
		MAX(G.TipoCambio)		Gas_TipoCambio,
		MAX(P.Proveedor)		Gas_Acreedor,
		MAX(P.Nombre)			Gas_Acre_Nombre,
		MAX(P.Tipo)				Gas_Acre_Tipo,
		MAX(P.Cuenta)			Gas_Acre_Cuenta,
		MAX(P.CuentaRetencion)	Gas_Acre_CuentaRetencion,
		CONVERT(VARCHAR(20),NULL)			Gas_Acre_Cuenta2,
		CONVERT(VARCHAR(20),NULL)			Gas_Acre_Cuenta3,
		CONVERT(VARCHAR(20),NULL)			Gas_Acre_Cuenta4,
		MAX(P.RFC)				Gas_Acre_RFC,
		CASE WHEN MAX(P.ZonaImpuesto) LIKE '%FRONTERA%' THEN 'F'
			 WHEN MAX(P.ZonaImpuesto) LIKE '%NACIONAL%' OR MAX(P.ZonaImpuesto) LIKE '%CENTRO%' THEN 'C'
			 ELSE '0' END		Gas_Acre_ZonaImp,
		MAX(G.OrigenTipo)		Gas_OrigenTipo,
		MAX(NC.ImporteD)		Gas_NC_ImporteD,
		ISNULL(MAX(R.ImporteD),0) Gas_NC_Redondeo,
		MIN(N.TipoOperacion) Gas_TipoOperacion,
		SUM(CASE WHEN D.Concepto = 'Fletes y Acarreos' THEN D.Importe + ISNULL(D.Impuestos,0) + ISNULL(D.Impuesto2,0) + ISNULL(D.Impuesto3,0)- (ISNULL(D.Retencion,0) + ISNULL(D.Retencion2,0) + ISNULL(D.Retencion3,0))  ELSE 0 END) Gas_Fletes
FROM Gasto         G
	 JOIN GastoD   D ON D.ID = G.ID
	 LEFT JOIN Concepto N ON N.Concepto = D.Concepto AND N.Modulo = 'GAS'
	 JOIN Prov     P ON G.Acreedor = P.Proveedor
	 LEFT JOIN vCxP_NC_T NC ON G.Empresa = NC.Empresa AND NC.Aplica = G.Mov AND NC.AplicaID = G.MovID
	 LEFT JOIN vCxP_NC_T R  ON R.ID = NC.ID AND NC.Aplica IN ('REDONDEO')
GROUP BY G.ID

GO


