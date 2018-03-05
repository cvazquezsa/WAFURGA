SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET QUOTED_IDENTIFIER OFF
SET NOCOUNT ON
SET IMPLICIT_TRANSACTIONS OFF
GO

-----------------------------------
---- J O R N A D A T I E M P O ----
-----------------------------------
EXEC spALTER_TABLE 'JornadaTiempo',	'WFGTiempoComida',	'float  NULL'
GO 
---VerJornadaTiempo JornadaTiempo

----------------------------------------------------------------------------------------------------------------------
---- M E N S A J E  E R R O R                 M E N S A J E  E R R O R                 M E N S A J E  E R R O R   ----
----------------------------------------------------------------------------------------------------------------------              
IF NOT EXISTS(SELECT * FROM MensajeLista WHERE Mensaje = 55231) INSERT INTO MensajeLista (Mensaje, Descripcion,          Tipo,     IE)
																VALUES      (55231, 'Las hora son iguales', 'ERROR', 0)
GO

-------------------------------------------------------------
---- S P W F G I N T E L I S I S N O M I N A V A L I D A ----
-------------------------------------------------------------
IF EXISTS (SELECT * FROM Sysobjects WHERE ID = Object_ID('dbo.spWFGIntelisisNominaValida') AND Type = 'P') DROP PROCEDURE dbo.spWFGIntelisisNominaValida
GO             
CREATE PROCEDURE spWFGIntelisisNominaValida				
		@ID				int,
		@iSolicitud		int,
		@Version		float,			
		@Resultado		varchar(max) = NULL OUTPUT,
		@Ok				int          = NULL OUTPUT,    
		@OkRef			varchar(255) = NULL OUTPUT						
