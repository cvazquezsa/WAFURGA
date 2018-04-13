SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
GO

IF EXISTS(SELECT * FROM SysObjects WHERE Name='spRepAltaSiVale' AND Type='P')
	DROP PROCEDURE spRepAltaSiVale
GO
CREATE PROCEDURE spRepAltaSiVale
	@Empresa varchar(5),
	@FechaD datetime,
	@FechaA datetime
AS
BEGIN
SELECT 
	'00001' LugarEntrega,
	CONCAT(REPLICATE('0',10-LEN(p.Personal)), p.Personal) Referencia,
	CONCAT(p.ApellidoPaterno,' ',p.ApellidoMaterno,' ',p.Nombre) NombreEmpleado,
	ppv.Valor NumeroTarjeta,
	'0000000000000000' TarjetaAdicional,
	p.Nombre Nombre,
	p.ApellidoPaterno,
	p.ApellidoMaterno,
	p.Registro2 RFC,
	p.Registro CURP,
	p.Registro3 NumeroSeguridadSocial,
	NULL TelefonoCelular,
	NULL CorreoElectronico,
	NULL TarjetaEmpleadoTitular
	FROM RH 
		JOIN RHD ON RH.ID=RHD.ID
		JOIN Personal p ON RHD.Personal = p.Personal
		JOIN WfgCfg wc on wc.Empresa=@Empresa
		LEFT JOIN PersonalPropValor ppv ON p.Personal = ppv.Cuenta AND ppv.Rama = 'PER' AND wc.NomPropiedadSiVale = ppv.Propiedad
		JOIN MovTipo mt ON RH.Mov=mt.Mov AND mt.Modulo='RH'	
	WHERE mt.Clave='RH.A' AND RH.Estatus='CONCLUIDO' AND RH.FechaEmision >= @FechaD AND RH.FechaEmision <= @FechaA
END
GO
EXEC spRepAltaSiVale 'E001', '20180101', '20180107'
	--SELECT * FROM Personal