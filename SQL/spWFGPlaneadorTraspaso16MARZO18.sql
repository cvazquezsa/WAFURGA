SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
GO

/**************** spWFGPlaneadorTraspaso ****************/
IF EXISTS (select * from sysobjects where id = object_id('dbo.spWFGPlaneadorTraspaso') and type = 'P') drop procedure dbo.spWFGPlaneadorTraspaso
GO
CREATE PROCEDURE spWFGPlaneadorTraspaso
@FechaD     datetime=NULL,
@FechaA     datetime=NULL,
@Empresa    varchar(5),
@DiasSurtir int 

--//WITH ENCRYPTION

AS BEGIN
  DECLARE @MinVVP                float,
          @MaxVVP                float,
          @MinVM                 float,
          @MaxVM                 float,
          @MinPeV                float,
          @MaxPeV                float,
          @TotalExistencia       float,
          @MinPe                 float,
          @MaxPe                 float,
          @ExistenciaSucTraspaso float,
          @ExistenciaTotalSuc    float,
          @ID                    int,
          @SucursalO             int,
          @SucursalD             int,
          @SiTraspasa            bit,
          @CantidadATraspasar    float,
          @ExistenciaActual      float,
          @RecibeTraspaso        bit,
          @IDMin                 int,
          @IDMax                 int,
          @SumatoriaVvp          float,
          @PorcVvp               float,
          @ArticuloO             varchar(20),
          @ArticuloD             varchar(20),
          @TotalCantidadTraspaso float,
          @RestaCantidadTraspaso float,
          @Fecha                 datetime,
          @AlmacenO              varchar(20),
          @AlmacenD              varchar(20),
          @ParteDecimal          float,
		  @TraspasoOK            bit,
          @CantidadInt           int, 
          @CantidadDec           float,
          @ExistenciaTotal       float,
          @ArtDec                varchar(20), 
          @TotalDec              float,
          @IDTraspaso            int,
          @SucDec                int,
		  @Suc                   int,
          @Art                   varchar(20),
          @Existencias           float,
		  @Subcuenta             varchar(50),
		  @SubcuentaD            varchar(50),
		  @SubCuentaDec          varchar(50),
		  @Subcuenta2            varchar(50),
		  @Sucursal              int, 
		  @Articulo              varchar(20), 
		  @Opcion                varchar(50), 
		  @Existencia            float, 
		  @InvDia                float,
		  @CantTrasp             float,
		  @CantTraspTotal        float,
		  @Ciclo                 int,
		  @CicloMax              int,
		  @CantTraspasa          float,
		  @Stock                 float,
		  @CalifFinal            float,
		  @NumReg                float,
		  @CantProp              float,
		  @TotalCantTrasp        float,
		  @Sucursal1             int, 
		  @Articulo1             varchar(20), 
		  @Opcion1               varchar(50), 
		  @CantTraspasa1         float,
		  @ExistenciaArt         float,
		  @CantDisponible        float,
		  @CalifFinalMax         float,
          @SucMax                int,
          @InvXDiaAnt            float,
          @InvXDiaR              float,
          @SucursalAnt	         int,
          @SucursalC             int,
          @CantidadR             float,
          @CantidadTraspasar     float,
          @CantidadT             float,
          @CantTraspasar         float,
          @CantidadRestante      float,
          @PropTraspaso          float,
		  @TotalExistInvXDia0    float,
          @Recibir1              float,
          @B                     float,
		  @Art2                  varchar(20), 
		  @Subcuenta1            varchar(50), 
		  @Suc2                  int, 
		  @Diferencia            float,
		  @TotalExistInvXDia02   float,
		  @SumCalifFinal         float,
		  @TotalInvXDia          float    

  SET @Fecha=dbo.fnFechaSinHora(GETDATE())
  
  DELETE FROM WFGPlaneadorTraspaso
  DELETE from WFGTraspaso

  IF @FechaD IS NULL SELECT @FechaD = MIN(FechaEmision) FROM WFGPlaneadorTraspasoJob 
  IF @FechaA IS NULL SELECT @FechaA = MAX(FechaEmision) FROM WFGPlaneadorTraspasoJob 

  -----------------------------------------------------------
  ---- C R E A C I O N  T A B L A S  T E M P O R A L E S ----
  -----------------------------------------------------------
  CREATE TABLE #WFGPlaneadorTraspasoJob ( Articulo       varchar(20) NULL,
                                          Sucursal       int         NULL,
                                          Cantidad       float       NULL,
										  Subcuenta      varchar(50) NULL)

 CREATE TABLE #PasoVVP ( Sucursal     int         NULL, 
                         Articulo     varchar(20) NULL, 
						 Subcuenta    varchar(50) NULL,
						 VVP          float       NULL, 
                         VM           float       NULL, 
                         TotalVtas    float       NULL) 

  CREATE TABLE #PasoInvXDia ( Sucursal     int         NULL, 
                              Articulo     varchar(20) NULL, 
						      Subcuenta    varchar(50) NULL,
							  InvXDia      float       NULL) 

  CREATE TABLE #PasoCalificaciones ( Sucursal     int         NULL, 
                                     Articulo     varchar(20) NULL, 
									 Subcuenta    varchar(50) NULL,
                                     VVP          float       NULL,
									 CalifVVP     float       NULL, 
									 VM           float       NULL, 
                                     CalifVM      float       NULL, 
                                     TotalVtas    float       NULL, 
                                     Existencia   float       NULL)

  CREATE TABLE #PasoCalPeV ( Sucursal     int         NULL, 
                             Articulo     varchar(20) NULL, 
							 Subcuenta    varchar(50) NULL,
                             Existencia   float       NULL,
                             PeV          float       NULL) 

  CREATE TABLE #TotalExistencia ( Sucursal          int         NULL,
                                  Articulo          varchar(20) NULL,
                                  Subcuenta         varchar(50) NULL,
                                  TotalExistencia   float       NULL) 
								
  CREATE TABLE #PasoPe  ( Sucursal     int         NULL, 
                          Articulo     varchar(20) NULL, 
						  Subcuenta    varchar(50) NULL,
                          Pe           float       NULL) 						

  CREATE TABLE #WFGPlaneadorTraspaso ( Sucursal          int           NULL,
                                       Articulo          varchar(20)   NULL,
									   Subcuenta         varchar(50)   NULL,
                                       VVP               float         NULL,
                                       CalificacionVVP   float         NULL,
                                       VelocidadMaxima   float         NULL,
                                       CalificacionVM    float         NULL,
                                       TotalVentas       float         NULL,
                                       ExistenciaActual  float         NULL,
                                       PeV               float         NULL,
                                       CalificacionPeV   float         NULL,
                                       PeF               float         NULL,
                                       CalificacionPeF   float         NULL)

  CREATE TABLE #CantidadATraspasar ( Sucursal               int         NULL, 
                                     Articulo               varchar(20) NULL, 
									 Subcuenta              varchar(50) NULL,
                                     Porcentaje             float       NULL,
                                     CantidadATraspasar     int         NULL,
									 CantidadATraspasarDec  float       NULL)								   

  CREATE TABLE #PorcentajeVvp ( Sucursal      int         NULL, 
                                Articulo      varchar(20) NULL, 
								Subcuenta     varchar(50) NULL,
                                PorcentajeVvp float       NULL)

  CREATE TABLE #Minimos ( Articulo  varchar(20) NULL, 
                          Subcuenta varchar(50) NULL,
                          MinVvp    float       NULL,
                          MaxVvp    float       NULL,
                          MinVm     float       NULL,
                          MaxVm     float       NULL,
                          MinPeV    float       NULL,
                          MaxPeV    float       NULL,
                          MinPe     float       NULL,
                          MaxPe     float       NULL) 						

  CREATE TABLE #TotalExistenciaMenorIgual2 (Articulo   varchar(20) NULL, 
                                            Subcuenta  varchar(50) NULL, 
											Existencia float       NULL) 
											 
  CREATE TABLE #SumaVvp (Articulo  varchar(20) NULL, 
                         Subcuenta varchar(50) NULL, 
						 SumaVvp   float       NULL)

  CREATE TABLE #Traspasos ( AlmacenO            varchar(20) NULL,
                            AlmacenD            varchar(20) NULL,
                            SucursalO           int         NULL,
                            SucursalD           int         NULL,
                            Articulo            varchar(20) NULL,
							Subcuenta           varchar(50) NULL,
                            CantidadTraspasada  float       NULL)

  CREATE TABLE #TotalDecimal (TotalDecimal float       NULL, 
                              Articulo     varchar(20) NULL, 
							  Subcuenta    varchar(50) NULL)

  CREATE TABLE #InsertaTraspaso(ID          int         NULL, 
                                Articulo    varchar(20) NULL, 
								Subcuenta   varchar(50) NULL, 
								SucursalO   int         NULL, 
								AlmacenD    varchar(20) NULL, 
								SucursalD   int         NULL, 
								CantidadInt float       NULL, 
								CantidadDec float       NULL)

  CREATE TABLE #SucOrdenCalifFinal (Sucursal  int         NULL, 
                                    Articulo  varchar(20) NULL, 
									Subcuenta varchar(50) NULL, 
									CalifFinal float      NULL)
  
  CREATE TABLE #CantidadTraspasar (Sucursal     int         NULL, 
                                   Articulo     varchar(20) NULL, 
								   Subcuenta    varchar(50) NULL, 
								   Existencia   float       NULL, 
								   PDInv        float       NULL,  
								   CantTraspasa float       NULL, 
								   Ciclo        int         NULL, 
								   CalifFinal   float       NULL)

  CREATE TABLE #WFGCantidadTraspasar   (Sucursal int NULL,   Articulo varchar(20) NULL, Subcuenta  varchar(50) NULL, Existencia        float NULL, CalifFinal   float NULL, InvXDia  float NULL, 
                                        Ciclo    int NULL,   Stock    float       NULL, Proporcion float       NULL, CantidadTraspasar float NULL, TotalInvXDia float NULL, Excluido bit   NULL)
  CREATE TABLE #WFGCantTraspasaCicloMax(Sucursal int NULL,   Articulo varchar(20) NULL, Subcuenta  varchar(50) NULL, Existencia        float NULL, CalifFinal   float NULL, InvXDia  float NULL, 
                                        Ciclo    int NULL,   Stock    float       NULL, CantidadTraspasar float NULL)
  CREATE TABLE #StockMinimo            (Sucursal int NULL,   Articulo varchar(20) NULL, Subcuenta varchar(50)  NULL, Stock             float NULL)
  CREATE TABLE #CantTraspaso           (Sucursal int NULL,   Articulo varchar(20) NULL, Subcuenta varchar(50)  NULL, Existencia        float NULL, CalifFinal   float NULL, InvXDia  float NULL)
  CREATE TABLE #CicloMax               (CicloMax int NULL,   Articulo varchar(20) NULL, Subcuenta varchar(50)  NULL, Sucursal          int   NULL)
  CREATE TABLE #TotalInvXDia           (InvXDia  float NULL, Articulo varchar(20) NULL, Subcuenta varchar(50)  NULL)
  CREATE TABLE #Recibir1               (Sucursal int   NULL, Articulo varchar(20) NULL, Subcuenta varchar(50)  NULL,  Cantidad float NULL)
  CREATE TABLE #Recibir2               (Sucursal int   NULL, Articulo varchar(20) NULL, Subcuenta varchar(50)  NULL,  Cantidad float NULL)
  CREATE TABLE #SumCalifFinal          (Articulo varchar(20) NULL, SubCuenta varchar(50) NULL, CalifFinal float NULL)
  CREATE TABLE #Recibir3               (Articulo varchar(20) NULL, SubCuenta varchar(50) NULL, Sucursal   int NULL, Cantidad float NULL)
  CREATE TABLE #Reparte                (Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, Sucursal   int NULL, Cantidad float NULL, InvXDia float null )
  CREATE TABLE #PropCantidadTraspasa   (Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, Sucursal   int NULL, CantidadTraspasar float NULL)
  CREATE TABLE #SucCalifMax            (Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, Sucursal   int NULL, CalifMax          float NULL)
  CREATE TABLE #SumaCantDec            (Articulo varchar(20) NULL, Subcuenta varchar(20) NULL, CantidadTraspasaDec float NULL)
  CREATE TABLE #Disponible             (Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, Sucursal int NULL, Disponible float NULL)
  CREATE TABLE #WfgPrioridadNum        (Prioridad int NULL, SucursalO int NULL, NombreSucO varchar(255) NULL, SucursalD int NULL, NombreSucD varchar(255) NULL)
  CREATE TABLE #WfgPrioridadNum2       (ID        int NULL, SucursalO int NULL, NombreSucO varchar(255) NULL, SucursalD int NULL, NombreSucD varchar(255) NULL)

  --------------------------------------------------------------------------------------------

  INSERT INTO #WFGPlaneadorTraspasoJob ( Sucursal,   Articulo,   Cantidad,        Subcuenta)
                                  SELECT w.Sucursal, w.Articulo, SUM(w.Cantidad), ISNULL(w.Subcuenta,'')
                                  FROM WFGPlaneadorTraspasoJob w
								  JOIN Art a ON w.Articulo=a.Articulo  
								  WHERE w.FechaEmision BETWEEN @FechaD AND @FechaA AND
								  a.Estatus='ALTA' AND ISNULL(a.WFGArtPlaneador,0)=1 AND w.Empresa=@Empresa
								  AND w.Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad)
								  GROUP BY w.Sucursal, w.Articulo, ISNULL(w.Subcuenta,'')
  --select * from #WFGPlaneadorTraspasoJob --where articulo='FL900'

  /************VELOCIDAD DE VENTA PROMEDIO*************/
  INSERT INTO #PasoVVP ( Sucursal, Articulo, Subcuenta,
                         VVP,      
                         VM,       
                         TotalVtas)
                  SELECT w.Sucursal, w.Articulo, ISNULL(w.Subcuenta,''),
				         SUM(w.Cantidad)/(DATEDIFF(dd,@FechaD, @FechaA)+1),--Se sumo 1 en el denominador debido a que Faltaba 1 unidad en la diferencia de fechas
                         MAX(w.Cantidad), 
						 SUM(w.Cantidad) 
                  FROM WFGPlaneadorTraspasoJob w
  			      JOIN Art a ON w.Articulo=a.Articulo 
				  WHERE FechaEmision BETWEEN @FechaD AND @FechaA
				  AND w.Empresa=@Empresa AND a.Estatus='ALTA'
				  AND ISNULL(a.WFGArtPlaneador,0)=1
				  AND w.Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad)
				  GROUP BY w.Sucursal, w.Articulo, ISNULL(w.Subcuenta,'')
  --select * from #PasoVVP where ARTICULO='FL900'

  INSERT INTO #Minimos (Articulo, Subcuenta,  MinVvp,   MaxVvp,   MinVm,   MaxVm)
                 SELECT Articulo, Subcuenta, MIN(VVP), MAX(VVP),  MIN(VM), MAX(VM) 
                 FROM #PasoVVP 
				 GROUP BY Articulo, Subcuenta
  --select * from #Minimos where articulo='fl900' --and subcuenta='c1t2'  

  INSERT INTO #PasoCalificaciones ( Sucursal,   Articulo,    Subcuenta,   VVP,   VM,    TotalVtas,       
                                    CalifVVP, 
									CalifVM,
									Existencia)
                             SELECT w.Sucursal, w.Articulo,  w.Subcuenta, p.VVP, p.VM,  TotalVtas,        
                                    CASE WHEN ISNULL(m.MaxVVP,0)=ISNULL(m.MinVVP,0) THEN 3 ELSE (((p.VVP-m.MinVVP)/(m.MaxVVP-m.MinVVP))*3) END CalifVVP, 
                                    CASE WHEN ISNULL(m.MaxVM,0)=ISNULL(m.MinVM,0) THEN 3 ELSE (((p.VM-m.MinVM)/(m.MaxVM-m.MinVM))*3) END CalifVM, 
									disponible.Existencias
                             FROM #WFGPlaneadorTraspasoJob w
                             JOIN #PasoVVP p ON w.Sucursal=p.Sucursal AND w.Articulo=p.Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(p.Subcuenta,'')
                             JOIN #Minimos m ON w.Articulo=m.Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(m.Subcuenta,'')
							 JOIN (SELECT Empresa, Sucursal, Cuenta, ISNULL(SubCuenta,'') SubCuenta, SUM(CASE WHEN Rama='INV' THEN SaldoU WHEN Rama='VMOS' THEN -SaldoU END) Existencias		
							       FROM SaldoU
		                           GROUP BY Empresa, Sucursal,  Cuenta, SubCuenta) disponible on w.Articulo=disponible.Cuenta AND ISNULL(w.Subcuenta,'')=ISNULL(disponible.SubCuenta,'') AND w.Sucursal=disponible.Sucursal
  --SELECT * FROM #PasoCalificaciones WHERE ARTICULO='FL900'

  INSERT INTO #PasoCalPeV ( Sucursal, Articulo, Subcuenta, Existencia, 
                            PeV)
                     SELECT Sucursal, Articulo, Subcuenta, CASE WHEN Existencia<0 THEN 0 ELSE Existencia END, 
					 (CASE WHEN 
					          (CASE WHEN Existencia<0 THEN 0 ELSE Existencia END + CASE WHEN TotalVtas<0 THEN 0 ELSE TotalVtas END)=0 
						   THEN 1 
						   ELSE 
						      (CASE WHEN Existencia<0 THEN 0 ELSE Existencia END/(CASE WHEN Existencia<0 THEN 0 ELSE Existencia END+CASE WHEN TotalVtas<0 THEN 0 ELSE TotalVtas END)
							  ) END *100) PeV
                     FROM #PasoCalificaciones
  --SELECT * FROM #PasoCalPeV where ARTICULO='FL900'--subcuenta='c1t2' order by sucursal, subcuenta, peV

  UPDATE m SET m.MinPeV=Minimo, MaxPeV=Maximo
  FROM (SELECT Articulo, Subcuenta, MIN(PeV) minimo , MAX(PeV) maximo
        FROM #PasoCalPeV
        GROUP BY Articulo, Subcuenta)a
  JOIN #Minimos m on a.Articulo=m.Articulo AND ISNULL(a.Subcuenta,'')=ISNULL(m.Subcuenta,'') 
 
  INSERT INTO #TotalExistencia (Sucursal, Articulo, Subcuenta, TotalExistencia)
                        SELECT Sucursal, Articulo, Subcuenta, SUM(Existencia) 
						FROM #PasoCalPeV GROUP BY Sucursal, Articulo, Subcuenta
 --SELECT * FROM #TotalExistencia WHERE ARTICULO='FL900'						

  INSERT INTO #PasoInvXDia (Sucursal,  Articulo, Subcuenta, InvXDia)
                     SELECT Sucursal,  Articulo, Subcuenta, (Vvp*@DiasSurtir)
	  				 FROM #PasoVVP  
  --select * from #PasoInvXDia WHERE ARTICULO='FL900'	

  INSERT INTO #PasoPe ( Sucursal,    Articulo,    Subcuenta,    Pe)
                 SELECT pc.Sucursal, pc.Articulo, pc.Subcuenta, ISNULL((ps.Existencia/NULLIF(te.TotalExistencia,0)),0)
                 FROM #PasoCalificaciones pc
				 JOIN #PasoCalPeV ps on pc.Sucursal=ps.Sucursal AND pc.Articulo=ps.Articulo AND ISNULL(pc.Subcuenta,'')=ISNULL(ps.Subcuenta,'')
                 JOIN #TotalExistencia te ON pc.Articulo=te.Articulo AND pc.Sucursal=te.Sucursal AND ISNULL(pc.Subcuenta,'')=ISNULL(te.Subcuenta,'')
				--where pc.articulo='0606'
  --select * from #PasoPe WHERE ARTICULO='FL900'	

  UPDATE m SET m.MinPe=Minimo, MaxPe=Maximo
  FROM (SELECT Articulo, Subcuenta, MIN(Pe) Minimo, MAX(Pe) Maximo
        FROM #PasoPe
	    GROUP BY Articulo, Subcuenta)a
	    JOIN #Minimos m on a.Articulo=m.Articulo AND ISNULL(a.Subcuenta,0)=ISNULL(m.Subcuenta,0)
  --SELECT * FROM #Minimos WHERE ARTICULO='FL900'
	   
  INSERT INTO #WFGPlaneadorTraspaso ( Sucursal,        Articulo,              VVP,            CalificacionVVP, 
                                      VelocidadMaxima, CalificacionVM,        TotalVentas,    ExistenciaActual, PeV,
									  CalificacionPeV,
									  PeF,             CalificacionPeF,       
									  Subcuenta)
                               SELECT p.Sucursal,      p.Articulo,            p.VVP,          p.CalifVVP, 
                                      p.VM,            ISNULL(p.CalifVM,0),   p.TotalVtas,    ps.Existencia,     ps.PeV,
                                      CASE WHEN m.MaxPeV=m.MinPeV THEN 3 ELSE ((1-((ps.PeV-m.MinPeV)/(m.MaxPeV-m.MinPeV)))*3) END CalifPeV,
								 	  pe.Pe,           CASE WHEN m.MaxPe=m.MinPe THEN 3 ELSE ((1-((pe.Pe-m.MinPe)/(m.MaxPe-m.MinPe)))*3) END CalifPe,
									  p.Subcuenta                               
                               FROM #PasoCalificaciones p
                               JOIN #PasoCalPeV ps on p.Sucursal=ps.Sucursal AND p.Articulo=ps.Articulo AND ISNULL(p.Subcuenta,'')=ISNULL(ps.Subcuenta,'')
                               JOIN #TotalExistencia t on p.Sucursal=t.Sucursal AND p.Articulo=t.Articulo AND ISNULL(p.Subcuenta,'')=ISNULL(t.Subcuenta,'')
                               JOIN #PasoPe pe on p.Sucursal=pe.Sucursal AND p.Articulo=pe.Articulo AND ISNULL(p.Subcuenta,'')=ISNULL(pe.Subcuenta,'')
                               JOIN #Minimos m on  p.Articulo=m.Articulo AND ISNULL(p.Subcuenta,'')=ISNULL(m.Subcuenta,'')
							   order by  p.articulo, p.subcuenta, p.sucursal							  
  --select * from #WFGPlaneadorTraspaso WHERE ARTICULO='FL900'

  INSERT INTO WFGPlaneadorTraspaso ( Sucursal,          NombreSuc,       Articulo,         Descripcion,      VVP,              CalificacionVVP, 
                                     VelocidadMaxima,   CalificacionVM,  TotalVentas,      ExistenciaActual, PeV,
                                     CalificacionPeV,   PeF,             CalificacionPeF, 
                                     CalificacionFinal, 
								     Subcuenta)
                     SELECT DISTINCT p.Sucursal,        s.Nombre,        p.Articulo,       a.Descripcion1,   VVP,              CalificacionVVP, 
							         VelocidadMaxima,   CalificacionVM,  TotalVentas,      ExistenciaActual, PeV,
									 CalificacionPeV,   PeF,             CalificacionPeF, 
									 ((CalificacionVVP*(SELECT (Ponderacion/100) FROM WFGPonderacion WHERE ID=1))+(CalificacionVM*(SELECT (Ponderacion/100) FROM WFGPonderacion WHERE ID=2))+
									 (CalificacionPeV*(SELECT (Ponderacion/100) FROM WFGPonderacion WHERE ID=3))+(CalificacionPeF*(SELECT (Ponderacion/100) FROM WFGPonderacion WHERE ID=4))),
									 p.Subcuenta
                     FROM #WFGPlaneadorTraspaso p
					 JOIN Sucursal s on p.sucursal=s.sucursal
					 JOIN Art a on p.Articulo=a.Articulo   
					 --select * from WFGPlaneadorTraspaso WHERE ARTICULO='FL900'

  INSERT INTO #SucOrdenCalifFinal (Sucursal, Articulo, Subcuenta, CalifFinal)
                            SELECT Sucursal, Articulo, Subcuenta,  CalificacionFinal
							FROM WFGPlaneadorTraspaso
							ORDER BY CalificacionFinal, Sucursal, Articulo, Subcuenta DESC
  --SELECT * FROM #SucOrdenCalifFinal WHERE ARTICULO='FL900'

  /********************Total existencias en tiendas con evaluacion <=2 + suma existencias en tiendas que no alcancen stock minimo ****************/
  INSERT INTO #TotalExistenciaMenorIgual2 (Articulo, Subcuenta, Existencia)
                                    SELECT Articulo, Subcuenta, SUM(a.Existencia)
                                    FROM ( SELECT SUM(ExistenciaActual) Existencia, Articulo, Subcuenta FROM WFGPlaneadorTraspaso WHERE Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND CalificacionFinal <=1 GROUP BY Articulo, Subcuenta
                                           UNION ALL
                                           SELECT SUM(w.ExistenciaActual) Existencia, w.Articulo, w.Subcuenta
                                           FROM WFGPlaneadorTraspaso w
                                           LEFT JOIN (SELECT Sucursal, Articulo, Cantidad FROM WFGStockMinimo) ws on w.Sucursal=ws.Sucursal AND w.Articulo=ws.Articulo
										   LEFT JOIN WFGStockMinimoEmpresa wse on w.Sucursal=wse.Sucursal
                                           WHERE w.Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND w.ExistenciaActual < ISNULL(ws.Cantidad, wse.Cantidad) AND CalificacionFinal > 1 AND CalificacionFinal < 2
                                           GROUP BY w.Articulo, Subcuenta
                                         )a 
										 GROUP BY Articulo, Subcuenta
  --SELECT * FROM #TotalExistenciaMenorIgual2 WHERE ARTICULO='FL900'
  
  --Total Vvp de tiendas con calificacion mayor o igual a 2
  INSERT INTO #SumaVvp (Articulo, Subcuenta, SumaVvp)
                 SELECT Articulo, ISNULL(Subcuenta,''), SUM(Vvp) 
                 FROM WFGPlaneadorTraspaso 
                 WHERE Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND CalificacionFinal >= 2 
                 GROUP BY Articulo, ISNULL(Subcuenta,'')
  --SELECT * FROM #SumaVvp WHERE ARTICULO='FL900'

  INSERT INTO #PorcentajeVvp ( Sucursal,   Articulo,   Subcuenta,   PorcentajeVvp)
                        SELECT w.Sucursal, w.Articulo, w.Subcuenta, ((Vvp/SumaVvp))
                        FROM WFGPlaneadorTraspaso w
                        JOIN #SumaVvp s on w.Articulo=s.Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(s.Subcuenta,'')
                        WHERE Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND CalificacionFinal >= 2
  --SELECT * FROM #PorcentajeVvp WHERE ARTICULO='FL900'

  --aqui compara contra el minimo
  INSERT INTO #StockMinimo (Sucursal, Articulo, Subcuenta, Stock)
                     SELECT t.Sucursal, t.Articulo, t.Subcuenta, ISNULL(ws.Cantidad, wse.Cantidad) stock
                     FROM WFGPlaneadorTraspaso t
                     LEFT JOIN (SELECT Sucursal, Articulo, Cantidad FROM WFGStockMinimo) ws on t.Sucursal=ws.Sucursal AND t.Articulo=ws.Articulo
                     LEFT JOIN WFGStockMinimoEmpresa wse on t.Sucursal=wse.Sucursal
  --SELECT * FROM #StockMinimo WHERE ARTICULO='FL900'

  /***** CALCULO CANTIDAD POSIBLE A TRASPASAR (1) ******/ 
  INSERT INTO ResumenCantTraspaso (Sucursal, Articulo, Subcuenta, Existencia, CalifFinal, InvXDia)
                  SELECT  DISTINCT s.Sucursal, s.Articulo, s.Subcuenta, ps.Existencia, s.CalifFinal, p.InvXDia
				  FROM #SucOrdenCalifFinal s
				  JOIN #PasoCalPeV ps on s.Sucursal=ps.Sucursal AND s.Articulo=ps.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(ps.Subcuenta,'')
				  JOIN #TotalExistencia t on s.Sucursal=t.Sucursal AND s.Articulo=t.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(t.Subcuenta,'')
                  JOIN #PasoInvXDia p on s.Sucursal=p.Sucursal AND s.Articulo=p.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(p.Subcuenta,'')
				  JOIN #PasoCalificaciones pc on s.Sucursal=pc.Sucursal and s.Articulo=pc.Articulo and ISNULL(s.Subcuenta,'')=ISNULL(pc.Subcuenta,'')
				  JOIN #StockMinimo st on s.Sucursal=st.Sucursal AND s.Articulo=st.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(st.Subcuenta,'')
  --SELECT * FROM ResumenCantTraspaso WHERE ARTICULO='FL900' order by Sucursal

  INSERT INTO #WFGCantidadTraspasar (Sucursal, Articulo, Subcuenta, Existencia, CalifFinal, InvXDia, Ciclo, Stock)
                     SELECT  DISTINCT s.Sucursal, s.Articulo, s.Subcuenta, ps.Existencia, s.CalifFinal, p.InvXDia, 1, st.Stock
					 FROM #SucOrdenCalifFinal s
					 JOIN #PasoCalPeV ps on s.Sucursal=ps.Sucursal AND s.Articulo=ps.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(ps.Subcuenta,'')
					 JOIN #TotalExistencia t on s.Sucursal=t.Sucursal AND s.Articulo=t.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(t.Subcuenta,'')
					 JOIN #PasoInvXDia p on s.Sucursal=p.Sucursal AND s.Articulo=p.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(p.Subcuenta,'')
					 JOIN #PasoCalificaciones pc on s.Sucursal=pc.Sucursal AND s.Articulo=pc.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(pc.Subcuenta,'')
					 JOIN #StockMinimo st on s.Sucursal=st.Sucursal AND s.Articulo=st.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(st.Subcuenta,'')
   --select * from #WFGCantidadTraspasar where articulo='DIADEPRIN'

   DECLARE crCantPos1 CURSOR FAST_FORWARD FOR     
    SELECT DISTINCT Articulo, Subcuenta
	FROM #WFGCantidadTraspasar
   OPEN crCantPos1
   FETCH NEXT FROM crCantPos1 INTO @Articulo, @Opcion
   WHILE @@FETCH_STATUS = 0
   BEGIN        
     SELECT @CicloMax=MAX(ISNULL(Ciclo,0)) FROM #WFGCantidadTraspasar WHERE Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'')	

	 ---INICIO EXCLUIR ITEMS CON EXISTENCIA SUFICIENTE
	 WHILE EXISTS (SELECT * FROM #WFGCantidadTraspasar 
	               WHERE ((Existencia < Stock) OR (Existencia < InvXDia)) AND InvXDia >0 AND Ciclo=@CicloMax AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'') 
	               AND ISNULL(Excluido,0)=0 AND @CicloMax < 2) 
	 BEGIN 
	   --INICIO: EVALUA SI EXISTENCIA ES MENOR A STOCK O A INVXDIA Y ORDENA POR CALIFICACION, TOMANDO EN CUENTA LA DE MENOR
	   SELECT TOP 1 @Sucursal=Sucursal, @InvDia=Existencia, @InvXDiaR=CASE WHEN Stock > InvXDia THEN Stock ELSE InvXDia END  
	   FROM #WFGCantidadTraspasar 
	   WHERE ((Existencia < Stock) OR (Existencia < InvXDia)) AND InvXDia >0 AND Ciclo=@CicloMax AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'') 
       ORDER BY CalifFinal DESC
	   --FIN: EVALUA SI EXISTENCIA ES MENOR A STOCK O A INVXDIA Y ORDENA POR CALIFICACION, TOMANDO EN CUENTA LA DE MENOR
	   --IF @Articulo='DIADEPRIN'
	   --SELECT @Sucursal, @InvDia, @InvXDiaR
		IF @CicloMax=1
		BEGIN
		   --SELECT @InvDia=@InvDia-ISNULL(@InvXDiaAnt,0)
		   --IF @Articulo='DIADEPRIN' SELECT @InvDia
	     --TOTAL EXISTENCIAS POR ARTICULO Y SUBCUENTA
          SELECT @TotalInvXDia=SUM(ISNULL(Existencia,0)) FROM #WFGCantidadTraspasar 
          WHERE Articulo=@Articulo AND ISNULL(SubCuenta,'')=ISNULL(@Opcion,'')
          AND Ciclo=@CicloMax
	     --IF @Articulo='DIADEPRIN'   SELECT @TotalInvXDia

		 SELECT @CantidadTraspasar=NULL, @CantidadT=NULL, @CantidadR=NULL
          DECLARE crCantTras CURSOR FAST_FORWARD FOR     
            SELECT Sucursal
	        FROM #WFGCantidadTraspasar
	        WHERE Articulo=@Articulo
	        AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'')
	        AND Ciclo=@CicloMax
		    AND ISNULL(Excluido,0)=0
	        ORDER BY CalifFinal DESC
          OPEN crCantTras
          FETCH NEXT FROM crCantTras INTO @SucursalC
          WHILE @@FETCH_STATUS = 0
          BEGIN	  
			 --IF @Articulo='DIADEPRIN'   SELECT @CantidadT
	         SELECT @CantidadT=SUM(ISNULL(CantidadTraspasar,0)) FROM #WFGCantidadTraspasar WHERE Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'') AND Ciclo=@CicloMax 
			 --IF @Articulo='DIADEPRIN'   SELECT @CantidadR
			 SELECT @CantidadR=@TotalInvXDia-ISNULL(@CantidadTraspasar,0)
			 
		     IF @CantidadT <= @TotalInvXDia
		     BEGIN
		       UPDATE #WFGCantidadTraspasar SET CantidadTraspasar=CASE WHEN @CantidadR >= @TotalInvXDia THEN CASE WHEN Stock > InvXDia THEN Stock ELSE InvXDia END ELSE ISNULL(@CantidadR,0) END
		       WHERE Sucursal=@SucursalC AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'') AND Ciclo=@CicloMax
		       
			   --if @articulo='diadeprin' select 'cantidad', @CantidadTraspasar
		       SELECT @CantidadTraspasar=CantidadTraspasar FROM #WFGCantidadTraspasar WHERE Sucursal=@SucursalC AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'')
		       AND Ciclo=@CicloMax		   
		      --select @cantidadtraspasar, @Totalinvxdia
		     END 
          FETCH NEXT FROM crCantTras INTO  @SucursalC
          END    
          CLOSE crCantTras
          DEALLOCATE crCantTras 

	      UPDATE #WFGCantidadTraspasar SET TotalInvXDia=ISNULL(@TotalInvXDia,0) WHERE Ciclo=@CicloMax AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'')
		  --IF @Articulo='diadeprin'
		  --select * from #WFGCantidadTraspasar where Articulo='diadeprin'
	      --Excluir items donde cantidadtraspasar es menor a STock o InvXDia
	      UPDATE #WFGCantidadTraspasar SET Excluido=1 WHERE Ciclo=@CicloMax AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'')
	      AND (CantidadTraspasar < CASE WHEN Stock > InvXDia THEN Stock ELSE InvXDia END) 

	      UPDATE #WFGCantidadTraspasar SET Proporcion  =Existencia/ISNULL(@InvXDiaR,0) 
	      WHERE Ciclo=@CicloMax AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'')
	      AND ISNULL(Excluido,0)=0	   
	      
	      --Incrementamos Ciclo
	      SELECT @CicloMax=@CicloMax+1	
	   
	      INSERT INTO #WFGCantidadTraspasar (Sucursal, Articulo, Subcuenta, Existencia, CalifFinal, InvXDia,                                                                                       
	                                         Ciclo,    Stock,    Excluido)
	   	                              SELECT Sucursal, Articulo, Subcuenta, Existencia, CalifFinal, CASE WHEN ISNULL(Excluido,0)=1 THEN 0 ELSE InvXDia END, 
								            @CicloMax, CASE WHEN ISNULL(Excluido,0)=1 THEN 0 ELSE Stock END, Excluido
								      FROM #WFGCantidadTraspasar WHERE Ciclo=@CicloMax-1 AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'')
									  AND Sucursal=@Sucursal
	    END
	    --select @ciclomax
	   	IF @CicloMax>=2
		BEGIN	
	      SELECT @CantTraspasar=SUM(CantidadTraspasar)
          FROM #WFGCantidadTraspasar w 
	      WHERE w.Ciclo=1 AND w.Articulo=@Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(@Opcion,'') 
		  AND ISNULL(Excluido,0)=0

		  SELECT @CantidadRestante=@TotalInvXDia - @CantTraspasar
		  --select @CantidadRestante

		  UPDATE w SET Proporcion=w1.CantidadTraspasar/@CantTraspasar
		  FROM #WFGCantidadTraspasar w 
		  JOIN #WFGCantidadTraspasar w1 on w.Articulo=w1.Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(w1.Subcuenta,'')  AND w.Sucursal=w1.Sucursal
	      WHERE w1.Ciclo=@CicloMax-1 AND w.Articulo=@Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(@Opcion,'') 
		  AND ISNULL(w.Excluido,0)=0 AND w.Ciclo=@CicloMax

		  --Reparte Cantidad no excluidos
		  UPDATE w SET CantidadTraspasar=(ISNULL(w.Proporcion,0)*ISNULL(@CantidadRestante,0))+w1.CantidadTraspasar
		  FROM #WFGCantidadTraspasar w 
		  JOIN #WFGCantidadTraspasar w1 on w.Articulo=w1.Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(w1.Subcuenta,'') AND w.Sucursal=w1.Sucursal
	      WHERE w1.Ciclo=@CicloMax-1 AND w.Articulo=@Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(@Opcion,'') 
		  AND ISNULL(w.Excluido,0)=0 AND w.Ciclo=@CicloMax
		END
		--IF @ARTICULO='DIADEPRIN'
	    --SELECT 'o', * FROM #WFGCantidadTraspasar WHERE ARTICULO='DIADEPRIN'   ORDER BY CICLO
     END 
	 ---FIN EXCLUIR ITEMS CON EXISTENCIA SUFICIENTE  
   FETCH NEXT FROM crCantPos1 INTO  @Articulo, @Opcion
   END    
   CLOSE crCantPos1
   DEALLOCATE crCantPos1  
   --select 'm',* from #WFGCantidadTraspasar where articulo='DIADEPRIN'
  
   INSERT #CicloMax (CicloMax,   Articulo, Subcuenta,            Sucursal)
              SELECT MAX(Ciclo), Articulo, ISNULL(Subcuenta,''), Sucursal 
              FROM #WFGCantidadTraspasar GROUP BY Articulo, Subcuenta, Sucursal   
             --select * from #CicloMax WHERE ARTICULO='016up'
   
   INSERT INTO #WFGCantTraspasaCicloMax (Articulo,   Subcuenta,   Existencia,   CalifFinal,   InvXDia,   Ciclo,   Stock,   CantidadTraspasar, Sucursal)
                                  SELECT w.Articulo, w.Subcuenta, w.Existencia, w.CalifFinal, w.InvXDia, w.Ciclo, w.Stock, CantidadTraspasar, w.Sucursal
                                  FROM #WFGCantidadTraspasar w 
                                  JOIN #CicloMax c ON w.Ciclo=c.CicloMax AND w.Articulo=c.Articulo AND w.Sucursal=c.Sucursal AND ISNULL(w.Subcuenta,'')=ISNULL(c.Subcuenta,'')
                                  --SELECT 'H', * FROM #WFGCantTraspasaCicloMax WHERE ARTICULO='DIADEPRIN'

   INSERT INTO #Recibir1 (Articulo,   Subcuenta,   Sucursal,   Cantidad)
          SELECT DISTINCT w.Articulo, w.Subcuenta, w.Sucursal, 0
          FROM #WFGCantTraspasaCicloMax w   
   
   INSERT INTO #Recibir2 (Articulo,   Subcuenta,   Sucursal,   Cantidad)
          SELECT DISTINCT w.Articulo, w.Subcuenta, w.Sucursal, 0
          FROM #WFGCantTraspasaCicloMax w      

   INSERT INTO #Recibir3 (Articulo,   Subcuenta,   Sucursal,   Cantidad)
          SELECT DISTINCT w.Articulo, w.Subcuenta, w.Sucursal, 0
          FROM #WFGCantTraspasaCicloMax w
   --select * from WFGPlaneadorTraspaso where Articulo='diadeprin'

   DECLARE crSucMax CURSOR FAST_FORWARD FOR
       SELECT DISTINCT Articulo, ISNULL(SubCuenta,'')
       FROM WFGPlaneadorTraspaso
       ORDER BY Articulo, ISNULL(SubCuenta,'')
   OPEN crSucMax 
   FETCH NEXT FROM crSucMax INTO @articulo, @subcuenta
   WHILE @@FETCH_STATUS=0
   BEGIN
     DECLARE crSucMax2 CURSOR FAST_FORWARD FOR
	    SELECT CalificacionFinal, Sucursal
	    FROM WFGPlaneadorTraspaso 
	    WHERE Articulo=@articulo AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')
	 OPEN crSucMax2
	 FETCH NEXT FROM crSucMax2 INTO @CalifFinal, @Sucursal
     WHILE @@FETCH_STATUS=0
     BEGIN 
	   IF ISNULL(@CalifFinal, 0) > ISNULL(@CalifFinalMax,0)
	   SELECT @CalifFinalMax=@CalifFinal, @SucMax=@Sucursal
     FETCH NEXT FROM crSucMax2 INTO @CalifFinal, @Sucursal
     END
     CLOSE crSucMax2
     DEALLOCATE crSucMax2

     INSERT #SucCalifMax VALUES (@SucMax, @Articulo, @Subcuenta, @CalifFinalMax)

   FETCH NEXT FROM crSucMax INTO @Articulo, @Subcuenta
   END
   CLOSE crSucMax
   DEALLOCATE crSucMax	 
	 --select * from #SucCalifMax where Articulo=@articulo
	
   --OBTIENE PARTE ENTERA
   UPDATE w SET w.RecibeTraspaso=1, w.CantidadATraspasar=FLOOR(c.CantidadTraspasar)
   FROM WFGPlaneadorTraspaso w
   JOIN #WFGCantTraspasaCicloMax c ON w.Articulo=c.Articulo AND w.Sucursal=c.Sucursal AND  ISNULL(w.Subcuenta,'')=ISNULL(c.Subcuenta,'')
   WHERE w.Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND c.CantidadTraspasar>0 AND (Existencia < CantidadTraspasar)

   --select * from WFGPlaneadorTraspaso where articulo='diadeprin'

   --OBTIENE PARTE DECIMAL	
   INSERT INTO #SumaCantDec (CantidadTraspasaDec,                                 Articulo, Subcuenta)
                      SELECT SUM(c.CantidadTraspasar-FLOOR(c.CantidadTraspasar)), Articulo, ISNULL(Subcuenta,'')
                      FROM #WFGCantTraspasaCicloMax c
                      GROUP BY Articulo, ISNULL(Subcuenta,'')
	 --select * from #SumaCantDec where articulo='diadeprin'

   UPDATE c set c.CantidadATraspasar=c.CantidadATraspasar+d.CantidadTraspasaDec
   FROM WFGPlaneadorTraspaso c
   JOIN #SucCalifMax s on c.articulo=s.articulo and ISNULL(c.Subcuenta,'')=ISNULL(s.Subcuenta,'') and c.sucursal=s.sucursal
   JOIN #SumaCantDec d on c.articulo=d.articulo and ISNULL(c.Subcuenta,'')=ISNULL(d.Subcuenta,'') 
   --select * from WFGPlaneadorTraspaso where articulo='diadeprin'
	 
   UPDATE w SET w.TraspasaASuc=1
   FROM WFGPlaneadorTraspaso w
   JOIN #WFGCantTraspasaCicloMax c ON w.Articulo=c.Articulo AND w.Sucursal=c.Sucursal AND  ISNULL(w.Subcuenta,'')=ISNULL(c.Subcuenta,'')
   WHERE w.Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND isnull(c.CantidadTraspasar,0)=0
   --select sucursal, TraspasaASuc, RecibeTraspaso, CantidadATraspasar, * from WFGPlaneadorTraspaso where articulo='diadeprin' --and subcuenta='c4t1' order by 1 

   /* R E P O R T E*/
   TRUNCATE TABLE WFGRPTPlaneadorTraspaso
   INSERT INTO WFGRPTPlaneadorTraspaso (Sucursal,            NombreSuc,    Articulo,        Descripcion, VVP,             CalificacionVVP,   VelocidadMaxima, CalificacionVM, TotalVentas,
                                        ExistenciaActual,     PeV,          CalificacionPeV, PeF,         CalificacionPeF, CalificacionFinal, TraspasaASuc,    RecibeTraspaso, CantidadATraspasar, 
										Subcuenta,		      DiasSurtir,	DOF)
                                 SELECT Sucursal,             NombreSuc,    Articulo,        Descripcion, VVP,             CalificacionVVP,   VelocidadMaxima, CalificacionVM, TotalVentas,
								        ExistenciaActual,     PeV,          CalificacionPeV, PeF,         CalificacionPeF, CalificacionFinal, TraspasaASuc,    RecibeTraspaso, CantidadATraspasar, 
										ISNULL(Subcuenta,''), @DiasSurtir,  @DiasSurtir*vvp
                                   FROM WFGPlaneadorTraspaso w
                                   WHERE w.Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad)     
   --select * from WFGPlaneadorTraspaso where articulo='diadeprin' /*and subcuenta='c1t2'*/ and traspasaasuc=1
   --select * from WFGPlaneadorTraspaso where articulo='fl900' /*and subcuenta='c1t2'*/ and recibetraspaso=1
	 
   DECLARE crWfgSucP CURSOR FAST_FORWARD FOR
	 SELECT DISTINCT SucursalO FROM WFGPrioridad
   OPEN crWfgSucP
   FETCH NEXT FROM crWfgSucP INTO 	@SucursalO
   WHILE @@FETCH_STATUS=0
   BEGIN
	 INSERT INTO #WfgPrioridadNum	  	
	   SELECT  ROW_NUMBER() OVER (ORDER BY ID) as Num, SucursalO as SO, NombreSucO as NomSO, SucursalD as sd, NombreSucD as nomsd
	   FROM WFGPrioridad
	   WHERE SucursalO=@SucursalO
   FETCH NEXT FROM crWfgSucP INTO @SucursalO
   END
   CLOSE crWfgSucP
   DEALLOCATE crWfgSucP
   --SELECT * FROM #WfgPrioridadNum

   DECLARE crWFGSuc2 CURSOR FAST_FORWARD FOR
   	 SELECT DISTINCT SucursalD FROM #WfgPrioridadNum
   OPEN crWFGSuc2
   FETCH NEXT FROM crWFGSuc2 INTO @SucursalD
   WHILE @@FETCH_STATUS=0
   BEGIN
 	 INSERT INTO #WfgPrioridadNum2 (ID,                                     SucursalO,  NombreSucO, SucursalD, NombreSucD)
	                         SELECT ROW_NUMBER() OVER (Order BY Prioridad), SucursalO,  NombreSucO, SucursalD, NombreSucD 
			                 FROM #WfgPrioridadNum WHERE SucursalD=@SucursalD
	
   FETCH NEXT FROM crWFGSuc2 INTO @SucursalD
   END
   CLOSE crWFGSuc2
   DEALLOCATE crWFGSuc2
   --select * from #WFGCantTraspasaCicloMax where Articulo='diadeprin'

   INSERT INTO #Disponible (Sucursal, Articulo, Subcuenta, Disponible)
		            SELECT  Sucursal, Articulo, Subcuenta, Existencia-CantidadTraspasar
		            FROM #WFGCantTraspasaCicloMax
		            WHERE Existencia>CantidadTraspasar
		            --SELECT * FROM #Disponible where articulo='diadeprin'
     
	UPDATE WFGPlaneadorTraspaso SET CantidadATraspasar=ISNULL(CantidadATraspasar,0)-ISNULL(ExistenciaActual,0) WHERE ISNULL(CantidadATraspasar,0)>0	 
    --SELECT 's', * FROM WFGPlaneadorTraspaso WHERE Articulo='BAIK0531'

  	 --------------------------------------------------------------------------------------------
     ------Obtiene existenciaActual sucursales que traspasan
   DECLARE crTraspaso CURSOR FAST_FORWARD FOR     
     SELECT a.Almacen, w.Sucursal, Articulo, CantidadATraspasar, Subcuenta
	 FROM WFGPlaneadorTraspaso w
	 JOIN Alm a ON w.Sucursal=a.Sucursal
     WHERE RecibeTraspaso=1 
	 ORDER BY Almacen, Sucursal
   OPEN crTraspaso
   FETCH NEXT FROM crTraspaso INTO @AlmacenD, @SucursalD, @ArticuloD, @CantTraspasa, @Subcuenta
   WHILE @@FETCH_STATUS = 0
   BEGIN      
     SELECT @TotalCantidadTraspaso=0
     DECLARE crTraspaso1 CURSOR FAST_FORWARD FOR     
	   SELECT wp.ID, wp.SucursalO, a.Almacen
	   FROM #WfgPrioridadNum2 wp
       JOIN WFGPlaneadorTraspaso w ON wp.SucursalO=w.Sucursal
       JOIN Alm a ON a.Sucursal=wp.SucursalO   
	   WHERE wp.SucursalD=@SucursalD AND ISNULL(w.RecibeTraspaso,0)=0 AND w.Articulo=@ArticuloD AND ISNULL(w.Subcuenta,'')=ISNULL(@Subcuenta,'')
	   ORDER BY id
     OPEN crTraspaso1
     FETCH NEXT FROM crTraspaso1 INTO @ID, @SucursalO, @AlmacenO
     WHILE @@FETCH_STATUS = 0 AND ISNULL(@TotalCantidadTraspaso,0)<>@CantTraspasa
     BEGIN 
	   SELECT @CantDisponible=Disponible FROM #Disponible WHERE Sucursal=@SucursalO AND Articulo=@ArticuloD AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')
	   IF @CantDisponible <= @CantTraspasa-ISNULL(@TotalCantidadTraspaso,0) AND @CantDisponible>0
	   BEGIN
		 INSERT INTO #Traspasos (AlmacenO,   AlmacenD,   SucursalO,  SucursalD,  Articulo,   Subcuenta,  CantidadTraspasada)
                          SELECT @AlmacenO,  @AlmacenD,  @SucursalO, @SucursalD, @ArticuloD, @Subcuenta, @CantDisponible	

		 UPDATE #Disponible SET Disponible=ROUND(Disponible-@CantDisponible,2) WHERE Sucursal=@SucursalO AND Articulo=@ArticuloD AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')
	     
		 SELECT  @TotalCantidadTraspaso=ISNULL(SUM(ISNULL(CantidadTraspasada,0)),0) FROM #Traspasos WHERE SucursalD=@SucursalD AND Articulo=@ArticuloD AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')		 	  
	     SELECT  @RestaCantidadTraspaso=ISNULL(@CantTraspasa-ISNULL(@TotalCantidadTraspaso,0),0)
		 
	   END
       ELSE IF @CantDisponible > @CantTraspasa-ISNULL(@TotalCantidadTraspaso,0)
       BEGIN
    	 INSERT INTO #Traspasos (AlmacenO,   AlmacenD,   SucursalO,  SucursalD,  Articulo,   Subcuenta,  CantidadTraspasada)
                          SELECT @AlmacenO,  @AlmacenD,  @SucursalO, @SucursalD, @ArticuloD, @Subcuenta, @CantTraspasa-ISNULL(@TotalCantidadTraspaso,0)         
		  
		 UPDATE #Disponible SET Disponible=ROUND(Disponible-(@CantTraspasa-ISNULL(@TotalCantidadTraspaso,0)),2) WHERE Sucursal=@SucursalO AND Articulo=@ArticuloD AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')
		 SELECT @TotalCantidadTraspaso=ISNULL(SUM(ISNULL(CantidadTraspasada,0)),0) FROM #Traspasos WHERE SucursalD=@SucursalD AND Articulo=@ArticuloD AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')		 	  
	   END
     FETCH NEXT FROM crTraspaso1 INTO @ID, @SucursalO, @AlmacenO
     END    
     CLOSE crTraspaso1
     DEALLOCATE crTraspaso1 

   FETCH NEXT FROM crTraspaso INTO @AlmacenD, @SucursalD, @ArticuloD, @CantTraspasa, @Subcuenta
   END    
   CLOSE crTraspaso
   DEALLOCATE crTraspaso 

   --SELECT '1', * FROM #Traspasos --where Articulo='diadeprin'
  --SELECT * FROM WFGPlaneadorTraspaso WHERE TraspasaASuc=1 AND ARTICULO='0606' AND SUBCUENTA='C1T2'
  --select * from #Traspasos where subcuenta='c1t2' --order by SucursalD
   INSERT INTO WFGTraspaso ( AlmacenO,   AlmacenD,   SucursalO,   NomSucO,   SucursalD,   NomSucD,   Articulo,   ArtDescripcion,  Subcuenta, CantidadTraspaso,     Accion,     Estado, Fecha)
                      SELECT t.AlmacenO, t.AlmacenD, t.SucursalO, so.Nombre, t.SucursalD, sd.Nombre, t.Articulo, a.Descripcion1,  Subcuenta, t.CantidadTraspasada, 'Traspaso', 'Plan', @Fecha
	 				  FROM #Traspasos t
					  JOIN Sucursal so on t.SucursalO=so.Sucursal
					  JOIN Sucursal sd on t.SucursalD=sd.Sucursal
					  JOIN Art a on t.Articulo=a.Articulo
   
   SELECT * FROM WFGTraspaso
   --SELECT * FROM WFGTraspaso --where articulo='zta-bb-233' and subcuenta='t1' order by articulo
   --select * from WFGPlaneadorTraspaso where articulo='0606' AND Subcuenta='C1T2' and traspasaasuc=1
   -- select * from WFGPlaneadorTraspaso where articulo='0606' AND Subcuenta='C1T2' and recibetraspaso=1
   -- SELECT * FROM #WFGPlaneadorTraspasoJob

RETURN
END
GO

--BEGIN TRANSACTION
--EXEC spWFGPlaneadorTraspaso '20180101', '20180107', 'E001', 7
--EXEC xpWFGVisRPTCalif
--ROLLBACK