--//WITH ENCRYPTION
AS BEGIN
--SELECT 'P'
  DECLARE 	@Texto					xml,
			@ReferenciaIS			varchar(100),
			@SubReferencia			varchar(100),					
			@Jornada				varchar(10),
			@Fecha					varchar(20),
			@Entrada				varchar(20),
			@SalidaComer			varchar(20),
			@EntradaComer			varchar(20),
			@Salida					varchar(20)																
						
  SELECT @ReferenciaIS  = Referencia,
         @SubReferencia = SubReferencia  
    FROM IntelisisService 
   WHERE ID = @ID  
      
  -----------------------------------
  ---- V A L I D A   N O M I N A ----
  -----------------------------------  
  SELECT @Jornada				= Jornada
    FROM #Jornada    	 	 	 
    
  IF NOT EXISTS(SELECT * FROM #Jornada) AND ISNULL(@OK,0) = 0																		SELECT @Ok = 60010  
  IF ISNULL(@Jornada,'')		  = ''  AND ISNULL(@OK,0) = 0																		SELECT @OK = 10010, @OkRef = ' Jornada'            
  
  IF NOT EXISTS(SELECT * FROM Personal WHERE Personal = @Jornada)  AND ISNULL(@OK,0) = 0											SELECT @OK = 20950, @OkRef = ' ' + ISNULL(@Jornada,'')
  IF ISNULL(@OK,0) <> 0
  BEGIN ---- O K
    SELECT @OkRef = Descripcion + ' ' + ISNULL(@OkRef,'') FROM MensajeLista WHERE Mensaje = @OK	  	 	
    INSERT INTO #Movimiento(Seccion,	Jornada,						Fecha,	Ok,		OKRef)
    SELECT                  'JornadaH',	ISNULL(@Jornada,'Sin Jornada'),	'',		@Ok,	@OkRef
	
	SELECT @Texto = (SELECT *
					   FROM #Movimiento
						FOR XML AUTO)
    IF @@ERROR <> 0 SET @Ok = 1          
    SELECT @Resultado = '<Intelisis Sistema="Intelisis" Contenido="Resultado" Referencia=' + CHAR(34) + ISNULL(@ReferenciaIS,'') + CHAR(34) + ' SubReferencia=' + CHAR(34) + ISNULL(@SubReferencia,'') + CHAR(34) + ' Version=' + CHAR(34) + ISNULL(CONVERT(varchar ,@Version),'') + CHAR(34) + '><Resultado IntelisisServiceID=' + CHAR(34) + ISNULL(CONVERT(varchar,@ID),'')  + CHAR(34)  + ' Ok=' + CHAR(34) + ISNULL(CONVERT(varchar,@Ok),'') + CHAR(34) + ' OkRef=' + CHAR(34) + ISNULL(@OkRef,'') + CHAR(34) + '>' + CONVERT(varchar(max),@Texto) + '</Resultado></Intelisis>'	
    RETURN
  END   ---- O K 
  DELETE FROM #Movimiento

  -------------------------------------
  -- V A L I D A   J O R N A D A D ----
  -------------------------------------  
  IF NOT EXISTS(SELECT * FROM #JornadaD) AND ISNULL(@OK,0) = 0
  BEGIN ---- J O R N A D A D   
    SET @Ok = 60010	 
	SELECT @OkRef = Descripcion + ' ' + ISNULL(@OkRef,'') FROM MensajeLista WHERE Mensaje = @OK	  	 	    
	INSERT INTO #Movimiento(Seccion,	Jornada,						Fecha,	Ok,		OKRef)
    SELECT                  'JornadaD',	ISNULL(@Jornada,'Sin Jornada'),	'',		@Ok,	@OkRef
  END   ---- J O R N A D A D
    --SELECT 'P'
  IF ISNULL(@OK,0) = 0
  BEGIN ---- D E T   
    ---------------------
	---- V A L I D A ----
	---------------------		
    --SELECT D2.Fecha FROM #JornadaD D2 WHERE D2.Entrada = '00:00' AND D2.SalidaComer = '00:00' AND D2.EntradaComer = '00:00' AND D2.Salida = '00:00'
	DECLARE CurJornadaDValida CURSOR FAST_FORWARD FOR   
    SELECT D.Fecha, D.Entrada, D.SalidaComer, D.EntradaComer, D.Salida	
      FROM #JornadaD D   
	 WHERE D.Fecha NOT IN (SELECT D2.Fecha FROM #JornadaD D2 WHERE D2.Entrada = '00:00:00' AND D2.SalidaComer = '00:00:00' AND D2.EntradaComer = '00:00:00' AND D2.Salida = '00:00:00')
      OPEN CurJornadaDValida   
     FETCH NEXT FROM CurJornadaDValida INTO @Fecha, @Entrada, @SalidaComer, @EntradaComer, @Salida	
     WHILE @@FETCH_STATUS <> -1  
     BEGIN
		--SELECT @Ok       
       IF ISNULL(@Fecha, '')      = ''								AND ISNULL(@OK,0) = ''	SELECT @OK = 10010, @OkRef = ' Fecha'
	   IF ISNULL(@Entrada,'')     = ISNULL(@EntradaComer,'')		AND ISNULL(@OK,0) = ''	SELECT @OK = 55231, @OkRef = ' Entradas: ' + @EntradaComer 
	   IF ISNULL(@Salida,'')     = ISNULL(@SalidaComer,'')			AND ISNULL(@OK,0) = ''	SELECT @OK = 55231, @OkRef = ' Salidas : ' + @SalidaComer
	   -- SELECT @Ok 	   	   
	   IF ISNULL(@OK,0) = 0 SET @Ok = 80000	   

	   SELECT @OkRef = Descripcion + ' ' + ISNULL(@OkRef,'') FROM MensajeLista WHERE Mensaje = @OK	
	     	 	
       INSERT INTO #Movimiento(Seccion,		Jornada,						Fecha,				Ok,		OKRef)
       SELECT                  'JornadaD',	ISNULL(@Jornada,'Sin Jornada'),	ISNULL(@Fecha,''),	@Ok,	@OkRef
	   SELECT @OK	= NULL, @OkRef = NULL
     FETCH NEXT FROM CurJornadaDValida INTO @Fecha, @Entrada, @SalidaComer, @EntradaComer, @Salida	
     END   
     CLOSE CurJornadaDValida  
     DEALLOCATE CurJornadaDValida	
  END   ---- D E T 
   
  IF EXISTS(SELECT * FROM #Movimiento P JOIN MensajeLista M ON M.Mensaje = P.OK AND M.Tipo <> 'INFO')
  BEGIN ---- E R R O R    D E T A L L E
    SELECT TOP(1)@OK    = Ok,
                 @OKRef = OKRef
      FROM #Movimiento P
      JOIN MensajeLista M
	    ON M.Mensaje = P.OK AND M.Tipo <> 'INFO'  
     ORDER BY P.Jornada
	     
	SELECT @Texto = (SELECT *
					   FROM #Movimiento
						FOR XML AUTO)
    IF @@ERROR <> 0 SET @Ok = 1          
    SELECT @Resultado = '<Intelisis Sistema="Intelisis" Contenido="Resultado" Referencia=' + CHAR(34) + ISNULL(@ReferenciaIS,'') + CHAR(34) + ' SubReferencia=' + CHAR(34) + ISNULL(@SubReferencia,'') + CHAR(34) + ' Version=' + CHAR(34) + ISNULL(CONVERT(varchar ,@Version),'') + CHAR(34) + '><Resultado IntelisisServiceID=' + CHAR(34) + ISNULL(CONVERT(varchar,@ID),'')  + CHAR(34)  + ' Ok=' + CHAR(34) + ISNULL(CONVERT(varchar,@Ok),'') + CHAR(34) + ' OkRef=' + CHAR(34) + ISNULL(@OkRef,'') + CHAR(34) + '>' + CONVERT(varchar(max),@Texto) + '</Resultado></Intelisis>'	
    RETURN
  END   ---- E R R O R    D E T A L L E

RETURN
END
GO


--------------------------------------------------------------
---- S P W F G I NT E L I S I S N O M I N A P R O C E S A ----
--------------------------------------------------------------

IF EXISTS (SELECT * FROM Sysobjects WHERE ID = Object_ID('dbo.spWFGIntelisisNominaProcesa') AND Type = 'P') DROP PROCEDURE dbo.spWFGIntelisisNominaProcesa
GO             
CREATE PROCEDURE spWFGIntelisisNominaProcesa 
		@ID				int,
		@iSolicitud		int,
		@Version		float,
		@Resultado		varchar(max) = NULL OUTPUT,
		@Ok				int          = NULL OUTPUT,    
		@OkRef			varchar(255) = NULL OUTPUT,
		@CambiarEstatus	int          = NULL OUTPUT				
--//WITH ENCRYPTION
AS BEGIN
--SELECT 'P'
  DECLARE 		
  		@Usuario				varchar(10),	
		@Empresa				varchar(5),
		@Estatus    			varchar(15),
		@ReferenciaIS			varchar(100),
		@SubReferencia			varchar(100),		
		@Jornada   				varchar(20),
		@FechaRegistro 			datetime,		
	    @Texto					xml
				          	 
  CREATE TABLE #Jornada(
						Jornada				varchar	(10)  NULL,
						Semana				int			  NULL,
						)
							  					  	
  CREATE TABLE #JornadaD(Fecha				varchar	(20)  NULL,
						 Entrada			varchar	(20)  NULL,
						 SalidaComer		varchar	(20)  NULL,
						 EntradaComer		varchar	(20)  NULL,
						 Salida				varchar	(20)  NULL,
						 TiempoComida		float		  NULL,
						)
  									
  CREATE TABLE #Movimiento (Seccion				varchar	(20)  NULL,
							Jornada				varchar	(10)  NULL,							
							Fecha				varchar	(20)  NULL,							
							Ok					int			  NULL,
							OKRef				varchar	(255) NULL)

  SELECT @ReferenciaIS  = Referencia,
         @SubReferencia = SubReferencia,
		 @Usuario       = Usuario
    FROM IntelisisService 
   WHERE ID = @ID
  
  SELECT @FechaRegistro = GETDATE()
    
  ---------------
  ---- X M L ----
  ---------------					    
  INSERT INTO #Jornada(Jornada,								Semana)	
  SELECT               Jornada,								Semana
    FROM OPENXML (	   @iSolicitud, '/Intelisis/Solicitud/JornadaH',1)  
    WITH (		       Jornada				varchar(10),	Semana	int)
					  	
  INSERT INTO #JornadaD(	Fecha,							Entrada,					SalidaComer,				EntradaComer,					Salida,							
							TiempoComida)
  SELECT                    Fecha,							Entrada,					SalidaComer,				EntradaComer,					Salida,							
							TiempoComida
    FROM OPENXML (@iSolicitud, '/Intelisis/Solicitud/JornadaH/JornadaD',1)   
    WITH (					Fecha			varchar(20),	Entrada	varchar(20),		SalidaComer	varchar(20),	EntradaComer	varchar(20),	Salida		varchar(20),							
							TiempoComida	float)

    --UPDATE #JornadaD SET Fecha= CONVERT(varchar(20),CONCAT(SubString(REPLACE(Fecha,' ',''),1,4),SubString(REPLACE(Fecha,' ',''),9,2),SubString(REPLACE(Fecha,' ',''),6,2)))
    --FROM #JornadaD 
    --SELECT * fROM #JornadaD 
  ---------------------------------
  ---- V A L I D A C I O N E S ----
  ---------------------------------  
  SELECT @Jornada = Jornada FROM #Jornada
  --SELECT 'Q'
  EXEC spWFGIntelisisNominaValida @ID, @iSolicitud, @Version, @Resultado OUTPUT, @Ok OUTPUT, @OkRef OUTPUT 
    --SELECT @Jornada
	--SELECT 'R'   
  IF ISNULL(@OK, 0) <> 0 OR EXISTS(SELECT * FROM #Movimiento P JOIN MensajeLista M ON M.Mensaje = P.OK AND M.Tipo <> 'INFO')
  BEGIN --- E R R O R   C O M P R A D
	SELECT @CambiarEstatus = 1
    RETURN
  END   --- E R R O R   C O M P R A D
  DELETE FROM #Movimiento      
  -----------------------------------        
  SELECT @CambiarEstatus = 1
  --SELECT @Ok
  IF ISNULL(@Ok,0) = 0
  BEGIN       				    	
	--SELECT * FROM #JornadaD JD
	--SELECT * FROM JornadaTiempo WHERE Jornada = @Jornada-- AND Fecha IN (SELECT CONVERT(datetime,JD.Fecha,103) FROM #JornadaD JD) ---- B O R R A M O S  F E C H A S  
	DELETE FROM JornadaTiempo WHERE Jornada = @Jornada AND Fecha IN (SELECT CONVERT(datetime,JD.Fecha,103) FROM #JornadaD JD) ---- B O R R A M O S  F E C H A S  
	 
	DELETE FROM #JornadaD     WHERE Entrada = '00:00:00' AND SalidaComer = '00:00:00' AND EntradaComer = '00:00:00' AND Salida = '00:00:00'	
	--SELECT * FROM #JornadaD
    UPDATE #JornadaD SET SalidaComer = NULL WHERE ISNULL(SalidaComer,'') = ''
	UPDATE #JornadaD SET Salida      = NULL WHERE ISNULL(Salida,'') = ''
	--SELECT 'P'
	INSERT INTO  JornadaTiempo (Jornada,	Entrada,										Salida,															Fecha,								WFGTiempoComida)
	SELECT						@Jornada,	CONVERT(datetime,Fecha +' '+ Entrada,103),		CONVERT(datetime,Fecha +' '+ ISNULL(Salida,''),103),	CONVERT(datetime,Fecha,103),				TiempoComida
	  FROM #JornadaD
	 WHERE ISNULL(Entrada,'') <> ''
	 ORDER BY CONVERT(datetime,Fecha,103)

	--INSERT INTO  JornadaTiempo (Jornada,	Entrada,										Salida,															Fecha,								WFGTiempoComida)
	--SELECT						@Jornada,	CONVERT(datetime,Fecha +' '+ EntradaComer,103),	CONVERT(datetime,Fecha+' '+ ISNULL(Salida,''),103),				CONVERT(datetime,Fecha,103),		TiempoComida
	--  FROM #JornadaD
	-- WHERE ISNULL(EntradaComer,'') <> ''
	-- ORDER BY CONVERT(datetime,Fecha,103)   
	 
  END       
  -------------------------
  IF (ISNULL(@Ok,0) = 0) SELECT @Ok = 80081
  
  IF NOT EXISTS(SELECT * FROM #Movimiento)    
  BEGIN --- M O V
    SELECT @OkRef = LTRIM(RTRIM(Descripcion)) + '.' + ISNULL(@OkRef,'') + '.' + ISNULL(@SubReferencia,'') FROM MensajeLista WHERE Mensaje = @Ok
	
    IF EXISTS(SELECT * FROM JornadaTiempo WHERE Jornada = @Jornada AND Fecha IN (SELECT CONVERT(datetime,JD.Fecha,103) FROM #JornadaD JD))
      INSERT INTO #Movimiento (Seccion,		Jornada,						Fecha,	OK,		OKRef)	
      SELECT				   'Afectar',	ISNULL(@Jornada,'Sin Jornada'),	Fecha,	@Ok,	@OkRef
	    FROM #JornadaD
    ELSE
      INSERT INTO #Movimiento (Seccion,		Jornada,						Fecha,	OK,		OKRef)	
      SELECT				   'Afectar',	ISNULL(@Jornada,'Sin Jornada'),	'',		@Ok,	@OkRef
  END   --- M O V 
     
  IF (ISNULL(@Ok,0) = 0) SELECT @OkRef = NULL     
  IF EXISTS(SELECT * FROM MensajeLista WHERE Mensaje = @Ok AND Tipo <>'INFO') DELETE FROM Nomina WHERE ID = 1 AND Estatus NOT IN('CONCLUIDO','CANCELADO')--- T R I G G E R  B O R R A  D E T		
  SELECT @Texto = ( 
				  SELECT *
				    FROM #Movimiento 
				     FOR XML AUTO)	  

  IF EXISTS(SELECT * FROM MensajeLista WHERE Mensaje = @Ok AND Tipo = 'INFO') SELECT @Ok = NULL, @OkRef = NULL       
  IF @@ERROR <> 0 SET @Ok = 1
  BEGIN    
    IF @@ERROR <> 0 SET @Ok = 1          
    SELECT @Resultado = '<Intelisis Sistema="Intelisis" Contenido="Resultado" Referencia=' + CHAR(34) + ISNULL(@ReferenciaIS,'') + CHAR(34) + ' SubReferencia=' + CHAR(34) + ISNULL(@SubReferencia,'') + CHAR(34) + ' Version=' + CHAR(34) + ISNULL(CONVERT(varchar ,@Version),'') + CHAR(34) + '><Resultado IntelisisServiceID=' + CHAR(34) + ISNULL(CONVERT(varchar,@ID),'')  + CHAR(34)  + ' Ok=' + CHAR(34) + ISNULL(CONVERT(varchar,@Ok),'') + CHAR(34) + ' OkRef=' + CHAR(34) + ISNULL(@OkRef,'') + CHAR(34) + '>' + CONVERT(varchar(max),@Texto) + '</Resultado></Intelisis>'	  
    IF @@ERROR <> 0 SET @Ok = 1  	      
  END

RETURN
END
GO


--BEGIN TRANSACTION nomina
--DECLARE  @Resultado		varchar(max),   
--		 @Archivo		varchar(max),
--		 @Usuario		varchar(10),
--		 @Contrasena	varchar(32),
--		 @Ok			int	,
--		 @ID			int	,
--		 @OkRef			varchar(255)

--SELECT @Usuario = 'INTELISIS', @Contrasena = 'f03652fb45e13091d4436787753dab55', 
--@Archivo = '<?xml version="1.0" encoding="Windows-1252"?> 
--              <Intelisis Sistema="Intelisis" Contenido="Solicitud" Referencia="Intelisis.Procesa.Nomina" SubReferencia="Generacion Jornadas" Version="1.0">   
--              <Solicitud>     
--                <JornadaH Jornada="0701" Semana="05" Empresa="E003">       
--                  <JornadaD Fecha="29/01/2018" Entrada="00:00:00" SalidaComer="00:00:00" EntradaComer="00:00:00" Salida="00:00:00" TiempoComida="00"/>       
--                  <JornadaD Fecha="30/01/2018" Entrada="10:00:00" SalidaComer="13:00:00" EntradaComer="14:00:00" Salida="21:00:00" TiempoComida="60"/>       
--                  <JornadaD Fecha="31/01/2018" Entrada="13:00:00" SalidaComer="00:00:00" EntradaComer="00:00:00" Salida="21:00:00" TiempoComida="0"/>       
--                  <JornadaD Fecha="01/02/2018" Entrada="10:00:00" SalidaComer="13:00:00" EntradaComer="14:00:00" Salida="21:00:00" TiempoComida="60"/>       
--                  <JornadaD Fecha="02/02/2018" Entrada="10:00:00" SalidaComer="13:00:00" EntradaComer="14:00:00" Salida="21:00:00" TiempoComida="60"/>       
--                  <JornadaD Fecha="03/02/2018" Entrada="10:00:00" SalidaComer="13:00:00" EntradaComer="14:00:00" Salida="21:00:00" TiempoComida="60"/>       
--                  <JornadaD Fecha="04/02/2018" Entrada="10:00:00" SalidaComer="13:00:00" EntradaComer="14:00:00" Salida="21:00:00" TiempoComida="60"/>     
--                </JornadaH>   
--              </Solicitud> 
--              </Intelisis> '

--EXEC spIntelisisService @Usuario,@Contrasena,@Archivo, @Resultado OUTPUT, @Ok OUTPUT, @OkRef OUTPUT, 1, 0, @ID OUTPUT
--SELECT @Ok, @OkRef, @Resultado, @ID
----SELECT * FROM usuario WHERE Usuario='Intelisis'
------SELECT * FROM JornadaTiempo where jornada = 'p0002'
----SELECT @Ok, @OkRef
----SELECT * FROM VERJornadaTiempo  where jornada = '00190' and mes =1 and dia in(8,9,10,11,12,13,14) aND ano=2018
----select len(Solicitud),Solicitud,* from IntelisisService where id > 1194
--ROLLBACK transaction nomina
--<Intelisis Sistema="Intelisis" Contenido="Resultado" Referencia="Intelisis.Procesa.Nomina" SubReferencia="Generacion Jornadas" Version="1"><Resultado IntelisisServiceID="1348" Ok="" OkRef=""><_x0023_Movimiento Seccion="Afectar" Jornada="0701" Fecha="29/01/2018" Ok="80081" OKRef="Operación Afectada..Generacion Jornadas"/><_x0023_Movimiento Seccion="Afectar" Jornada="0701" Fecha="30/01/2018" Ok="80081" OKRef="Operación Afectada..Generacion Jornadas"/><_x0023_Movimiento Seccion="Afectar" Jornada="0701" Fecha="31/01/2018" Ok="80081" OKRef="Operación Afectada..Generacion Jornadas"/><_x0023_Movimiento Seccion="Afectar" Jornada="0701" Fecha="01/02/2018" Ok="80081" OKRef="Operación Afectada..Generacion Jornadas"/><_x0023_Movimiento Seccion="Afectar" Jornada="0701" Fecha="02/02/2018" Ok="80081" OKRef="Operación Afectada..Generacion Jornadas"/><_x0023_Movimiento Seccion="Afectar" Jornada="0701" Fecha="03/02/2018" Ok="80081" OKRef="Operación Afectada..Generacion Jornadas"/><_x0023_Movimiento Seccion="Afectar" Jornada="0701" Fecha="04/02/2018" Ok="80081" OKRef="Operación Afectada..Generacion Jornadas"/></Resultado></Intelisis>

