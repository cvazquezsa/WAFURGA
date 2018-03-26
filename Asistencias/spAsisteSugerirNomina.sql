/**************** spAsisteSugerirNomina ****************/
if exists (select * from sysobjects where id = object_id('dbo.spAsisteSugerirNomina') and type = 'P') drop procedure dbo.spAsisteSugerirNomina
GO             
CREATE PROCEDURE spAsisteSugerirNomina
			@Empresa	char(5), 
			@Sucursal	int,
			@Usuario	char(10),
			@Modulo		char(5),
			@ID		int, 
			@Mov		char(20),
			@MovID		varchar(20),
			@Accion		char(20),

			@Ok 		int		OUTPUT, 
			@OkRef 		varchar(255)	OUTPUT
--//WITH ENCRYPTION
AS BEGIN
  DECLARE
    @Moneda		        char(10),
    @TipoCambio		    float,
    @GenerarFaltas	    bit,
    @GenerarRetardos	bit,
    @GenerarHorasExtras	bit,
    @MovFaltas		    char(20),
    @MovRetardos	    char(20),
    @MovHorasExtras	    char(20),
    @NominaID		    int,
    @Minutos		    int,
    @Horas		        char(5),
    @Concepto		    varchar(50),
	@MovTipo            varchar(20),
	@FechaD	            datetime,
    @FechaA	            datetime,	
	-- BUG 4978
    @HerramHorasExtra	bit
	
	SELECT @MovTipo = MT.Clave 
	  FROM Asiste A 
	  JOIN MovTipo MT ON MT.Mov = A.Mov AND MT.Modulo = @Modulo
	 WHERE A.ID = @ID

  IF @Accion = 'CANCELAR'
  BEGIN
    DECLARE crCancelarNomina CURSOR FOR
     SELECT ID FROM Nomina WHERE OrigenTipo = @Modulo AND Origen = @Mov AND OrigenID = @MovID
    OPEN crCancelarNomina
    FETCH NEXT FROM crCancelarNomina INTO @NominaID
    WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
    BEGIN
      IF @@FETCH_STATUS <> -2 AND @Ok IS NULL
	  BEGIN
		IF @MovTipo = 'ASIS.C'
			IF EXISTS (SELECT * FROM MovFlujo WHERE Cancelado = 0 AND Empresa = @Empresa AND OModulo = @Modulo AND OID = @ID AND OModulo <> DModulo)
				IF @Accion = 'CANCELAR' SELECT @Ok = 60060 
		
		IF @Ok IS NULL
			EXEC spAfectar 'NOM', @NominaID, @Accion, @EnSilencio = 1, @Ok = @Ok OUTPUT, @OkRef = @OkRef OUTPUT
	  END
      FETCH NEXT FROM crCancelarNomina INTO @NominaID
    END  -- While
    CLOSE crCancelarNomina
    DEALLOCATE crCancelarNomina
  END--Cancelar 
	ELSE
  BEGIN
    SELECT @Moneda	       = ContMoneda,
           @GenerarFaltas      = AsisteGenerarFaltas,
           @GenerarRetardos    = AsisteGenerarRetardos,
           @GenerarHorasExtras = AsisteGenerarHorasExtras,
		   @HerramHorasExtra   = HerramientaHorasExtra
      FROM EmpresaCfg
     WHERE Empresa = @Empresa
    SELECT @TipoCambio = TipoCambio FROM Mon WHERE Moneda = @Moneda
  
    SELECT @MovFaltas      = NomFaltas,
           @MovRetardos    = NomRetardos,
           @MovHorasExtras = NomHorasExtras
      FROM EmpresaCfgMov
     WHERE Empresa = @Empresa    

    DECLARE crAsisteConcepto CURSOR LOCAL FOR
     SELECT DISTINCT ISNULL(RTRIM(Concepto), '') FROM AsisteD WHERE ID = @ID
    OPEN crAsisteConcepto
    FETCH NEXT FROM crAsisteConcepto INTO @Concepto
    WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
    BEGIN
      IF @@FETCH_STATUS <> -2 AND @Ok IS NULL
      BEGIN
        IF @GenerarFaltas = 1
        BEGIN           
        IF EXISTS(SELECT @NominaID, MIN(d.Renglon), d.Personal, d.Fecha, 1.0
                    FROM AsisteD d
                    JOIN Personal p ON p.Personal = d.Personal AND p.Estatus <> 'BAJA'
                   WHERE d.ID = @ID AND UPPER(d.Tipo) = 'DIAS AUSENCIA' 
				     AND ISNULL(RTRIM(d.Concepto), '') = @Concepto
					 --- BUG 6235 Las faltas justificadas no deben viajar al módulo de Nómina
                     AND ISNULL(RTRIM(d.Concepto), '') NOT IN (SELECT Concepto FROM Concepto WHERE MODULO = 'ASIS')
                GROUP BY d.Personal, d.Fecha)
        BEGIN   
		
		 SELECT @FechaD = FechaD,
		        @FechaA = FechaA
		   FROM Asiste 
		  WHERE ID = @ID 
		        
          INSERT Nomina (UltimoCambio, Sucursal, SucursalOrigen, SucursalDestino, OrigenTipo, Origen, OrigenID, Empresa, Usuario, Estatus, Mov, FechaEmision, Proyecto, UEN, Moneda, TipoCambio, Concepto)
          SELECT GETDATE(), @Sucursal, @Sucursal, @Sucursal, 'ASIS', @Mov, @MovID, @Empresa, @Usuario, 'CONFIRMAR', @MovFaltas, FechaEmision, Proyecto, UEN, @Moneda, @TipoCambio,@Concepto
            FROM Asiste WHERE ID = @ID 

          SELECT @NominaID = SCOPE_IDENTITY()
    
			  IF @Concepto = ''
			  BEGIN
					INSERT NominaD (ID, Renglon, Personal, FechaD, Cantidad)
							SELECT @NominaID, MIN(d.Renglon), d.Personal, d.Fecha, 1.0
							FROM AsisteD d
							JOIN Personal p ON p.Personal = d.Personal AND p.Estatus <> 'BAJA'
							WHERE d.ID = @ID AND UPPER(d.Tipo) = 'DIAS AUSENCIA' AND ISNULL(RTRIM(d.Concepto), '') = ISNULL(@Concepto,'')
							GROUP BY d.Personal, d.Fecha
			  END
			  IF @Concepto <> ''
			  BEGIN			      
				  INSERT NominaD (ID, Renglon, Personal, FechaD, Cantidad)
				  SELECT @NominaID, MIN(d.Renglon), d.Personal, d.Fecha, 1.0
					FROM AsisteD d
					JOIN Personal p ON p.Personal = d.Personal AND p.Estatus <> 'BAJA'
				   WHERE d.ID = @ID AND UPPER(d.Tipo) = 'DIAS AUSENCIA' AND ISNULL(RTRIM(d.Concepto), '') = ISNULL(@Concepto,'')
					 AND d.Fecha NOT IN ( SELECT D.Fecha
											FROM PersonalAsisteDifDia D
											JOIN PersonalAsisteDif A ON A.Personal = D.Personal AND A.Empresa = D.Empresa
										   WHERE D.Fecha >= @FechaD  AND D.Fecha <= @FechaA
											 --AND A.Concepto  = 'PERMISO AUSENTARSE' 
											 --- BUG 6235 Las faltas justificadas no deben viajar al módulo de Nómina
											 AND A.Concepto IN (SELECT Concepto FROM Concepto WHERE MODULO = 'ASIS')
											 AND A.tipo = 'DIAS AUSENCIA'
											 AND Permiso IS NOT NULL AND PermisoID IS NOT NULL
										 )
					AND d.Personal NOT IN (SELECT D.Personal
											FROM PersonalAsisteDifDia D
											JOIN PersonalAsisteDif A ON A.Personal = D.Personal AND A.Empresa = D.Empresa
										   WHERE D.Fecha >= @FechaD  AND D.Fecha <= @FechaA
											 --AND A.Concepto  = 'PERMISO AUSENTARSE'
											 --- BUG 6235 Las faltas justificadas no deben viajar al módulo de Nómina
											 AND A.Concepto IN (SELECT Concepto FROM Concepto WHERE MODULO = 'ASIS')
											 AND A.tipo = 'DIAS AUSENCIA'
											 AND Permiso IS NOT NULL AND PermisoID IS NOT NULL
										   )
				   GROUP BY d.Personal, d.Fecha			   		  
               END

			   IF NOT EXISTS (SELECT * FROM NominaD WHERE ID = @NominaID)
			   BEGIN
				DELETE Nomina WHERE ID = @NominaID
			   END
        END
        END
        IF @GenerarRetardos = 1
        BEGIN 
            IF EXISTS(SELECT @NominaID, MIN(d.Renglon), d.Personal, d.Fecha, 1.0
                        FROM AsisteD d
                        JOIN Personal p ON p.Personal = d.Personal AND p.Estatus <> 'BAJA'
                       WHERE d.ID = @ID AND UPPER(d.Tipo) = 'MINUTOS AUSENCIA' AND ISNULL(RTRIM(d.Concepto), '') = @Concepto
                    GROUP BY d.Personal, d.Fecha)
         BEGIN

		    SELECT @FechaD = NULL,
				   @FechaA = NULL

		 	SELECT @FechaD = FechaD,
				   @FechaA = FechaA
		      FROM Asiste 
		     WHERE ID = @ID 

          INSERT Nomina (UltimoCambio, Sucursal, SucursalOrigen, SucursalDestino, OrigenTipo, Origen, OrigenID, Empresa, Usuario, Estatus, Mov, FechaEmision, Proyecto, UEN, Moneda, TipoCambio, Concepto)
          SELECT GETDATE(), @Sucursal, @Sucursal, @Sucursal, 'ASIS', @Mov, @MovID, @Empresa, @Usuario, 'CONFIRMAR', @MovRetardos, FechaEmision, Proyecto, UEN, @Moneda, @TipoCambio, @Concepto
            FROM Asiste WHERE ID = @ID 

          SELECT @NominaID = SCOPE_IDENTITY()
      
            IF @Concepto = ''
			BEGIN
					INSERT NominaD (ID, Renglon, Personal, FechaD, Cantidad)
								SELECT @NominaID, MIN(d.Renglon), d.Personal, d.Fecha, 1.0
								FROM AsisteD d
								JOIN Personal p ON p.Personal = d.Personal AND p.Estatus <> 'BAJA'
								WHERE d.ID = @ID AND UPPER(d.Tipo) = 'MINUTOS AUSENCIA' AND ISNULL(RTRIM(d.Concepto), '') = @Concepto
								GROUP BY d.Personal, d.Fecha
			END

			IF @Concepto <> ''
			BEGIN
				INSERT NominaD (ID, Renglon, Personal, FechaD, Cantidad)
				SELECT @NominaID, MIN(d.Renglon), d.Personal, d.Fecha, 1.0
				FROM AsisteD d
				JOIN Personal p ON p.Personal = d.Personal AND p.Estatus <> 'BAJA'
				WHERE d.ID = @ID AND UPPER(d.Tipo) = 'MINUTOS AUSENCIA' AND ISNULL(RTRIM(d.Concepto), '') = @Concepto
				AND d.Fecha NOT IN ( SELECT A.Fecha 
			     					   FROM PersonalAsisteDifMin R
									   JOIN PersonalAsisteDif A ON A.Personal = R.Personal AND A.Empresa = R.Empresa
		 							  WHERE R.Fecha >= @FechaD  AND R.Fecha <=  @FechaA
										AND A.Concepto  = 'PERMISO AUSENTARSE' and A.tipo = 'MINUTOS AUSENCIA'
										AND R.Permiso IS NOT NULL AND R.PermisoID IS NOT NULL
								   )
				AND d.Personal NOT IN ( SELECT A.Personal 
										  FROM PersonalAsisteDifMin R
										  JOIN PersonalAsisteDif A ON A.Personal = R.Personal AND A.Empresa = R.Empresa
		 								 WHERE R.Fecha >= @FechaD  AND R.Fecha <=  @FechaA
										   AND A.Concepto  = 'PERMISO AUSENTARSE' and A.tipo = 'MINUTOS AUSENCIA'
										   AND R.Permiso IS NOT NULL AND R.PermisoID IS NOT NULL
									  )
					GROUP BY d.Personal, d.Fecha
			 END

			 IF NOT EXISTS (SELECT * FROM NominaD WHERE ID = @NominaID)
			 BEGIN
				DELETE Nomina WHERE ID = @NominaID
			 END
        END
        END
        IF @GenerarHorasExtras = 1 AND @HerramHorasExtra <> 1
        BEGIN            
         IF EXISTS(SELECT @NominaID, MIN(d.Renglon), d.Personal, d.Fecha, SUM(d.Cantidad)/60.0
                     FROM AsisteD d
                     JOIN Personal p ON p.Personal = d.Personal AND p.Estatus <> 'BAJA'
                    WHERE d.ID = @ID AND UPPER(d.Tipo) = 'MINUTOS EXTRAS' AND ISNULL(RTRIM(d.Concepto), '') = @Concepto
                 GROUP BY d.Personal, d.Fecha)
         BEGIN
          INSERT Nomina (UltimoCambio, Sucursal, SucursalOrigen, SucursalDestino, OrigenTipo, Origen, OrigenID, Empresa, Usuario, Estatus, Mov, FechaEmision, Proyecto, UEN, Moneda, TipoCambio, Concepto)
          SELECT GETDATE(), @Sucursal, @Sucursal, @Sucursal, 'ASIS', @Mov, @MovID, @Empresa, @Usuario, 'CONFIRMAR', @MovHorasExtras, FechaEmision, Proyecto, UEN, @Moneda, @TipoCambio, @Concepto
            FROM Asiste WHERE ID = @ID 
          SELECT @NominaID = SCOPE_IDENTITY()
    
          INSERT NominaD (ID, Renglon, Personal, FechaD, Cantidad)
          SELECT @NominaID, MIN(d.Renglon), d.Personal, d.Fecha, SUM(d.Cantidad)/60.0
            FROM AsisteD d
            JOIN Personal p ON p.Personal = d.Personal AND p.Estatus <> 'BAJA'
           WHERE d.ID = @ID AND UPPER(d.Tipo) = 'MINUTOS EXTRAS' AND ISNULL(RTRIM(d.Concepto), '') = @Concepto
           GROUP BY d.Personal, d.Fecha

          DECLARE crNominaD CURSOR LOCAL FOR
           SELECT Cantidad*60 FROM NominaD WHERE ID = @NominaID
          OPEN crNominaD
          FETCH NEXT FROM crNominaD INTO @Minutos
          WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
          BEGIN
            IF @@FETCH_STATUS <> -2 AND @Ok IS NULL
            BEGIN
              EXEC spMinutosToHoras @Minutos, @Horas OUTPUT,1
              UPDATE NominaD SET Horas = @Horas WHERE CURRENT OF crNominaD
            END

            FETCH NEXT FROM crNominaD INTO @Minutos
          END  -- While
          CLOSE crNominaD
          DEALLOCATE crNominaD
        END
      END
      END
      FETCH NEXT FROM crAsisteConcepto INTO @Concepto
    END  -- While
    CLOSE crAsisteConcepto
    DEALLOCATE crAsisteConcepto
  END
  RETURN
END
GO