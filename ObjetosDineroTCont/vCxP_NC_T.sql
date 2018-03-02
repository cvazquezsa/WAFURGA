/****** Object:  View [dbo].[vCxP_NC_T]    Script Date: 10/06/2015 12:56:27 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vCxP_NC_T]'))
DROP VIEW [dbo].[vCxP_NC_T]
GO



CREATE VIEW [dbo].[vCxP_NC_T]
AS
SELECT dbo.Cxp.ID, dbo.Cxp.Empresa, dbo.Cxp.Mov, dbo.Cxp.FechaEmision, dbo.Cxp.MovID, dbo.CxpD.Aplica, dbo.CxpD.AplicaID, 
			--CASE WHEN round(O.Importe,2) <= dbo.CxpD.Importe THEN dbo.CxpD.Importe ELSE O.Importe END AS Importe,
			dbo.CxpD.Importe ImporteD,  dbo.CxpD.Importe * dbo.Cxp.IVAFiscal as ImporteIVA,
			
            dbo.Cxp.TipoCambio
            
			--CASE WHEN round(O.Importe,2) <= dbo.CxpD.Importe THEN dbo.Cxp.IvaFiscal ELSE O.IvaFiscal END AS IvaFiscal,
			--dbo.Cxp.IEPSFiscal
FROM         dbo.Cxp INNER JOIN
                      dbo.CxpD ON dbo.Cxp.ID = dbo.CxpD.ID
			 JOIN dbo.Cxp O ON Cxp.Empresa = O.Empresa AND Cxp.OrigenTipo = 'CXP' AND Cxp.Origen = O.Mov AND Cxp.OrigenID = O.MovID
WHERE     dbo.Cxp.Mov = 'Aplicacion'
  AND Cxp.Estatus = 'CONCLUIDO'
  --and cxp.ID = 9424

GO


