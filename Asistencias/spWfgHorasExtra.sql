SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF

if exists (select * from sysobjects where id = object_id('dbo.spWfgHorasExtra') and type = 'P') drop procedure dbo.spWfgHorasExtra
GO
CREATE PROCEDURE spWfgHorasExtra  
@Empresa       char(5),  
@Sucursal      int,  
@Modulo        char(5),  
@ID            int,  
@Estatus       char(15),  
@EstatusNuevo  char(15),  
@Usuario       char(10),  
@FechaEmision  datetime,  
@FechaRegistro datetime,  
@Mov           char(20),  
@MovID         varchar(20),  
@MovTipo       char(20),  
@IDGenerar     int,  
@Ok            int  OUTPUT,  
@OkRef         varchar(255) OUTPUT
AS
BEGIN  

	DECLARE
		@FechaD datetime,
		@FechaA datetime,
		@MovGenerar varchar(20) = 'Horas Extras Sem1',
		@Concepto varchar(50),
		@Moneda varchar(10),
		@EstatusGenerar varchar(20) = 'BORRADOR',
		@IDNom int,
		@FechaIns datetime,
		@DiaNum int = 0,
		@Renglon float = 0

	DECLARE @WfgPersonalAsiste TABLE (
		Empresa varchar(5),
		Personal varchar(20),
		Minutos int,
		MinutosJornada int,
		MinutosExtra int,
		HorasExtras float
		)
	DECLARE @WfgInsertar TABLE (
		Empresa varchar(5),
		Personal varchar(20),
		HorasExtras float
		)

	SELECT @Moneda=ContMoneda FROM EmpresaCfg WHERE Empresa=@Empresa
	SELECT @FechaD=FechaD, @FechaA=FechaA FROM Asiste WHERE Id=@ID
	SELECT @FechaIns = @FechaD

	INSERT INTO @WfgPersonalAsiste (Empresa, Personal, Minutos, MinutosJornada)
		SELECT
		  pa.Empresa,
		  pa.Personal,
		  SUM(DATEDIFF(mi,pa.Entrada,pa.Salida)) Minutos,
		  ISNULL(j.HorasSemana,0)*60
		  FROM PersonalAsiste pa
			JOIN Personal p ON pa.Personal=p.Personal
			JOIN Jornada j ON p.Jornada=j.Jornada
		  WHERE pa.Fecha >=@FechaD AND pa.Fecha<=@FechaA AND pa.Empresa=@Empresa
		  GROUP BY pa.Empresa,pa.Personal, j.horasSemana

	DELETE @WfgPersonalAsiste WHERE ISNULL(MinutosJornada,0)=0
	UPDATE @WfgPersonalAsiste SET MinutosExtra = Minutos - ISNUll(MinutosJornada,0)
	UPDATE @WfgPersonalAsiste SET HorasExtras = ROUND(CONVERT(float,MinutosExtra)/30,0)/2 --Redondea hacia abajo, aqui posiblemente hay que ajustar a redondeo o fracción
	
	INSERT INTO @WfgInsertar
		SELECT Empresa, Personal, HorasExtras FROM @WfgPersonalAsiste
	
	SELECT @FechaIns = @FechaD
	
	WHILE EXISTS (SELECT * FROM @WfgInsertar WHERE HorasExtras>0)
	BEGIN --exists
		SELECT @DiaNum+=1
		SELECT @Concepto = CONCAT('Dia ', @DiaNum)
		
		INSERT INTO Nomina 
			(Empresa,  Mov,			FechaEmision,	Concepto,	Moneda,	TipoCambio,	Usuario,  Estatus,			Ejercicio,
			Periodo,					FechaRegistro)
		SELECT
			@Empresa, @MovGenerar,  @FechaIns,	@Concepto,	@Moneda,1,			@Usuario, @EstatusGenerar,	DATEPART(yy, @FechaIns),
		DATEPART(mm, @FechaIns),GETDATE()
		
		SELECT @IDNom = SCOPE_IDENTITY()
		IF @DiaNum<=3
		BEGIN--@DiaNum<=3
			INSERT INTO NominaD
				(ID,Renglon, Modulo, Personal, Horas, Cantidad, FechaD)
			SELECT 
				@IDNom,
				(ROW_NUMBER() OVER(ORDER BY Empresa,Personal))*2048, 
				'NOM',
				Personal,
				TIMEFROMPARTS(CASE WHEN HorasExtras >= 3 THEN 3 ELSE FLOOR(HorasExtras) END,CASE WHEN HorasExtras >= 3 THEN 0 ELSE HorasExtras-FLOOR(HorasExtras) END,0,0,0),
				CASE WHEN HorasExtras >= 3 THEN 3 ELSE HorasExtras END,
				@FechaIns 
				FROM @wfgInsertar
				WHERE HorasExtras>0
			UPDATE @WfgInsertar SET HorasExtras=CASE WHEN HorasExtras-3 <0 THEN 0 ELSE HorasExtras-3 END
		END--@DiaNum<=3
		ELSE
		BEGIN--@DiaNum>3
			INSERT INTO NominaD
				(ID,Renglon, Modulo, Personal, Horas, Cantidad, FechaD)
			SELECT 
				@IDNom,
				(ROW_NUMBER() OVER(ORDER BY Empresa,Personal))*2048, 
				'NOM',
				Personal,
				TIMEFROMPARTS(FLOOR(HorasExtras),(HorasExtras - FLOOR(HorasExtras))*60,0,0,0),
				HorasExtras,
				@FechaIns 
				FROM @wfgInsertar
				WHERE HorasExtras>0
			UPDATE @WfgInsertar SET HorasExtras=0
		END--@DiaNum>3
		--SELECT * FROM @WfgInsertar
		SELECT @FechaIns = DATEADD(dd,1,@FechaIns)

		--SELECT * FROM NominaD wHERE ID=@IDNom
	END--exists

	--SELECT * FROm Nomina WHERE Mov='Horas Extras Sem1' AND Id=3883
	--SELECT * FROm NominaD WHERE Id=3883
	
	return
END
GO

--BEGIN TRANSACTION
--	EXEC spAfectar 'ASIS', 169, 'AFECTAR', 'Todo', NULL, 'INTELISIS'--, @Estacion=16
--IF @@TRANCOUNT>0
--	ROLLBACK

