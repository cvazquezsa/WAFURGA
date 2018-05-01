/****** Object:  UserDefinedFunction [dbo].[fn_SaldoCont]    Script Date: 11/06/2015 11:32:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_SaldoCont]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_SaldoCont]
GO

CREATE FUNCTION [dbo].[fn_SaldoCont] (@Empresa VARCHAR(5), @Sucursal INT, @Ejercicio INT, @Periodo INT, @Cuenta VARCHAR(20))
	RETURNS FLOAT
AS BEGIN
	DECLARE @Saldo FLOAT

	SELECT @Saldo = SUM(ISNULL(Cargos,0)-ISNULL(Abonos,0))
	FROM Acum
	WHERE Rama    = 'CONT'
	  AND Empresa = @Empresa
	  AND Sucursal = CASE WHEN ISNULL(@Sucursal,-1) < 0 THEN Sucursal ELSE @Sucursal END
	  AND Cuenta  = @Cuenta
	  AND Ejercicio = @Ejercicio
	  AND Periodo <= @Periodo
	  AND Moneda = 'Pesos'
	  
	RETURN ISNULL(@Saldo,0)
END

GO


