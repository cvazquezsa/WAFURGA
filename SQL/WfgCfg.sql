SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE Name='WfgCfg' AND Type='U')
	CREATE TABLE WfgCfg (
		Empresa	varchar(5) NOT NULL,
		ActivarCorteCredito bit NULL DEFAULT 0, --Este check se utilizará para que al procesar el spWfgCorteCredito mediante un job, se genere o no el corte de crédito.
		)
GO

EXEC spALTER_TABLE 'WfgCfg','DiaCorteCredito','int NULL'
EXEC spALTER_TABLE 'WfgCfg','NomConceptoSiVale','varchar(50) NULL'
EXEC spALTER_TABLE 'WfgCfg','NomPropiedadSiVale','varchar(50) NULL'
GO

--SELECT Propiedad FROM PersonalProp WHERe NivelPersonal=1