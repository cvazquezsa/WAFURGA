
/****** Object:  View [dbo].[vDineroCXP]    Script Date: 11/30/2016 18:37:00 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vDineroCXP]'))
DROP VIEW [dbo].[vDineroCXP]
GO




CREATE VIEW [dbo].[vDineroCXP]  
AS  
SELECT  Cxp.ID Cxp_ID, MAX(Cxp.Mov) Cxp_Mov, MAX(Cxp.MovID) Cxp_MovID, MAX(Cxp.Moneda) Cxp_Moneda, MAX(Cxp.TipoCambio) Cxp_TipoCambio, 
  MAX(Cxp.Referencia) Cxp_Referencia, MAX(Cxp.Retencion) Cxp_Retencion, MAX(CXP.Concepto) CXP_Concepto,
  MAX(P.Proveedor) Cxp_Proveedor, MAX(P.Nombre) Cxp_ProveedorNombre, MAX(P.RFC) Cxp_ProveedorRFC, MAX(P.Tipo) Cxp_ProveedorTipo,
  MAX(Cxp.Origen) Cxp_Origen, MAX(Cxp.OrigenID) Cxp_OrigenID, MAX(Cxp.ProveedorMoneda) Cxp_ProveedorMoneda, MAX(Cxp.ProveedorTipoCambio) Cxp_ProveedorTipoCambio,
  MAX(MI.TipoImpuesto1) Cxp_TipoImpuesto1 ,MAX (MI.Impuesto1) Cxp_Impuesto1, SUM(MI.Importe1) Cxp_Importe1,  
  MAX(MI.TipoImpuesto2) Cxp_TipoImpuesto2 ,MAX (MI.Impuesto2) Cxp_Impuesto2, SUM(MI.Importe2) Cxp_Importe2,  
  MAX(MI.TipoImpuesto3) Cxp_TipoImpuesto3 ,MAX (MI.Impuesto3) Cxp_Impuesto3, SUM(MI.Importe3) Cxp_Importe3,  
  MAX(MI.TipoImpuesto5) Cxp_TipoImpuesto5 ,MAX (MI.Impuesto5) Cxp_Impuesto5, SUM(MI.Importe5) Cxp_Importe5  
  --MAX(MI.TipoRetencion1) Cxp_TipoRetencion1 ,MAX (MI.Retencion1) Cxp_Retencion1, SUM(ISNULL(MI.Importe1,0) * (ISNULL(MI.Retencion1,0)/100)) Cxp_ImporteRetencion1,  
  --MAX(MI.TipoRetencion2) Cxp_TipoRetencion2 ,MAX (MI.Retencion2) Cxp_Retencion2, SUM(ISNULL(MI.Importe2,0) * (ISNULL(MI.Retencion2,0)/100)) Cxp_ImporteRetencion2  
FROM Cxp
 LEFT JOIN MovImpuesto MI ON MI.Modulo = 'CXP' AND Cxp.ID = MI.ModuloID   
 LEFT JOIN Prov P ON Cxp.Proveedor = P.Proveedor
GROUP BY Cxp.ID  

GO


