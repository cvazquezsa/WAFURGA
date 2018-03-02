
/****** Object:  View [dbo].[vCompraGastosDiversos]    Script Date: 10/06/2015 13:52:16 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vCompraGastosDiversos]'))
DROP VIEW [dbo].[vCompraGastosDiversos]
GO

CREATE VIEW [dbo].[vCompraGastosDiversos]
AS
SELECT     CGD.ID AS GD_ID, CGD.Concepto AS GD_Concepto, CGD.Acreedor AS GD_Acreedor, P.Nombre AS GD_AcreedorNombre, 
                      P.RFC AS GD_AcreedorRFC, P.Tipo AS GD_AcreedorTipo, CGD.Importe AS GD_Importe, CGD.Moneda AS GD_Moneda, 
                      CGD.TipoCambio AS GD_TipoCambio, CGD.Prorrateo AS GD_Prorrateo, CGD.FechaEmision AS GD_FechaEmision, 
                      CGD.Condicion AS GD_Condicion, CGD.Referencia AS GD_Referencia, CGD.Retencion AS GD_Retencion, CGD.Retencion2 AS GD_Retencion2, 
                      CGD.Retencion3 AS GD_Retencion3, CGD.Impuestos AS GD_Impuestos
FROM         dbo.CompraGastoDiverso AS CGD INNER JOIN
                      dbo.Prov AS P ON CGD.Acreedor = P.Proveedor

GO


