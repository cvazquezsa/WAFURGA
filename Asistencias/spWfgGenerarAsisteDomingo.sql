SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
/**************** spWfgGenerarAsisteDomingo ****************/
if exists (select * from sysobjects where id = object_id('dbo.spWfgGenerarAsisteDomingo') and type = 'P') drop procedure dbo.spWfgGenerarAsisteDomingo
GO
CREATE PROCEDURE spWfgGenerarAsisteDomingo
		    @Empresa		char(5),
		    @Personal		char(10),
		    @Jornada		varchar(20),
		    @FechaInicial	datetime,
		    @FechaFinal		datetime,

		    @Ok			int		OUTPUT,
		    @OkRef		varchar(255)	OUTPUT
AS
BEGIN
	DECLARE @PersonalAsisteDom TABLE (
		Empresa varchar(5),
		Personal varchar(20),
		Fecha	datetime,
		DiaSemana int
		)
	IF @@DATEFIRST=1
			INSERT INTO @PersonalAsisteDom
				SELECT DISTINCT pa.Empresa, pa.Personal, pa.Fecha, DATEPART(DW, pa.Fecha)
					FROM PersonalAsiste pa
					WHERE pa.Empresa=@Empresa AND pa.Personal=@Personal AND pa.Fecha>=@FechaInicial AND pa.Fecha<=@FechaFinal AND DATEPART(DW, pa.Fecha)=7
	IF @@DATEFIRST=7
		INSERT INTO @PersonalAsisteDom
			SELECT DISTINCT pa.Empresa, pa.Personal, pa.Fecha, DATEPART(DW, pa.Fecha)
				FROM PersonalAsiste pa
				WHERE pa.Empresa=@Empresa AND pa.Personal=@Personal AND pa.Fecha>=@FechaInicial AND pa.Fecha<=@FechaFinal AND DATEPART(DW, pa.Fecha)=1

	IF EXISTS (SELECT * FROM @PersonalAsisteDom)
		INSERT INTO PersonalAsisteDifDia (Empresa, Personal, Fecha)
			SELECT Empresa, Personal, Fecha
				FROM @PersonalAsisteDom
--SELECT * FROM PersonalAsisteDifDia
END
GO
--BEGIN TRANSACTION
--EXEC spWfgGenerarAsisteDomingo 'E003', '0308', '0308', '20180212', '20180218', nULL, NULL
--ROLLBACK