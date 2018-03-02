

/****** Object:  View [dbo].[vDineroVenta]    Script Date: 11/30/2016 18:35:26 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vDineroVenta]'))
DROP VIEW [dbo].[vDineroVenta]
GO




CREATE VIEW [dbo].[vDineroVenta]  
AS  
SELECT  V.ID Vtas_ID, MAX(V.Mov) Vtas_Mov, MAX(V.MovID) Vtas_MovID, MAX(V.Moneda) Vtas_Moneda, MAX(V.TipoCambio) Vtas_TipoCambio, MAX(V.Referencia) Vtas_Referencia, MAX(V.Retencion) Vtas_Retencion,  
MAX(V.Cliente) Vtas_Cliente, MAX(Cte.Nombre) Vtas_ClienteNombre, MAX(Cte.RFC) Vtas_ClienteRFC, MAX(Cte.Tipo) Vtas_ClienteTipo, 
  MAX(MI.TipoImpuesto1) Vtas_TipoImpuesto1 ,MAX (MI.Impuesto1) Vtas_Impuesto1, SUM(MI.Importe1) Vtas_Importe1,  
  MAX(MI.TipoImpuesto2) Vtas_TipoImpuesto2 ,MAX (MI.Impuesto2) Vtas_Impuesto2, SUM(MI.Importe2) Vtas_Importe2,  
  MAX(MI.TipoImpuesto3) Vtas_TipoImpuesto3 ,MAX (MI.Impuesto3) Vtas_Impuesto3, SUM(MI.Importe3) Vtas_Importe3,  
  MAX(MI.TipoImpuesto5) Vtas_TipoImpuesto5 ,MAX (MI.Impuesto5) Vtas_Impuesto5, SUM(MI.Importe5) Vtas_Importe5,
  MAX(ISNULL(V.Condicion,'Contado')) Vtas_Condicion, MAX(V.Importe + ISNULL(V.Impuestos,0) - ISNULL(V.Retencion,0)) Vtas_ImporteTotal, MAX(V.CostoTotal) AS Vtas_CostoFactura,
  SUM(CASE WHEN ROUND(MI.Impuesto1,0) IN (10,11) THEN MI.Importe1 ELSE 0.0 END) Vtas_IVA_F,
  SUM(CASE WHEN ROUND(MI.Impuesto1,0) IN (15,16) THEN MI.Importe1 ELSE 0.0 END) Vtas_IVA_C,
  SUM(CASE WHEN ROUND(MI.Impuesto1,0) IN (10,11) THEN MI.SubTotal ELSE 0.0 END) Vtas_BASE_F,
--  SUM(CASE WHEN ROUND(MI.TipoImpuesto1,0) IN (10) THEN MI.SubTotal ELSE 0.0 END) Vtas_BASE_F10,
  SUM(CASE WHEN ROUND(MI.Impuesto1,0) IN (16) THEN MI.SubTotal ELSE 0.0 END) Vtas_BASE_C,
  SUM(CASE WHEN ROUND(MI.Impuesto1,0) IN (15) THEN MI.SubTotal ELSE 0.0 END) Vtas_BASE_C15,
  SUM(CASE WHEN ROUND(MI.Impuesto1,0)  =   0     THEN MI.SubTotal ELSE 0.0 END) Vtas_BASE_0,
  MAX(A.Nombre) AS Vtas_AgenteNombre
  --MAX(MI.TipoRetencion1) Vtas_TipoRetencion1 ,MAX (MI.Retencion1) Vtas_Retencion1, SUM(ISNULL(MI.Importe1,0) * (ISNULL(MI.Retencion1,0)/100)) Vtas_ImporteRetencion1,  
  --MAX(MI.TipoRetencion2) Vtas_TipoRetencion2 ,MAX (MI.Retencion2) Vtas_Retencion2, SUM(ISNULL(MI.Importe2,0) * (ISNULL(MI.Retencion2,0)/100)) Vtas_ImporteRetencion2  
FROM Venta       V  
 LEFT JOIN MovImpuesto MI ON MI.Modulo = 'VTAS' AND V.ID = MI.ModuloID   
 JOIN Cte ON V.Cliente = Cte.Cliente
 LEFT JOIN Agente A ON A.Agente = V.Agente
GROUP BY V.ID  

GO


