SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
/**************** spGenerarAsisteCorteMov ****************/
if exists (select * from sysobjects where id = object_id('dbo.spGenerarAsisteCorteMov') and type = 'P') drop procedure dbo.spGenerarAsisteCorteMov
GO
CREATE PROCEDURE spGenerarAsisteCorteMov
		    @Sucursal		int,
		    @Empresa		char(5),
		    @Usuario		char(10),
    		@FechaInicial	datetime,
		    @FechaFinal		datetime,
		    @Ok			    int		        OUTPUT,
		    @OkRef		    varchar(255)	OUTPUT
--//WITH ENCRYPTION
AS BEGIN
  DECLARE
    @ID			                int,
    @Renglon		            float,
    @CfgMovCorte	            char(20),
    @FechaEmision	            datetime,
    @Personal		            char(10),
    @Registro		            char(10),
    @FechaHoraD		            datetime,
    @FechaHoraA		            datetime,
    @Fecha		                datetime, 
    @Extra		                int,
    @Ausencia		            int, 
    @Minutos		            int,
    @Cantidad		            int,
    @Tipo		                varchar(20),
    @Concepto		            varchar(50),
    @PersonalEstatus            char(15),
    @FechaBaja		            datetime,
    @Lenguaje                   varchar(25),
    @DiaSemanaAsist             int,
    @Jornada                    varchar(20),
    @Domingo                    bit, 
    @Sabado                     bit,
    @Lunes                      bit,    
    @Martes                     bit, 
    @Miercoles                  bit,
    @Jueves                     bit,   
    @Viernes                    bit,
    @AsistDescansolaborado      bit,
    @AsistDiaFestivolaborado    bit,
    @AsistDomingoLaborado       bit
    
    SET @Lenguaje = @@LANGUAGE

    SELECT @AsistDescansolaborado   = ISNULL(AsistDescansolaborado,0),
           @AsistDiaFestivolaborado = ISNULL(AsistDiaFestivolaborado,0), 
           @AsistDomingoLaborado    = ISNULL(AsistDomingoLaborado,0)
      FROM EmpresaCfg
      WHERE Empresa = @Empresa
  -- Dias
  DECLARE crDifDia CURSOR
     FOR SELECT Personal, Fecha, SUM(Ausencia), SUM(Extra), SUM(Minutos)
           FROM PersonalAsisteDifDia
          WHERE Empresa = @Empresa AND Fecha >= @FechaInicial AND Fecha < DATEADD(day, 1, @FechaFinal)-- AND Permiso IS NULL AND PermisoID IS NULL 
          GROUP BY Personal, Fecha
          ORDER BY Personal, Fecha

  OPEN crDifDia 
  FETCH NEXT FROM crDifDia INTO @Personal, @Fecha, @Ausencia, @Extra, @Minutos
  WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
  BEGIN
    IF @@FETCH_STATUS <> -2 AND @Ok IS NULL
    BEGIN  
      SELECT @Jornada = Jornada FROM Personal WHERE Personal = @Personal

      SELECT @Domingo   = Domingo   FROM Jornada WHERE Jornada = @Jornada
      SELECT @Sabado    = Sabado    FROM Jornada WHERE Jornada = @Jornada
      SELECT @Lunes     = Lunes     FROM Jornada WHERE Jornada = @Jornada
      SELECT @Martes    = Martes    FROM Jornada WHERE Jornada = @Jornada
      SELECT @Miercoles = Miercoles FROM Jornada WHERE Jornada = @Jornada
      SELECT @Jueves    = Jueves    FROM Jornada WHERE Jornada = @Jornada
      SELECT @Viernes   = Viernes   FROM Jornada WHERE Jornada = @Jornada      

      SELECT @Concepto = NULL
      IF @Ausencia > 0
      BEGIN
        SELECT @Concepto = PermisoConcepto
          FROM PersonalAsisteDifDia 
         WHERE Empresa = @Empresa AND Personal = @Personal AND Fecha = @Fecha AND Permiso IS NOT NULL AND PermisoID IS NOT NULL AND Ausencia > 0

        INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,            Concepto) 
                          VALUES (@Empresa, @Personal, @Fecha, 1,        'Dias Ausencia', @Concepto)
      END ELSE
      IF @Extra > 0 
      BEGIN

        SELECT @DiaSemanaAsist =  DATEPART (DW, @Fecha)  
        SELECT @Concepto = PermisoConcepto
          FROM PersonalAsisteDifDia
         WHERE Empresa = @Empresa AND Personal = @Personal AND Fecha = @Fecha AND Permiso IS NOT NULL AND PermisoID IS NOT NULL AND Extra > 0

        IF @@DATEFIRST = 1
        BEGIN
            IF ((@Fecha IN (SELECT Fecha FROM DiaFestivo)) OR (@Fecha IN (SELECT Fecha FROM JornadaDiaFestivo WHERE Jornada = @Jornada))) AND @AsistDiaFestivolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Día Festivo laborado', @Concepto)
            END
            ELSE IF @DiaSemanaAsist = 7 AND @AsistDomingoLaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Domingo Laborado', @Concepto)
            END
            ELSE IF (@Domingo = 1 AND @DiaSemanaAsist = 7) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, @Minutos, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Sabado = 1 AND @DiaSemanaAsist = 6) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Lunes = 1 AND @DiaSemanaAsist = 1) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Martes = 1 AND @DiaSemanaAsist = 2) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Miercoles = 1 AND @DiaSemanaAsist = 3) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Jueves = 1 AND @DiaSemanaAsist = 4) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Viernes = 1 AND @DiaSemanaAsist = 5) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END          
            ELSE      
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, @Minutos, 'Minutos Extras', @Concepto)
            END
        END

        IF @@DATEFIRST = 7
        BEGIN
            IF ((@Fecha IN (SELECT Fecha FROM DiaFestivo)) OR (@Fecha IN (SELECT Fecha FROM JornadaDiaFestivo WHERE Jornada = @Jornada))) AND @AsistDiaFestivolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Día Festivo laborado', @Concepto)
            END
            ELSE IF @DiaSemanaAsist = 1 AND @AsistDomingoLaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Domingo Laborado', @Concepto)
            END
            ELSE IF (@Domingo = 1 AND @DiaSemanaAsist = 1) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, @Minutos, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Sabado = 1 AND @DiaSemanaAsist = 7) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Lunes = 1 AND @DiaSemanaAsist = 2) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Martes = 1 AND @DiaSemanaAsist = 3) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Miercoles = 1 AND @DiaSemanaAsist = 4) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Jueves = 1 AND @DiaSemanaAsist = 5) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END
            ELSE IF (@Viernes = 1 AND @DiaSemanaAsist = 6) AND @AsistDescansolaborado = 1
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, 1, 'Descanso laborado', @Concepto)
            END          
            ELSE      
            BEGIN
                INSERT PersonalAsisteDif (Empresa,  Personal,  Fecha,  Cantidad, Tipo,             Concepto) 
                                  VALUES (@Empresa, @Personal, @Fecha, @Minutos, 'Minutos Extras', @Concepto)
            END
        END


      END
    END
    FETCH NEXT FROM crDifDia INTO @Personal, @Fecha, @Ausencia, @Extra, @Minutos
  END  -- While
  CLOSE crDifDia
  DEALLOCATE crDifDia

  -- Minutos
  DECLARE crDifMin CURSOR
     FOR SELECT Personal, Fecha, Registro, FechaHoraD, FechaHoraA, Ausencia, Extra
           FROM PersonalAsisteDifMin
          WHERE Empresa = @Empresa AND Fecha >= @FechaInicial AND Fecha < DATEADD(day, 1, @FechaFinal) AND Permiso IS NULL AND PermisoID IS NULL 
  OPEN crDifMin
  FETCH NEXT FROM crDifMin INTO @Personal, @Fecha, @Registro, @FechaHoraD, @FechaHoraA, @Ausencia, @Extra
  WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
  BEGIN
    IF @@FETCH_STATUS <> -2 AND @Ok IS NULL
    BEGIN
      EXEC spGenerarAsisteJustificar @Empresa, @Personal, @Fecha, @Registro, @FechaHoraD, @FechaHoraA, @Ausencia, @Extra, @Ok OUTPUT, @OkRef OUTPUT
    END

    FETCH NEXT FROM crDifMin INTO @Personal, @Fecha, @Registro, @FechaHoraD, @FechaHoraA, @Ausencia, @Extra
  END  -- While
  CLOSE crDifMin
  DEALLOCATE crDifMin

  -- Borrar Cortes Anteriores
  DECLARE crBorradores CURSOR
     FOR SELECT ID 
           FROM Asiste 
          WHERE Empresa = @Empresa AND Estatus = 'BORRADOR' AND Mov = @CfgMovCorte
  
  OPEN crBorradores
  FETCH NEXT FROM crBorradores INTO @ID
  WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
  BEGIN
    IF @@FETCH_STATUS <> -2 AND @Ok IS NULL
    BEGIN
      DELETE AsisteD WHERE ID = @ID
      DELETE Asiste  WHERE ID = @ID
    END
    FETCH NEXT FROM crBorradores INTO @ID
  END  -- While
  CLOSE crBorradores
  DEALLOCATE crBorradores

  -- Generar el Corte

  SELECT @FechaEmision = GETDATE(), @Renglon = 0.0
  EXEC spExtraerFecha @FechaEmision OUTPUT
  SELECT @CfgMovCorte = ISNULL(NULLIF(RTRIM(AsisteCorte), ''), 'Corte') FROM EmpresaCfgMov WHERE Empresa = @Empresa
  SELECT @ID = NULL
  SELECT @ID = MAX(ID) FROM Asiste WHERE Empresa = @Empresa AND Usuario = @Usuario AND Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR')

  IF @ID IS NULL
  BEGIN 
    INSERT Asiste (Sucursal, Empresa,  Mov,          FechaEmision,  Usuario,  Estatus,    FechaD,        FechaA) 
           VALUES (@Sucursal, @Empresa, @CfgMovCorte, @FechaEmision, @Usuario, 'BORRADOR', @FechaInicial, @FechaFinal)
    SELECT @ID = SCOPE_IDENTITY()
  END ELSE
  BEGIN
    DELETE AsisteD WHERE ID = @ID
    UPDATE Asiste 
       SET FechaEmision = @FechaEmision,
	   Estatus = 'BORRADOR',
           FechaD  = @FechaInicial,
           FechaA  = @FechaFinal
     WHERE ID = @ID
  END

  DECLARE crDif CURSOR
     FOR SELECT d.Personal, d.Fecha, d.Registro, d.Cantidad, d.Tipo, d.Concepto, p.Estatus, p.FechaBaja
           FROM PersonalAsisteDif d, Personal p
          WHERE d.Empresa = @Empresa AND d.Fecha >= @FechaInicial AND d.Fecha < DATEADD(day, 1, @FechaFinal) 
            AND d.Personal = p.Personal
          ORDER BY d.Personal, d.Fecha, d.Registro

  OPEN crDif
  FETCH NEXT FROM crDif INTO @Personal, @Fecha, @Registro, @Cantidad, @Tipo, @Concepto, @PersonalEstatus, @FechaBaja
  WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
  BEGIN
    IF @@FETCH_STATUS <> -2 AND @Ok IS NULL
    BEGIN
      IF @PersonalEstatus <> 'BAJA' OR @Fecha<=@FechaBaja
      BEGIN
        SELECT @Renglon = @Renglon + 2048
        INSERT AsisteD (Sucursal, ID,  Renglon,  Personal,  Fecha,  Registro,  Cantidad,  Tipo,  Concepto)
                VALUES (@Sucursal, @ID, @Renglon, @Personal, @Fecha, @Registro, @Cantidad, @Tipo, @Concepto)
      END
    END
    FETCH NEXT FROM crDif INTO @Personal, @Fecha, @Registro, @Cantidad, @Tipo, @Concepto, @PersonalEstatus, @FechaBaja
  END  -- While
  CLOSE crDif
  DEALLOCATE crDif
  RETURN
END
GO
