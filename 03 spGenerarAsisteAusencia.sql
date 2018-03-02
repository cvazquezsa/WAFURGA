/**************** spGenerarAsisteAusencia ****************/
if exists (select * from sysobjects where id = object_id('dbo.spGenerarAsisteAusencia') and type = 'P') drop procedure dbo.spGenerarAsisteAusencia
GO
CREATE PROCEDURE spGenerarAsisteAusencia
		    @Empresa		char(5),
		    @CfgToleraEntrada	int, 
		    @CfgToleraSalida	int, 
		    @Personal		char(10),
		    @Jornada		varchar(20),
		    @FechaAlta		datetime,
		    @FechaInicial	datetime,
		    @FechaFinal		datetime,

		    @Ok			int		OUTPUT,
		    @OkRef		varchar(255)	OUTPUT
--//WITH ENCRYPTION
AS BEGIN
  DECLARE
    @ID			int,
    @UltID		int,
    @FechaEntrada	datetime,
    @FechaSalida	datetime,
    @Entrada		datetime,
    @Salida		datetime,
    @EntradaReal	datetime,
    @SalidaReal		datetime,
    @Dia		int,
    @Mes		int,
    @Ano		int,
    @Dias		int,
    @Minutos	int,
    @Nocturna   bit
  
  SELECT @Nocturna = JornadaNocturna 
    FROM Jornada 
   WHERE Jornada = @Jornada
   
   SET @Nocturna = ISNULL(@Nocturna,0)
  
  IF NOT EXISTS(SELECT * FROM JornadaTiempo WHERE Jornada = @Jornada AND Entrada > @FechaFinal)
  BEGIN
    SELECT @Ok = 55260
    RETURN
  END

  SELECT @UltID = 0
  DECLARE crJornadaTiempo CURSOR
     FOR SELECT Entrada, Salida
           FROM JornadaTiempo
          WHERE Jornada = @Jornada AND Salida > @FechaInicial AND Entrada < DATEADD(day, 1, @FechaFinal) AND Entrada >= @FechaAlta
  SELECT @EntradaReal = @FechaInicial              
  OPEN crJornadaTiempo
  FETCH NEXT FROM crJornadaTiempo INTO @Entrada, @Salida

  WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
  BEGIN
    IF @@FETCH_STATUS <> -2 AND @Ok IS NULL
    BEGIN
      SELECT @FechaEntrada = @Entrada, @FechaSalida = @Salida
      EXEC spExtraerFecha @FechaEntrada OUTPUT
      EXEC spExtraerFecha @FechaSalida  OUTPUT
      IF EXISTS(SELECT * FROM PersonalAsiste WHERE Empresa = @Empresa AND Personal = @Personal/* NES Para correcci�n de entradas y salidas en diferentes dias AND Fecha = @FechaEntrada*/
					AND DAY(Entrada) = DAY(@FechaEntrada) AND MONTH(Entrada) = MONTH(@FechaEntrada) AND YEAR(Entrada) = YEAR(@FechaEntrada))
      BEGIN
        SELECT @ID = NULL
        SELECT @ID = MIN(ID)
          FROM PersonalAsiste 
         WHERE Empresa = @Empresa AND Personal = @Personal AND Fecha = @FechaEntrada AND ProcesarAusencia = 1 AND ID > @UltID

        IF @ID IS NULL 
        BEGIN
          SELECT @Minutos = DATEDIFF(mi, @Entrada, @Salida)
          
          IF @Nocturna = 1 
          BEGIN
            SET @EntradaReal =  DATEADD(dd,-1,@EntradaReal)
            SELECT @Minutos = DATEDIFF(mi, @Entrada, @EntradaReal)
          END

          IF @Minutos > @CfgToleraEntrada 
            INSERT PersonalAsisteDifMin (Empresa,  Personal,  FechaHoraD, FechaHoraA, Fecha,         Ausencia, Registro) 
                                 VALUES (@Empresa, @Personal, @Entrada,   @Salida,    @FechaEntrada, @Minutos, 'Entrada')
        END ELSE 
        BEGIN
          SELECT @UltID = ID, @EntradaReal = Entrada, @SalidaReal  = Salida 
            FROM PersonalAsiste 
           WHERE ID = @ID

          SELECT @Minutos = DATEDIFF(mi, @Entrada, @EntradaReal)

          IF @Nocturna = 1 
          BEGIN
            SET @EntradaReal =  DATEADD(dd,-1,@EntradaReal)
            SELECT @Minutos = DATEDIFF(mi, @Entrada, @EntradaReal)
          END
          IF @Minutos > @CfgToleraEntrada
            INSERT PersonalAsisteDifMin (Empresa,  Personal,  FechaHoraD, FechaHoraA,   Fecha,         Ausencia, Registro) 
                                 VALUES (@Empresa, @Personal, @Entrada,   @EntradaReal, @FechaEntrada, @Minutos, 'Entrada')

          SELECT @Minutos = DATEDIFF(mi, @SalidaReal, @Salida)
          IF @Nocturna = 1 
          BEGIN
            SET @SalidaReal =  DATEADD(dd,-1,@SalidaReal)
            SELECT @Minutos = DATEDIFF(mi, @Salida, @SalidaReal)
          END
          IF @Minutos > @CfgToleraSalida
            INSERT PersonalAsisteDifMin (Empresa,  Personal,  FechaHoraD,  FechaHoraA, Fecha,        Ausencia, Registro) 
                                 VALUES (@Empresa, @Personal, @SalidaReal, @Salida,    @FechaSalida, @Minutos, 'Salida')
                                
                                                                                   
        END
      END ELSE 
      BEGIN
        IF NOT EXISTS(SELECT * FROM PersonalAsisteDifDia WHERE Empresa = @Empresa AND Personal = @Personal AND Fecha = @FechaEntrada)
          INSERT PersonalAsisteDifDia (Empresa, Personal, Fecha, Ausencia) VALUES (@Empresa, @Personal, @FechaEntrada, 1)
      END
      UPDATE PersonalAsiste SET ProcesarAusencia = 0 WHERE ID = @ID
    END
    FETCH NEXT FROM crJornadaTiempo INTO @Entrada, @Salida
  END  -- While
  CLOSE crJornadaTiempo
  DEALLOCATE crJornadaTiempo
  RETURN
END
GO
