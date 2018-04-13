SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Type='p' AND Name='spLayoutSiVale')
	DROP PROCEDURE spLayoutSiVale
GO
CREATE PROCEDURE spLayoutSiVale
	@Id int
AS
BEGIN
	DECLARE
		@Empresa varchar(5),
		@NomConceptoSiVale varchar(50),
		@NomPropiedadSiVale varchar(50),
		@LongitudMax int =26

	SELECT @Empresa=Empresa FROM Nomina WHERE ID=@Id
	SELECT @NomConceptoSiVale=NomConceptoSiVale,@NomPropiedadSiVale=NomPropiedadSiVale FROM WfgCfg WHERE Empresa=@Empresa
	--SELECT @Concepto='Sueldo', @Id=159, @PropiedadTarjeta='Tarjeta Si Vale'
	
	SELECT 
		CASE 
			WHEN LEN(CONCAT(p.ApellidoPaterno,' ', p.ApellidoMaterno, ' ', p.Nombre))<=@LongitudMax THEN CONCAT(p.ApellidoPaterno,' ', p.ApellidoMaterno, ' ', p.Nombre)
			WHEN LEN(CONCAT(p.ApellidoPaterno,' ', p.Nombre))<=@LongitudMax THEN CONCAT(p.ApellidoPaterno,' ', p.Nombre)
			WHEN LEN(p.Nombre)<=@LongitudMax THEN p.Nombre
		END  Nombre, 
		ppv.Valor NumeroTarjeta, 
		nd.Importe Monto
		FROM NominaD nd
			JOIN Personal p ON nd.Personal=p.Personal
			LEFT JOIN PersonalPropValor ppv ON ppv.Rama='PER' AND p.Personal=ppv.Cuenta AND Propiedad=@NomPropiedadSiVale
		WHERE nd.Concepto = @NomConceptoSiVale AND nd.ID=@Id
END
GO
EXEC spLayoutSiVale 159--,'Sueldo','Tarjeta Si Vale'
