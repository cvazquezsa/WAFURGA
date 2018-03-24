SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
SET ANSI_PADDING OFF
GO
/**************** spGenerarAsisteCorte ****************/
if exists (select * from sysobjects where id = object_id('dbo.spGenerarAsisteCorte') and type = 'P') drop procedure dbo.spGenerarAsisteCorte
GO
CREATE PROCEDURE spGenerarAsisteCorte
		    @Sucursal		int,
                    @Empresa		char(5),
		    @Usuario		char(10),
    		    @FechaInicial	datetime,
		    @FechaFinal		datetime
--//WITH ENCRYPTION
AS BEGIN
  DECLARE
    @Personal		char(10),
    @FechaAlta		datetime,
    @Jornada		varchar(20),
    @CfgToleraEntrada 	int,
    @CfgToleraSalida	int,
    @Ok			int,
    @OkRef		varchar(255)

  SELECT @Ok = NULL, @OkRef = NULL
  EXEC spExtraerFecha @FechaInicial OUTPUT
  EXEC spExtraerFecha @FechaFinal OUTPUT

  SELECT @CfgToleraEntrada = ISNULL(AsisteToleraEntrada, 0),
         @CfgToleraSalida  = ISNULL(AsisteToleraSalida, 0)
    FROM EmpresaCfg
   WHERE Empresa = @Empresa

  BEGIN TRANSACTION
/*
    DELETE PersonalAsisteDifDia WHERE Empresa = @Empresa AND Fecha >= @FechaInicial AND Fecha < DATEADD(day, 1, @FechaFinal)
    DELETE PersonalAsisteDifMin WHERE Empresa = @Empresa AND Fecha >= @FechaInicial AND Fecha < DATEADD(day, 1, @FechaFinal)
    DELETE PersonalAsisteDif    WHERE Empresa = @Empresa AND Fecha >= @FechaInicial AND Fecha < DATEADD(day, 1, @FechaFinal)
    DELETE PersonalAsiste       WHERE Empresa = @Empresa AND Fecha >= @FechaInicial AND Fecha < DATEADD(day, 1, @FechaFinal)
*/

    TRUNCATE TABLE PersonalAsisteDifDia 
    TRUNCATE TABLE PersonalAsisteDifMin 
    TRUNCATE TABLE PersonalAsisteDif    
    TRUNCATE TABLE PersonalAsiste       

    DECLARE crPersonal CURSOR
       FOR SELECT NULLIF(RTRIM(p.Personal), ''), NULLIF(RTRIM(p.Jornada), ''), p.FechaAlta
             FROM Personal p, Jornada j
            WHERE p.Jornada = j.Jornada
--            AND p.Estatus = 'ALTA'
			  AND p.Empresa = @Empresa
              AND UPPER(j.Tipo) = 'CONTROL ASISTENCIA'

    OPEN crPersonal
    FETCH NEXT FROM crPersonal INTO @Personal, @Jornada, @FechaAlta
    WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
    BEGIN
      IF @@FETCH_STATUS <> -2 AND @Ok IS NULL
      BEGIN
        EXEC spGenerarAsiste @Empresa, @Personal, @FechaInicial, @FechaFinal, @Ok OUTPUT, @OkRef OUTPUT
        IF @Ok IS NULL
          EXEC spGenerarAsisteAusencia @Empresa, @CfgToleraEntrada, @CfgToleraSalida, @Personal, @Jornada, @FechaAlta, @FechaInicial, @FechaFinal, @Ok OUTPUT, @OkRef OUTPUT

        IF @Ok IS NULL
          EXEC spGenerarAsisteExtra @Empresa, @Personal, @Jornada, @FechaInicial, @FechaFinal, @Ok OUTPUT, @OkRef OUTPUT

        IF @Ok IS NOT NULL AND @OkRef IS NULL 
          SELECT @OkRef = 'Persona: '+RTRIM(@Personal)
      END
      FETCH NEXT FROM crPersonal INTO @Personal, @Jornada, @FechaAlta
    END  -- While
    CLOSE crPersonal
    DEALLOCATE crPersonal

    IF @Ok IS NULL
      EXEC spGenerarAsistePermisos @Empresa, @FechaInicial, @FechaFinal, @Ok OUTPUT, @OkRef OUTPUT

    IF @Ok IS NULL
      EXEC spGenerarAsisteCorteMov @Sucursal, @Empresa, @Usuario, @FechaInicial, @FechaFinal, @Ok OUTPUT, @OkRef OUTPUT

/*    IF (SELECT AsisteJornadasNocturnas FROM EmpresaCfg WHERE Empresa = @Empresa) = 1 AND @Ok IS NULL
      EXEC spGenerarAsisteJornadasNocturnas @Empresa, @FechaFinal, @Ok OUTPUT, @OkRef OUTPUT*/

  IF @Ok IS NULL
  BEGIN
    COMMIT TRANSACTION
    SELECT "Se Genero con Exito el Corte de Asistencia"
  END ELSE
  BEGIN
    ROLLBACK TRANSACTION
    SELECT RTRIM(Descripcion)+'<BR>'+RTRIM(@OkRef) FROM MensajeLista WHERE Mensaje = @Ok  
  END
  
  RETURN
END
GO

