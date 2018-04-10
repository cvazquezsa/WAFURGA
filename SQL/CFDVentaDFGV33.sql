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
		    ON B.OrigenID = C.ID AND dbo.fnValorCFDVentaV33 (C.ID, 1, null)>0
GO
--SELECT * FROM CFDVentaDFGV33 WHERe Id=153832

