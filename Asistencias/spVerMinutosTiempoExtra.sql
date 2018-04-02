SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
SET ANSI_PADDING OFF
GO
/**************** [spVerMinutosTiempoExtra] ****************/
if exists (select * from sysobjects where id = object_id('dbo.[spVerMinutosTiempoExtra]') and type = 'P') drop procedure dbo.[spVerMinutosTiempoExtra]
GO
CREATE PROCEDURE [dbo].[spVerMinutosTiempoExtra]
    @Empresa	varchar(5),
	@FechaD		datetime,
	@FechaA		datetime,
	@BorraTabla bit 
--//WITH ENCRYPTION 
AS BEGIN
	DECLARE @JornadaTiempo TABLE (
		Jornada varchar(20),
		Fecha datetime,
		Entrada datetime,
		Salida datetime,
		WfgTiempoComida int
		)
	DECLARE @PersonalAsiste TABLE (
		Empresa varchar(5),
		Personal varchar(20),
		Fecha	datetime,
		Entrada datetime,
		Salida datetime
		)
	DECLARE @CalculoHE TABLE(
		Empresa varchar(5),
		Personal varchar(20),
		Fecha	datetime,
		Entrada datetime,
		Salida datetime,
		WfgTiempoComida int,
		HorasPromedio float,
		Minutos	int
		)

