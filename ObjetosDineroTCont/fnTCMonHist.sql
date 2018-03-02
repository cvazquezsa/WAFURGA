  
CREATE FUNCTION [dbo].[fnTCMonHist](@Fecha DATETIME)  
 RETURNS FLOAT  
AS BEGIN  
 DECLARE @TC FLOAT  
  
 SELECT @TC = TipoCambio  
 FROM MonHist  
 WHERE dbo.fnFechaSinHora(Fecha) = @Fecha  
   AND Moneda = 'Dolares'  
  
 -- Si no existe TC para el día especificado, busca el último  
 IF ISNULL(@TC,0) = 0 BEGIN  
  SELECT TOP 1 @TC = TipoCambio  
  FROM MonHist  
  WHERE dbo.fnFechaSinHora(Fecha) <= @Fecha  
    AND Moneda = 'Dolares'  
  ORDER BY Fecha DESC  
 END  
  
 RETURN @TC  
END  