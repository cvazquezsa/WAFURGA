

/****** Object:  View [dbo].[vDineroCXC]    Script Date: 11/30/2016 18:36:15 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vDineroCXC]'))
DROP VIEW [dbo].[vDineroCXC]
GO



CREATE VIEW [dbo].[vDineroCXC]  
AS  
SELECT  Cxc.ID Cxc_ID, MAX(Cxc.Mov) Cxc_Mov, MAX(Cxc.MovID) Cxc_MovID, MAX(Cxc.Moneda) Cxc_Moneda, MAX(Cxc.TipoCambio) Cxc_TipoCambio, 
 MAX(Cte.Nombre) Cxc_ClienteNombre, MAX(Cte.RFC) Cxc_ClienteRFC, MAX(Cte.Tipo) Cxc_ClienteTipo,
  MAX(Cxc.ClienteMoneda) Cxc_ClienteMoneda, MAX(Cxc.ClienteTipoCambio) Cxc_ClienteTipoCambio, MAX(Cxc.Cliente) Cxc_Cliente,
  MAX(Cxc.Concepto) Cxc_Concepto, MAX(Cxc.Referencia) Cxc_Referencia, MAX(Cxc.Retencion) Cxc_Retencion,  
  MAX(MI.TipoImpuesto1) Cxc_TipoImpuesto1 ,MAX (MI.Impuesto1) Cxc_Impuesto1, SUM(MI.Importe1) Cxc_Importe1,  
  MAX(MI.TipoImpuesto2) Cxc_TipoImpuesto2 ,MAX (MI.Impuesto2) Cxc_Impuesto2, SUM(MI.Importe2) Cxc_Importe2,  
  MAX(MI.TipoImpuesto3) Cxc_TipoImpuesto3 ,MAX (MI.Impuesto3) Cxc_Impuesto3, SUM(MI.Importe3) Cxc_Importe3,  
  MAX(MI.TipoImpuesto5) Cxc_TipoImpuesto5 ,MAX (MI.Impuesto5) Cxc_Impuesto5, SUM(MI.Importe5) Cxc_Importe5  
  --MAX(MI.TipoRetencion1) Cxc_TipoRetencion1 ,MAX (MI.Retencion1) Cxc_Retencion1, SUM(ISNULL(MI.Importe1,0) * (ISNULL(MI.Retencion1,0)/100)) Cxc_ImporteRetencion1,  
  --MAX(MI.TipoRetencion2) Cxc_TipoRetencion2 ,MAX (MI.Retencion2) Cxc_Retencion2, SUM(ISNULL(MI.Importe2,0) * (ISNULL(MI.Retencion2,0)/100)) Cxc_ImporteRetencion2  
FROM Cxc  
 LEFT JOIN MovImpuesto MI ON MI.Modulo = 'CXC' AND Cxc.ID = MI.ModuloID   
 LEFT JOIN Cte ON CXC.Cliente = Cte.Cliente
GROUP BY Cxc.ID  

GO