DECLARE
	@IDCorte	int,
	@FechaMovil	datetime,
	@nDia int,
	@SQL		varchar(max),
	@Dias		varchar(max),
	@Insert		varchar(max),
	@cNum		int,
	@cDia		varchar(10),
	@cFechaD	varchar(10),
	@cFechaA	varchar(10),
	@Semana		int,
	@DiaSem		int,
	@S1D6       datetime,
    @S2D6       datetime,
	@S1D7       datetime,
	@S2D7       datetime,
	@Idt        int
	
	IF @BorraTabla = 1
	BEGIN
		DELETE FROM AuxAsistenciaHE
		RETURN
	END
	
	IF @BorraTabla = 0
	BEGIN
		SELECT @IDCorte=ID FROM Asiste WHERE Mov='Corte' AND FechaD=@FechaD AND FechaA=@FechaA AND Estatus='CONCLUIDO'
		--SELECT * FROM AsisteD WHERE id=@IdCorte
		INSERT INTO @JornadaTiempo
			SELECT jt.Jornada,jt.Fecha,MIN(jt.Entrada),MAX(jt.Salida),MAX(jt.WFGTiempoComida) 
				FROM JornadaTiempo jt 
				WHERE jt.Fecha>=@FechaD AND jt.Fecha<=@FechaA
				GROUP BY jt.Jornada, jt.Fecha
		--SELECT * FROM @JornadaTiempo
		
		INSERT INTO @PersonalAsiste
		SELECT pa.Empresa,pa.Personal,pa.Fecha,MIN(pa.Entrada),	MAX(pa.Salida) 
			FROM PersonalAsiste pa
			WHERE pa.Fecha>=@FechaD AND pa.Fecha<=@FechaA
			GROUP BY pa.Empresa,pa.Personal,pa.Fecha
		--SELECT * FROM PersonalAsiste WHERE Personal='0701'

		/*INSERT INTO @CalculoHE(Empresa,Personal,Fecha,Entrada,Salida, WfgTiempoComida,HorasPromedio)
			SELECT pa.Empresa,pa.Personal,pa.Fecha,
				CASE WHEN pa.Entrada<ISNULL(jt.Entrada,0) THEN ISNULL(jt.Entrada,0) ELSE pa.Entrada END,
				pa.Salida,
				jt.WfgTiempoComida,
				j.HorasPromedio 
				FROM @PersonalAsiste pa
					JOIN Personal p ON pa.Personal=p.Personal
					LEFT JOIN @JornadaTiempo jt ON p.Jornada=jt.Jornada AND pa.Fecha=jt.Fecha
					JOIN Jornada j ON jt.Jornada=j.Jornada*/
			
			INSERT INTO @CalculoHE(Empresa,Personal,Fecha,Entrada,Salida, WfgTiempoComida,HorasPromedio)
			SELECT pa.Empresa,pa.Personal,pa.Fecha,
				pa.Entrada,
				pa.Salida,
				NULL,
				j.HorasPromedio 
				FROM @PersonalAsiste pa
					JOIN Personal p ON pa.Personal=p.Personal
					--LEFT JOIN @JornadaTiempo jt ON p.Jornada=jt.Jornada AND pa.Fecha=jt.Fecha
					JOIN Jornada j ON p.Jornada=j.Jornada
				--WHERE p.Sindicato='Por Dias'
			DECLARE 
				@chePersona varchar(20),
				@cheFecha	datetime,
				@cheEntrada datetime,
				@jtEntrada datetime,
				@TiempoComida int
			DECLARE crCalculoHE CURSOR FOR
				SELECT Personal, Fecha, Entrada FROM @CalculoHE
			OPEN crCalculoHE
			FETCH NEXT FROM crCalculoHE INTO
				@chePersona,@cheFecha,@cheEntrada
			WHILE @@FETCH_STATUS=0
			BEGIN
				SELECT @jtEntrada=NULL, @TiempoComida=NULL
				SELECT  @jtEntrada=jt.Entrada, @TiempoComida=jt.WFGTiempoComida
					FROM JornadaTiempo jt
						JOIN Personal p ON jt.Jornada=p.Jornada
						JOIN Jornada j ON j.Jornada=p.Jornada
					WHERE p.Personal=@chePersona AND jt.Fecha=@cheFecha
				--SELECT * FROM Jornada wHERe Jornada='0701'
				IF ISNULL(@TiempoComida,0)=0
				BEGIN
					SELECT @TiempoComida=j.HorasComida FROM Personal p
						JOIN Jornada j ON p.Jornada=j.Jornada
						WHERE p.Personal=@chePersona
					UPDATE @CalculoHE SET WfgTiempoComida=@TiempoComida WHERE Personal=@chePersona AND Fecha=@cheFecha
				END
					
				IF ISNULL(@jtEntrada,0)>@cheEntrada
					UPDATE @CalculoHE SET Entrada=@jtEntrada WHERE Personal=@chePersona AND Fecha=@cheFecha
				
				UPDATE @CalculoHE SET WfgTiempoComida=@TiempoComida WHERE Personal=@chePersona AND Fecha=@cheFecha
					--SELECT * FROM JornadaTiempo 
				FETCH NEXT FROM crCalculoHE INTO
					@chePersona,@cheFecha,@cheEntrada
			END
			CLOSE crCalculoHE
			DEALLOCATE crCalculoHE

		--SELECT * FROM @CalculoHE
		UPDATE @CalculoHE SET Minutos = CASE 
											WHEN (DATEDIFF(mi,Entrada,Salida)-ISNULL(WfgTiempoComida,0)-ISNULL(HorasPromedio,0)*60) >0 
												THEN (DATEDIFF(mi,Entrada,Salida)-ISNULL(WfgTiempoComida,0)-ISNULL(HorasPromedio,0)*60)
											ELSE
												0
											END
		DELETe @CalculoHE WHERE Minutos=0
		SELECT * FROM @CalculoHE
		INSERT INTO AuxAsistenciaHE (Empresa, Personal, FechaD, FechaA)
			SELECT DISTINCT Empresa,Personal,@FechaD, @FechaA FROM @CalculoHE
		
		SELECT @FechaMovil=@FechaD, @nDia=1

		WHILE @FechaMovil<=@FechaA
		BEGIN
			IF @nDia = 1
				UPDATE AUXAsistenciaHE SET Semana1Dia1 = c.Minutos 
					FROM @CalculoHE c 
					WHERE c.Fecha=@FechaMovil AND AUXAsistenciaHE.Empresa=c.Empresa AND AUXAsistenciaHE.Personal=c.Personal
			IF @nDia = 2
				UPDATE AUXAsistenciaHE SET Semana1Dia2 = c.Minutos 
					FROM @CalculoHE c 
					WHERE c.Fecha=@FechaMovil AND AUXAsistenciaHE.Empresa=c.Empresa AND AUXAsistenciaHE.Personal=c.Personal
			IF @nDia = 3
				UPDATE AUXAsistenciaHE SET Semana1Dia3 = c.Minutos 
					FROM @CalculoHE c 
					WHERE c.Fecha=@FechaMovil AND AUXAsistenciaHE.Empresa=c.Empresa AND AUXAsistenciaHE.Personal=c.Personal
			IF @nDia = 4
				UPDATE AUXAsistenciaHE SET Semana1Dia4 = c.Minutos 
					FROM @CalculoHE c 
					WHERE c.Fecha=@FechaMovil AND AUXAsistenciaHE.Empresa=c.Empresa AND AUXAsistenciaHE.Personal=c.Personal
			IF @nDia = 5
				UPDATE AUXAsistenciaHE SET Semana1Dia5 = c.Minutos 
					FROM @CalculoHE c 
					WHERE c.Fecha=@FechaMovil AND AUXAsistenciaHE.Empresa=c.Empresa AND AUXAsistenciaHE.Personal=c.Personal
			IF @nDia = 6
				UPDATE AUXAsistenciaHE SET Semana1Dia6 = c.Minutos 
					FROM @CalculoHE c 
					WHERE c.Fecha=@FechaMovil AND AUXAsistenciaHE.Empresa=c.Empresa AND AUXAsistenciaHE.Personal=c.Personal
			IF @nDia = 7
				UPDATE AUXAsistenciaHE SET Semana1Dia7 = c.Minutos 
					FROM @CalculoHE c 
					WHERE c.Fecha=@FechaMovil AND AUXAsistenciaHE.Empresa=c.Empresa AND AUXAsistenciaHE.Personal=c.Personal

			SELECT @FechaMovil=DATEADD(dd,1,@FechaMovil),@nDia+=1
		END
		
		--UPDATE AuxAsistenciaHE SET Semana1Dia1 = 20 WHERE Personal='0308'
		--SELECT * FROM AuxAsistenciaHE

	END
END
GO
EXEC spVerMinutosTiempoExtra 'E003',	'20180101',	'20180107',	1
EXEC spVerMinutosTiempoExtra 'E003',	'20180101',	'20180107',	0