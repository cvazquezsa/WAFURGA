SET ANSI_NULLS OFF
GO
ALTER VIEW dbo.CFDVtaTotalImpuestoV33
AS
	SELECT OrdenExportacion,
		   ID,
		   ImpuestoClave TipoImpuesto,
		   Importe,
		   TipoFactor,
		   TasaOCuota
	  FROM (SELECT MAX(ISNULL(A.OrdenExportacion,B.OrdenExportacion)) OrdenExportacion, B.ID, B.VentaDTipoImpuestoV33 AS ImpuestoClave, SUM(B.VentaDImpuestoImporteV33) Importe, B.VentaDTipoTasaV33 TipoFactor, 
		CAST(B.VentaDImpuestoTasaV33 AS DECIMAL(20,4)) TasaOCuota
			  FROM CFDVentaDMovImpuestoV33 B
		 LEFT JOIN CFDVentaMovImpuesto A
				ON A.ID = B.ID
			   AND A.ImpuestoClave = B.VentaDImpuestoClaveV33
			   AND A.Tasa = B.VentaDImpuestoTasaV33*100
			 WHERE ISNULL(B.VentaDImpuestoImporteV33,0) >= 0
			   AND B.VentaDTipoTasaV33 <> 'Exento'
		  GROUP BY /*ISNULL(A.OrdenExportacion,B.OrdenExportacion),*/ B.ID, B.VentaDTipoImpuestoV33, B.VentaDTipoTasaV33, CAST(B.VentaDImpuestoTasaV33 AS DECIMAL(20,4)) ) AS Imp
			 WHERE ImpuestoClave IN ('002','003')
GO
SELECT * FROm CFDVtaTotalImpuestoV33 WHERe ID=153815