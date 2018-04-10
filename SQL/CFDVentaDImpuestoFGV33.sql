SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
ALTER VIEW dbo.CFDVentaDImpuestoFGV33
AS
		SELECT REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,B.ID))))) + RTRIM(LTRIM(CONVERT(varchar, B.ID))) +
			   REPLICATE('0',12-LEN(RTRIM(LTRIM(CONVERT(varchar,B.RenglonID))))) + RTRIM(LTRIM(CONVERT(varchar, B.RenglonID))) +
			   REPLICATE('0',7-LEN(RTRIM(LTRIM(CONVERT(varchar,B.RenglonID))))) + RTRIM(LTRIM(CONVERT(varchar, B.RenglonID))) +
			   REPLICATE(' ',50)													OrdenExportacion,
			   B.ID																	ID,
			   B.RenglonID															Renglon,
			   B.RenglonID															RenglonSub,
			   SUM((D.SubTotal+isnull(D.Impuesto2Total,0))*
			   dbo.fnCFDTipoCambioMN(A.TipoCambio,
									 ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)))			Base,
			   '002'																Impuesto,
			   CASE WHEN Art.Impuesto1Excento = 1
					THEN 'Exento'
					ELSE 'Tasa' END													TipoFactor,
			   CASE WHEN Art.Impuesto1Excento = 1
			        THEN NULL
					ELSE (D.Impuesto1/100) END										TasaOCuota,
			   CASE WHEN Art.Impuesto1Excento = 1
			        THEN NULL
					ELSE SUM(((D.SubTotal+isnull(D.Impuesto2Total,0))*
						      (D.Impuesto1/100))*dbo.fnCFDTipoCambioMN(A.TipoCambio,
							   ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))) END			Importe
		  FROM Venta A
		  JOIN VentaOrigen B
		    ON A.ID = B.ID
		  JOIN Venta C
		    ON B.OrigenID = C.ID
		  JOIN VentaTCalc D
		    ON B.OrigenID = D.ID
		  JOIN EmpresaCfg ON A.Empresa = EmpresaCfg.Empresa
		  JOIN EmpresaCFD ON A.Empresa = EmpresaCFD.Empresa
		  JOIN MovTipo mt ON mt.Modulo = 'VTAS' AND mt.Mov = A.Mov
		  JOIN Art ON D.Articulo = Art.Articulo
		 WHERE isnull(D.Impuesto1,0) >= 0 
			AND D.Importe>0--WAFURGA
	  GROUP BY B.ID, B.RenglonID, D.Impuesto1, Art.Impuesto1Excento
	 UNION ALL
		SELECT REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,B.ID))))) + RTRIM(LTRIM(CONVERT(varchar, B.ID))) +
			   REPLICATE('0',12-LEN(RTRIM(LTRIM(CONVERT(varchar,B.RenglonID))))) + RTRIM(LTRIM(CONVERT(varchar, B.RenglonID))) +
			   REPLICATE('0',7-LEN(RTRIM(LTRIM(CONVERT(varchar,B.RenglonID))))) + RTRIM(LTRIM(CONVERT(varchar, B.RenglonID))) +
			   REPLICATE(' ',50)													OrdenExportacion,
			   B.ID																	ID,
			   B.RenglonID															Renglon,
			   B.RenglonID															RenglonSub,
			   SUM((D.SubTotal)*
			   dbo.fnCFDTipoCambioMN(A.TipoCambio,
									 ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)))			Base,
			   '003'																Impuesto,
			   'Tasa'																TipoFactor,
			   (D.Impuesto2/100)													TasaOCuota,
			   SUM(((D.SubTotal)*(D.Impuesto2/100))*
			   dbo.fnCFDTipoCambioMN(A.TipoCambio,
									 ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)))			Importe
		  FROM Venta A
		  JOIN VentaOrigen B
		    ON A.ID = B.ID
		  JOIN Venta C
		    ON B.OrigenID = C.ID
		  JOIN VentaTCalc D
		    ON B.OrigenID = D.ID
		  JOIN EmpresaCfg ON A.Empresa = EmpresaCfg.Empresa
		  JOIN EmpresaCFD ON A.Empresa = EmpresaCFD.Empresa
		  JOIN MovTipo mt ON mt.Modulo = 'VTAS' AND mt.Mov = A.Mov
		 WHERE isnull(D.Impuesto2,0) > 0
	  GROUP BY B.ID, B.RenglonID, D.Impuesto2
	 UNION ALL
		SELECT REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,B.ID))))) + RTRIM(LTRIM(CONVERT(varchar, B.ID))) +
			   REPLICATE('0',12-LEN(RTRIM(LTRIM(CONVERT(varchar,B.RenglonID))))) + RTRIM(LTRIM(CONVERT(varchar, B.RenglonID))) +
			   REPLICATE('0',7-LEN(RTRIM(LTRIM(CONVERT(varchar,B.RenglonID))))) + RTRIM(LTRIM(CONVERT(varchar, B.RenglonID))) +
			   REPLICATE(' ',50)													OrdenExportacion,
			   B.ID																	ID,
			   B.RenglonID															Renglon,
			   B.RenglonID															RenglonSub,
			   SUM((D.SubTotal)*
			   dbo.fnCFDTipoCambioMN(A.TipoCambio,
									 ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)))			Base,
			   '003'																Impuesto,
			   'Cuota'																TipoFactor,
			   (D.Impuesto3/100)													TasaOCuota,
			   SUM(((D.SubTotal)*(D.Impuesto3/100))*
			   dbo.fnCFDTipoCambioMN(A.TipoCambio,
									 ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)))			Importe
		  FROM Venta A
		  JOIN VentaOrigen B
		    ON A.ID = B.ID
		  JOIN Venta C
		    ON B.OrigenID = C.ID
		  JOIN VentaTCalc D
		    ON B.OrigenID = D.ID
		  JOIN EmpresaCfg ON A.Empresa = EmpresaCfg.Empresa
		  JOIN EmpresaCFD ON A.Empresa = EmpresaCFD.Empresa
		  JOIN MovTipo mt ON mt.Modulo = 'VTAS' AND mt.Mov = A.Mov
		 WHERE isnull(D.Impuesto3,0) > 0
	  GROUP BY B.ID, B.RenglonID, D.Impuesto3
GO
SELECT * FROM CFDVentaDImpuestoFGV33 WHERe Id=153832