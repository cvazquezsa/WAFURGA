---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO 

ALTER VIEW dbo.CFDVentaDFGV33
AS
		SELECT REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,B.ID))))) + RTRIM(LTRIM(CONVERT(varchar, B.ID))) +
			   REPLICATE('0',12-LEN(RTRIM(LTRIM(CONVERT(varchar,B.RenglonID))))) + RTRIM(LTRIM(CONVERT(varchar, B.RenglonID))) +
			   REPLICATE('0',7-LEN(RTRIM(LTRIM(CONVERT(varchar,B.RenglonID))))) + RTRIM(LTRIM(CONVERT(varchar, B.RenglonID))) +
			   REPLICATE(' ',50)													OrdenExportacion,
			   B.ID																	ID,
			   B.RenglonID															Renglon,
			   B.RenglonID															RenglonSub,
			   '01010101'															ClaveProdServ,
			   C.Mov+' '+C.MovID													NoIdentificacion,
			   '1'																	Cantidad,
			   'ACT'																ClaveUnidad,
			   'Venta'																Descripcion,
			   dbo.fnValorCFDVentaV33 (C.ID, 1, null)								ValorUnitario,
			  /* CASE WHEN dbo.fnValorCFDVentaV33 (C.ID, 2, null)<0 THEN 0 ELSE 	dbo.fnValorCFDVentaV33 (C.ID, 2, null) END*/0							Descuento,
			   dbo.fnValorCFDVentaV33 (C.ID, 1, null)								Importe
		  FROM Venta A
		  JOIN VentaOrigen B
		    ON A.ID = B.ID
		  JOIN Venta C
		    ON B.OrigenID = C.ID
GO
ALTER VIEW dbo.CFDVentaFGV33
AS
			SELECT REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,A.ID))))) + RTRIM(LTRIM(CONVERT(varchar,A.ID))) +
				   REPLICATE(' ',12) +
				   REPLICATE(' ',7) +
				   REPLICATE(' ',50)															OrdenExportacion,
				   A.ID																			ID,
				   dbo.fnSerieConsecutivo(A.MovID)												VentaSerie,
				   dbo.fnFolioConsecutivo(A.MovID)												VentaFolio,
				   CONVERT(datetime,A.FechaRegistro, 126)										VentaFechaRegistro,
				   (SELECT FormaPago FROM dbo.fnNotasFacturaCFD33(A.ID, NULL, NULL))			VentaFormaPago,
				   SUM(dbo.fnValorCFDVentaV33 (B.OrigenID, 1, null))							VentaSubTotal,
				   /*SUM(dbo.fnValorCFDVentaV33 (B.OrigenID, 2, null)),*/0							VentaDescuentoImporte,
				   SATMon.Clave																	VentaMoneda,
				   A.TipoCambio																	VentaTipoCambio,
				   SUM((dbo.fnValorCFDVentaV33 (B.OrigenID, 1, null) /*-
                        dbo.fnValorCFDVentaV33 (B.OrigenID, 2, null)*/)) +
                                         ISNULL(Imp.ImporteImpuesto,0)                          VentaTotal,
				   'I'																			TipoComprobante,
				   'PUE'																		MetodoPago,
				   EmpresaCP.ClaveCP															LugarExpedicionEmpresaV33,
				   SucCP.ClaveCP																LugarExpedicionSucursalV33,
				   
				   REPLACE(Empresa.Nombre,'.','')												EmpresaNombre,
				   Empresa.RFC																	EmpresaRFC,
				   Empresa.FiscalRegimen														EmpresaRegimenFiscal,
				   REPLACE(Sucursal.Nombre,'.','')												SucursalNombre,
				   Sucursal.RFC																	SucursalRFC,
				   Sucursal.FiscalRegimen														SucursalRegimenFiscal,
				   
				   'XAXX010101000'																ReceptorRFC,
				   'P01'																		UsoCFDI
			  FROM Venta A
			  JOIN VentaOrigen B ON A.ID = B.ID
			  JOIN Mon ON A.Moneda = Mon.Moneda
			  JOIN Empresa ON A.Empresa = Empresa.Empresa
			  JOIN Sucursal ON A.Sucursal = Sucursal.Sucursal
		 LEFT JOIN SATMoneda SATMon ON Mon.Clave = SATMon.Clave
		 LEFT JOIN SATCatCP EmpresaCP ON Empresa.CodigoPostal = EmpresaCP.ClaveCP
		 LEFT JOIN SATCatCP SucCP ON Sucursal.CodigoPostal = SucCP.ClaveCP
         LEFT JOIN (SELECT ID, SUM(ROUND(Importe,2)) ImporteImpuesto FROM CFDVentaDImpuestoFGV33 GROUP BY ID) Imp ON A.ID = Imp.ID
		  GROUP BY A.ID, A.MovID, A.FechaRegistro, SATMon.Clave, A.TipoCambio, EmpresaCP.ClaveCP, SucCP.ClaveCP, Empresa.Nombre, Empresa.RFC,
				   Empresa.FiscalRegimen, Sucursal.Nombre, Sucursal.RFC, Sucursal.FiscalRegimen, Imp.ImporteImpuesto

