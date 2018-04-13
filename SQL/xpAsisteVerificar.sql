SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
GO
IF EXISTS(SELECT * FROM sysObjects WHERE Name='xpAsisteVerificar' AND Type='P')
	DROP PROCEDURE xpAsisteVerificar
GO
CREATE PROCEDURE xpAsisteVerificar
	@ID               	int,
	@Accion				char(20),
  @Empresa          	char(5),
	@Usuario			char(10),
  @Modulo	      		char(5),
  @Mov              	char(20),
	@MovID				varchar(20),
  @MovTipo	      	char(20),
	@FechaEmision		datetime,
	@Estatus			char(15),
	@MovFechaD			datetime,
	@MovFechaA			datetime,
	@OrigenTipo			char(10),
  @Origen				char(20),
  @OrigenID			varchar(20),
  @OrigenMovTipo		char(20),
	@Conexion			bit,
	@SincroFinal		bit,
	@Sucursal			int,
	@CfgContX			bit,
	@CfgContXGenerar	char(20),
	@GenerarPoliza		bit,
	@Ok               	int          OUTPUT,
  @OkRef            	varchar(255) OUTPUT
AS
BEGIN--xpAsisteVerificar
	DECLARE
		@Personal		varchar(10),
		@NoRegistros	int,
		@RegistrosEsperados	int,
		@Jornada		varchar(20),
		@TipoJornada	varchar(20),
		@TiempoComida	float,
		@NumRegistro	int,
		@Registro		varchar(20),
		@ContinuarReg	bit,
		@HoraRegistro	varchar(5)

	IF @Modulo='ASIS' AND @MovTipo='ASIS.R' AND @Accion IN ('AFECTAR','VERIFICAR')
	BEGIN--Mov Registro
		DECLARE crWfgVerRegistro CURSOR FAST_FORWARD FOR
			SELECT Personal FROM AsisteD WHERE ID=@ID
		
		OPEN crWfgVerRegistro
		FETCH NEXT FROM crWfgVerRegistro INTO
			@Personal

		WHILE @@FETCH_STATUS=0
		BEGIN--crWfgVerRegistro
			SELECT @NoRegistros=COUNT(*) FROM AsisteD WHERE ID=@ID AND Personal=@Personal
			IF NOT @NoRegistros%2=0
			BEGIN--Validacion Registro par
				SELECT @Ok=22021, @OkRef=CONCAT('Personal: ',@Personal)
				BREAK
			END--Validacion Registro par			

			SELECT @Jornada=Jornada FROM Personal WHERE Personal=@Personal
			SELECT @TipoJornada=Tipo FROM Jornada WHERE Jornada=@Jornada
			IF @TipoJornada='Control Asistencia' AND ISNULL(@Ok,0)=0
			BEGIN--Control Asistencia SI
				SELECT @TiempoComida=WFGTiempoComida FROM JornadaTiempo WHERE Jornada=@Jornada AND Fecha=@FechaEmision AND WFGTiempoComida IS NOT NULL
				IF ISNULL(@TiempoComida,0)>0
					SELECT @RegistrosEsperados=4
				ELSE
					IF EXISTS (SELECT * FROM JornadaTiempo WHERE Jornada=@Jornada AND Fecha=@FechaEmision)
						SELECT  @RegistrosEsperados=2
					ELSE
						SELECT  @RegistrosEsperados=0 
				IF @RegistrosEsperados>@NoRegistros
					BEGIN
						SELECT @Ok=22022, @OkRef=CONCAT('Se esperaban ',@RegistrosEsperados,', se registrarón ',@NoRegistros, ' ',@Personal)
						BREAK
					END
			END--Control Asistencia SI
		
		/*****INICIA VALIDACION DE ORDEN CORRECTO DE REGISTROS*****/

		

			IF ISNULL(@Ok,0)=0
			BEGIN--Valiacion de orden correcto
				DECLARE crWfgOrdenCorrecto CURSOR FAST_FORWARD FOR
					SELECT ROW_NUMBER() OVER (ORDER BY HoraRegistro) NumRegistro,Registro,HoraRegistro 
						FROM AsisteD 
						WHERE ID=@ID AND Personal=@Personal		

				OPEN	crWfgOrdenCorrecto
				FETCH NEXT FROM crWfgOrdenCorrecto INTO
					@NumRegistro,@Registro,@HoraRegistro

				WHILE @@FETCH_STATUS=0 AND ISNULL(@Ok,0)=0
				BEGIN--crWfgOrdenCorrecto
					IF @NumRegistro % 2=0
						IF NOT @Registro='Salida'
						BEGIN
							SELECT @Ok=22023, @OkRef=CONCAT('Se esperaba Salida se encontro ',@Registro,', Personal: ',@Personal,'Hora: ',@HoraRegistro)
						END

					IF NOT(@NumRegistro % 2=0) AND ISNULL(@Ok,0)=0
						IF NOT (@Registro='Entrada')
						BEGIN
							SELECT @Ok=22023, @OkRef=CONCAT('Se esperaba Entrada se encontro ',@Registro,', Personal: ',@Personal,'Hora: ',@HoraRegistro)
						END
					FETCH NEXT FROM crWfgOrdenCorrecto INTO
						@NumRegistro,@Registro,@HoraRegistro
				END--crWfgOrdenCorrecto
			
				CLOSE crWfgOrdenCorrecto
				DEALLOCATE crWfgOrdenCorrecto
			END--Valiacion de orden correcto		

		/*****TERMINA VALIDACION DE ORDEN CORRECTO DE REGISTROS*****/		

			SELECT 	@NoRegistros=NULL,@Jornada=NULL,@TipoJornada=NULL,@TiempoComida=NULL,@RegistrosEsperados=NULL		

			FETCH NEXT FROM crWfgVerRegistro INTO
				@Personal
		END--crWfgVerRegistro
		CLOSE crWfgVerRegistro
		DEALLOCATE crWfgVerRegistro
	END--MovRegistro
END--xpAsisteVerificar