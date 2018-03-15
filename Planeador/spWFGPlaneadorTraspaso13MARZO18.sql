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
		  @ExistenciaArt         float

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
										  Subcuenta      varchar(50) NULL
                                        )

 CREATE TABLE #PasoVVP ( Sucursal     int         NULL, 
                         Articulo     varchar(20) NULL, 
						 Subcuenta    varchar(50) NULL,
						 VVP          float       NULL, 
                         VM           float       NULL, 
                         TotalVtas    float       NULL
                        ) 

  CREATE TABLE #PasoInvXDia ( Sucursal     int         NULL, 
                              Articulo     varchar(20) NULL, 
						      Subcuenta    varchar(50) NULL,
							  InvXDia      float       NULL
                            ) 

  CREATE TABLE #PasoCalificaciones ( Sucursal     int         NULL, 
                                     Articulo     varchar(20) NULL, 
									 Subcuenta    varchar(50) NULL,
                                     VVP          float       NULL,
									 CalifVVP     float       NULL, 
									 VM           float       NULL, 
                                     CalifVM      float       NULL, 
                                     TotalVtas    float       NULL, 
                                     Existencia   float       NULL
                                   )

  CREATE TABLE #PasoCalPeV ( Sucursal     int         NULL, 
                             Articulo     varchar(20) NULL, 
							 Subcuenta    varchar(50) NULL,
                             Existencia   float       NULL,
                             PeV          float       NULL
                           ) 

  CREATE TABLE #TotalExistencia ( Sucursal          int         NULL,
                                  Articulo          varchar(20) NULL,
                                  Subcuenta         varchar(50) NULL,
                                  TotalExistencia   float       NULL
                                ) 

								
  CREATE TABLE #PasoPe  ( Sucursal     int         NULL, 
                          Articulo     varchar(20) NULL, 
						  Subcuenta    varchar(50) NULL,
                          Pe           float       NULL
                        ) 
						

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
                                       CalificacionPeF   float         NULL
                                      )


  CREATE TABLE #CantidadATraspasar ( Sucursal               int         NULL, 
                                     Articulo               varchar(20) NULL, 
									 Subcuenta              varchar(50) NULL,
                                     Porcentaje             float       NULL,
                                     CantidadATraspasar     int       NULL,
									 CantidadATraspasarDec  float     NULL
                                   )
								   

  CREATE TABLE #PorcentajeVvp ( Sucursal      int         NULL, 
                                Articulo      varchar(20) NULL, 
								Subcuenta     varchar(50) NULL,
                                PorcentajeVvp float       NULL
                              )



  CREATE TABLE #Minimos ( Articulo  varchar(20) NULL, 
                          Subcuenta varchar(50) NULL,
                          MinVvp    float       NULL,
                          MaxVvp    float       NULL,
                          MinVm     float       NULL,
                          MaxVm     float       NULL,
                          MinPeV    float       NULL,
                          MaxPeV    float       NULL,
                          MinPe     float       NULL,
                          MaxPe     float       NULL
					    )  
						

  CREATE TABLE #TotalExistenciaMenorIgual2 (Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, Existencia float NULL)  
  CREATE TABLE #SumaVvp (Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, SumaVvp float NULL)

  CREATE TABLE #Traspasos ( AlmacenO            varchar(20) NULL,
                            AlmacenD            varchar(20) NULL,
                            SucursalO           int         NULL,
                            SucursalD           int         NULL,
                            Articulo            varchar(20) NULL,
							Subcuenta           varchar(50) NULL,
                            CantidadTraspasada  float       NULL
                          )

  CREATE TABLE #TotalDecimal (TotalDecimal float NULL, Articulo varchar(20) NULL, Subcuenta varchar(50) NULL)
  CREATE TABLE #InsertaTraspaso(ID INT NULL, Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, SucursalO int NULL, AlmacenD varchar(20) NULL, SucursalD int NULL, CantidadInt float NULL, CantidadDec float NULL)
  CREATE TABLE #SucOrdenCalifFinal (Sucursal int NULL, Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, CalifFinal float NULL)
  CREATE TABLE #CantidadTraspasar (Sucursal int NULL, Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, Existencia float NULL, PDInv float NULL, CantTraspasa float NULL, Ciclo int NULL, CalifFinal float NULL)


  --------------------------------------------------------------------------------------------

 INSERT INTO #WFGPlaneadorTraspasoJob ( Sucursal,   Articulo,   Cantidad,        Subcuenta)
                                 SELECT w.Sucursal, w.Articulo, SUM(w.Cantidad), ISNULL(w.Subcuenta,'')
                                 FROM WFGPlaneadorTraspasoJob w
								 JOIN Art a ON w.Articulo=a.Articulo  
								 --JOIN WFGPrioridad wp ON w.Sucursal=wp.SucursalO
								 WHERE w.FechaEmision BETWEEN @FechaD AND @FechaA AND
								 a.Estatus='ALTA' AND ISNULL(a.WFGArtPlaneador,0)=1 AND w.Empresa=@Empresa
								 AND w.Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad)
								 GROUP BY w.Sucursal, w.Articulo, ISNULL(w.Subcuenta,'')

  --select * from #WFGPlaneadorTraspasoJob where articulo='FL900'

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
				 --and a.articulo='0606'
				 GROUP BY w.Sucursal, w.Articulo, ISNULL(w.Subcuenta,'')
--select * from #PasoVVP where ARTICULO='FL900'

 INSERT INTO #Minimos (Articulo, Subcuenta,  MinVvp,   MaxVvp,   MinVm,   MaxVm)
                SELECT Articulo, Subcuenta, MIN(VVP), MAX(VVP),  MIN(VM), MAX(VM) 
                FROM #PasoVVP 
				--where articulo='0606'
				GROUP BY Articulo, Subcuenta
 --select * from #Minimos where articulo='fl900' --and subcuenta='c1t2'  

  INSERT INTO #PasoCalificaciones ( Sucursal,   Articulo,    Subcuenta,   VVP,   VM,    TotalVtas,       
                                    CalifVVP, 
									CalifVM,
									Existencia)
                             SELECT w.Sucursal, w.Articulo,  w.Subcuenta, p.VVP, p.VM,  TotalVtas,        
                                    CASE WHEN ISNULL(m.MaxVVP,0)=ISNULL(m.MinVVP,0) THEN 3 ELSE (((p.VVP-m.MinVVP)/(m.MaxVVP-m.MinVVP))*3) END CalifVVP, 
                                    CASE WHEN ISNULL(m.MaxVM,0)=ISNULL(m.MinVM,0) THEN 3 ELSE (((p.VM-m.MinVM)/(m.MaxVM-m.MinVM))*3) END CalifVM, 
									disponible.existencias
                                    ----(ISNULL(a.Disponible,0)+ISNULL(b.Reservado,0)) Existencia
                             FROM #WFGPlaneadorTraspasoJob w
                             JOIN #PasoVVP p ON w.Sucursal=p.Sucursal AND w.Articulo=p.Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(p.Subcuenta,'')
                             JOIN #Minimos m on w.Articulo=m.Articulo AND isnull(w.Subcuenta,'')=isnull(m.Subcuenta,'')
							 JOIN (SELECT Empresa, Sucursal, Cuenta, ISNULL(SubCuenta,'') SubCuenta, SUM(CASE WHEN Rama='INV' THEN SaldoU WHEN Rama='VMOS' THEN -SaldoU END) Existencias		
							       FROM SaldoU --WHERE Cuenta='0606' AND SubCuenta='C1T2' 
		                           GROUP BY Empresa, Sucursal,  Cuenta, SubCuenta) disponible on w.Articulo=disponible.Cuenta and ISNULL(w.Subcuenta,'')=ISNULL(disponible.SubCuenta,'') and w.Sucursal=disponible.Sucursal
							 --where w.articulo='0606'

  --SELECT * FROM #PasoCalificaciones WHERE ARTICULO='FL900'

  INSERT INTO #PasoCalPeV ( Sucursal, Articulo, Subcuenta, Existencia, PeV)
                     SELECT Sucursal, Articulo, Subcuenta, CASE WHEN Existencia<0 THEN 0 ELSE Existencia END, 
					 (CASE WHEN (CASE WHEN Existencia<0 THEN 0 ELSE Existencia END+CASE WHEN TotalVtas<0 THEN 0 ELSE TotalVtas END)=0 THEN 1 ELSE (CASE WHEN Existencia<0 THEN 0 ELSE Existencia END/(CASE WHEN Existencia<0 THEN 0 ELSE Existencia END+CASE WHEN TotalVtas<0 
THEN 0 ELSE TotalVtas END)) END *100) PeV
                     FROM #PasoCalificaciones
					 --where articulo='0606'
 --SELECT * FROM #PasoCalPeV where ARTICULO='FL900'--subcuenta='c1t2' order by sucursal, subcuenta, peV

  UPDATE m SET m.MinPeV=Minimo, MaxPeV=Maximo
  FROM (SELECT Articulo, Subcuenta, MIN(PeV) minimo , MAX(PeV) maximo
        FROM #PasoCalPeV
		--where articulo='0606'
        GROUP BY Articulo, Subcuenta)a
 JOIN #Minimos m on a.Articulo=m.Articulo AND ISNULL(a.Subcuenta,'')=ISNULL(m.Subcuenta,'') 
 --where a.articulo='0606'
 
 --SELECT * FROM #Minimos WHERE ARTICULO='FL900'
 --select MinPeV, MaxPeV, articulo, subcuenta from #Minimos-- where articulo='0606'
 
 INSERT INTO #TotalExistencia (Sucursal, Articulo, Subcuenta, TotalExistencia)
                        SELECT Sucursal, Articulo, Subcuenta, SUM(Existencia) FROM #PasoCalPeV /*where articulo='0606'*/ GROUP BY Sucursal, Articulo, Subcuenta

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
	   --where articulo='0606'
	   GROUP BY Articulo, Subcuenta)a
	   JOIN #Minimos m on a.Articulo=m.Articulo AND ISNULL(a.Subcuenta,0)=ISNULL(m.Subcuenta,0)
	   --where m.articulo='0606'

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
							  /*where p.articulo='0606'*/ order by  p.articulo, p.subcuenta, p.sucursal
							  
--select * from #WFGPlaneadorTraspaso WHERE ARTICULO='FL900'

INSERT INTO WFGPlaneadorTraspaso (  Sucursal,          NombreSuc,       Articulo,         Descripcion,      VVP,              CalificacionVVP, 
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
							-- where p.articulo='0606'

  --select * from WFGPlaneadorTraspaso WHERE ARTICULO='FL900'

  INSERT INTO #SucOrdenCalifFinal (Sucursal, Articulo, Subcuenta, CalifFinal)
                            SELECT Sucursal, Articulo, Subcuenta,  CalificacionFinal
							FROM WFGPlaneadorTraspaso
							ORDER BY CalificacionFinal, Sucursal, Articulo, Subcuenta DESC

 --SELECT * FROM #SucOrdenCalifFinal WHERE ARTICULO='FL900'
  --Total existencias en tiendas con evaluacion <=2 + suma existencias en tiendas que no alcancen stock minimo 

  INSERT INTO #TotalExistenciaMenorIgual2 (Articulo, Subcuenta, Existencia)
                                    SELECT Articulo, Subcuenta, SUM(a.Existencia)
                                    FROM (  SELECT SUM(ExistenciaActual) Existencia, Articulo, Subcuenta FROM WFGPlaneadorTraspaso WHERE /*articulo='0606' and*/ Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND CalificacionFinal <=1 GROUP BY Articulo, Subcuenta
                                            UNION ALL
                                            SELECT SUM(w.ExistenciaActual) Existencia, w.Articulo, w.Subcuenta
                                            FROM WFGPlaneadorTraspaso w
                                            LEFT JOIN (SELECT Sucursal, Articulo, Cantidad FROM WFGStockMinimo) ws on w.Sucursal=ws.Sucursal AND w.Articulo=ws.Articulo
										    LEFT JOIN WFGStockMinimoEmpresa wse on w.Sucursal=wse.Sucursal
                                            WHERE /*w.articulo='0606' and*/ w.Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND w.ExistenciaActual < ISNULL(ws.Cantidad, wse.Cantidad) AND CalificacionFinal > 1 AND CalificacionFinal < 2
                                            GROUP BY w.Articulo, Subcuenta
                                         )a 
										 --where a.articulo='0606'
										 GROUP BY Articulo, Subcuenta
 --SELECT * FROM #TotalExistenciaMenorIgual2 WHERE ARTICULO='FL900'
    

  --Total Vvp de tiendas con calificacion mayor o igual a 2
  INSERT INTO #SumaVvp (Articulo, Subcuenta, SumaVvp)
                 SELECT Articulo, ISNULL(Subcuenta,''), SUM(Vvp) 
                 FROM WFGPlaneadorTraspaso 
                 WHERE /*articulo='0606' and*/ Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND CalificacionFinal >= 2 
                 GROUP BY Articulo, ISNULL(Subcuenta,'')
   --SELECT * FROM #SumaVvp WHERE ARTICULO='FL900'

  INSERT INTO #PorcentajeVvp ( Sucursal,   Articulo,   Subcuenta,   PorcentajeVvp)
                        SELECT w.Sucursal, w.Articulo, w.Subcuenta, ((Vvp/SumaVvp))
                        FROM WFGPlaneadorTraspaso w
                        JOIN #SumaVvp s on w.Articulo=s.Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(s.Subcuenta,'')
                        WHERE /*w.articulo='0606' and*/ Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND CalificacionFinal >= 2

  --SELECT * FROM #PorcentajeVvp WHERE ARTICULO='FL900'

  CREATE TABLE #StockMinimo (Sucursal int null, Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, Stock float NULL)
  CREATE TABLE #CantTraspaso (Sucursal int NULL, Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, Existencia float NULL, CalifFinal float NULL, InvXDia float NULL)
  CREATE TABLE #WFGCantidadTraspasar(Sucursal int NULL, Articulo varchar(20) NULL, Subcuenta varchar(50) NULL, Existencia float NULL, CalifFinal float NULL, InvXDia float NULL, Ciclo int NULL, Stock float NULL, Proporcion float NULL, CantidadTraspasar float NULL, TotalInvXDia float NULL, Excluido bit NULL)
   
  --aqui compara contra el minimo
  INSERT INTO #StockMinimo (Sucursal, Articulo, Subcuenta, Stock)
                     SELECT t.Sucursal, t.Articulo, t.Subcuenta, ISNULL(ws.Cantidad, wse.Cantidad) stock
                     FROM WFGPlaneadorTraspaso t
                     LEFT JOIN (SELECT Sucursal, Articulo, Cantidad FROM WFGStockMinimo) ws on t.Sucursal=ws.Sucursal AND t.Articulo=ws.Articulo
                     LEFT JOIN WFGStockMinimoEmpresa wse on t.Sucursal=wse.Sucursal
--SELECT * FROM #StockMinimo WHERE ARTICULO='FL900'

  --delete from ResumenCantTraspaso

  /***** CALCULO CANTIDAD POSIBLE A TRASPASAR (1) ******/ 
  INSERT INTO ResumenCantTraspaso (Sucursal, Articulo, Subcuenta, Existencia, CalifFinal, InvXDia)
                  SELECT  DISTINCT s.Sucursal, s.Articulo, s.Subcuenta, ps.Existencia, s.CalifFinal, p.InvXDia
				  FROM #SucOrdenCalifFinal s
				  JOIN #PasoCalPeV ps on s.Sucursal=ps.Sucursal AND s.Articulo=ps.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(ps.Subcuenta,'')
				  JOIN #TotalExistencia t on s.Sucursal=t.Sucursal AND s.Articulo=t.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(t.Subcuenta,'')
                  JOIN #PasoInvXDia p on s.Sucursal=p.Sucursal AND s.Articulo=p.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(p.Subcuenta,'')
				  JOIN #PasoCalificaciones pc on s.Sucursal=pc.Sucursal and s.Articulo=pc.Articulo and ISNULL(s.Subcuenta,'')=ISNULL(pc.Subcuenta,'')
				  JOIN #StockMinimo st on s.Sucursal=st.Sucursal AND s.Articulo=st.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(st.Subcuenta,'')
				  --WHERE s.articulo='0606' AND s.subcuenta='C4T1'

  -- SELECT * FROM ResumenCantTraspaso WHERE ARTICULO='FL900' order by Sucursal
   DECLARE @TotalInvXDia float 

   INSERT INTO #WFGCantidadTraspasar (Sucursal, Articulo, Subcuenta, Existencia, CalifFinal, InvXDia, Ciclo, Stock)
                     SELECT  DISTINCT s.Sucursal, s.Articulo, s.Subcuenta, ps.Existencia, s.CalifFinal, p.InvXDia, 1, st.Stock
					 FROM #SucOrdenCalifFinal s
					 JOIN #PasoCalPeV ps on s.Sucursal=ps.Sucursal AND s.Articulo=ps.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(ps.Subcuenta,'')
					 JOIN #TotalExistencia t on s.Sucursal=t.Sucursal AND s.Articulo=t.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(t.Subcuenta,'')
					 JOIN #PasoInvXDia p on s.Sucursal=p.Sucursal AND s.Articulo=p.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(p.Subcuenta,'')
					 JOIN #PasoCalificaciones pc on s.Sucursal=pc.Sucursal AND s.Articulo=pc.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(pc.Subcuenta,'')
					 JOIN #StockMinimo st on s.Sucursal=st.Sucursal AND s.Articulo=st.Articulo AND ISNULL(s.Subcuenta,'')=ISNULL(st.Subcuenta,'')
					 --WHERE s.articulo='0606' and s.subcuenta='C4T1'

   --select * from #WFGCantidadTraspasar where articulo='016UP'

DECLARE @InvXDiaAnt float,
@InvXDiaR float,
@SucursalAnt	int,
@SucursalC      int,
@CantidadR      float,
@CantidadTraspasar float,
@CantidadT         float,
@CantTraspasar     float,
@CantidadRestante float,
@PropTraspaso     float


   DECLARE crCantPos1 CURSOR FAST_FORWARD FOR     
    SELECT DISTINCT Articulo, Subcuenta
	FROM #WFGCantidadTraspasar
	--WHERE ARTICULO='016UP'
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
	  -- IF @Articulo='68720' SELECT '1'
	   --INICIO: EVALUA SI EXISTENCIA ES MENOR A STOCK O A INVXDIA Y ORDENA POR CALIFICACION, TOMANDO EN CUENTA LA DE MENOR
	   SELECT TOP 1 @Sucursal=Sucursal, @InvDia=Existencia, @InvXDiaR=CASE WHEN Stock > InvXDia THEN Stock ELSE InvXDia END  
	   FROM #WFGCantidadTraspasar 
	   WHERE ((Existencia < Stock) OR (Existencia < InvXDia)) AND InvXDia >0 AND Ciclo=@CicloMax AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'') 
       ORDER BY CalifFinal DESC
	   --FIN: EVALUA SI EXISTENCIA ES MENOR A STOCK O A INVXDIA Y ORDENA POR CALIFICACION, TOMANDO EN CUENTA LA DE MENOR
	   --SELECT @Sucursal, @InvDia, @InvXDiaR
	    --ACTUALIZA InvXDia Anterior cuando el ciclo es mayor a 2 iteraciones

		IF @CicloMax=1
		BEGIN

		--SELECT @InvDia, @InvXDiaAnt
	   SELECT @InvDia=@InvDia-ISNULL(@InvXDiaAnt,0)

	   --TOTAL EXISTENCIAS POR ARTICULO Y SUBCUENTA
	   SELECT @TotalInvXDia=SUM(ISNULL(Existencia,0)) FROM #WFGCantidadTraspasar 
	   WHERE Articulo=@Articulo AND ISNULL(SubCuenta,'')=ISNULL(@Opcion,'')
	   AND Ciclo=@CicloMax
	   --SELECT @TotalInvXDia

	   --If @Articulo='68720' SELECT  @TotalInvXDia
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
	   select @CantidadTraspasar=NULL, @CantidadR=NULL	
       WHILE @@FETCH_STATUS = 0
       BEGIN    	  
	     --select @CantidadTraspasar=NULL, @CantidadR=NULL		 
	    --IF @Articulo='68720' SELECT * FROM #WFGCantidadTraspasar WHERE Articulo=@Articulo
		 SELECT @CantidadT=SUM(ISNULL(CantidadTraspasar,0)) FROM #WFGCantidadTraspasar WHERE Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'')
		  AND Ciclo=@CicloMax 

		 SELECT @CantidadR=@TotalInvXDia-ISNULL(@CantidadTraspasar,0)
	     --IF @Articulo='152MA' SELECT @CantidadT, @TotalInvXDia
		 IF @CantidadT <= @TotalInvXDia
		 BEGIN
		   UPDATE #WFGCantidadTraspasar SET CantidadTraspasar=CASE WHEN @CantidadR >= @TotalInvXDia THEN CASE WHEN Stock > InvXDia THEN Stock ELSE InvXDia END ELSE ISNULL(@CantidadR,0) END
		   WHERE Sucursal=@SucursalC AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'') AND Ciclo=@CicloMax
		 
		   SELECT @CantidadTraspasar=CantidadTraspasar FROM #WFGCantidadTraspasar WHERE Sucursal=@SucursalC AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'')
		   AND Ciclo=@CicloMax		   
		   --select @cantidadtraspasar, @Totalinvxdia
		   --IF @Articulo='68720' SELECT * FROM #WFGCantidadTraspasar WHERE Articulo=@Articulo
		 END	 		 
	     
       FETCH NEXT FROM crCantTras INTO  @SucursalC
       END    
       CLOSE crCantTras
       DEALLOCATE crCantTras 

	   UPDATE #WFGCantidadTraspasar SET TotalInvXDia=ISNULL(@TotalInvXDia,0)        WHERE /*Sucursal <> @Sucursal AND*/ Ciclo=@CicloMax AND Articulo=@Articulo AND isnull(Subcuenta,'')=isnull(@Opcion,'')

	   --Excluir items donde cantidadtraspasar es menor a STock o InvXDia
	   UPDATE #WFGCantidadTraspasar SET Excluido=1 WHERE Ciclo=@CicloMax AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'')
	   AND CantidadTraspasar < CASE WHEN Stock > InvXDia THEN Stock ELSE InvXDia END
	   --IF @Articulo='68720' SELECT * FROM #WFGCantidadTraspasar WHERE Articulo=@Articulo
	   UPDATE #WFGCantidadTraspasar SET Proporcion  =Existencia/ISNULL(@InvXDiaR,0) 
	   WHERE Ciclo=@CicloMax AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=isnull(@Opcion,'')
	   AND ISNULL(Excluido,0)=0
	   
	   --Incrementamos Ciclo
	   SELECT @CicloMax=@CicloMax+1	
	   
	   INSERT INTO #WFGCantidadTraspasar (Sucursal, Articulo, Subcuenta, Existencia, CalifFinal, InvXDia,                                                                                       
	                                      Ciclo,    Stock,    Excluido)
	   	                           SELECT Sucursal, Articulo, Subcuenta, Existencia, CalifFinal, CASE WHEN ISNULL(Excluido,0)=1 THEN 0 ELSE InvXDia END, 
								          @CicloMax, CASE WHEN ISNULL(Excluido,0)=1 THEN 0 ELSE Stock END, Excluido
								   FROM #WFGCantidadTraspasar WHERE Ciclo=@CicloMax-1 AND Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Opcion,'')
		--IF @Articulo='68720' SELECT 'c',* FROM #WFGCantidadTraspasar WHERE Articulo=@Articulo
	   END
	    --select @ciclomax
	   	IF @CicloMax>=2
		BEGIN	
	      SELECT @CantTraspasar=SUM(CantidadTraspasar)
          FROM #WFGCantidadTraspasar w 
	      WHERE w.Ciclo=1 AND w.Articulo=@Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(@Opcion,'') 
		  AND ISNULL(Excluido,0)=0
		  --IF @Articulo='68720' select @CantTraspasar

		  SELECT @CantidadRestante=@TotalInvXDia - @CantTraspasar

		  
		  UPDATE w SET Proporcion=w1.CantidadTraspasar/@CantTraspasar
		  FROM #WFGCantidadTraspasar w 
		  JOIN #WFGCantidadTraspasar w1 on w.Articulo=w1.Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(w1.Subcuenta,'') 
	      WHERE w1.Ciclo=@CicloMax-1 AND w.Articulo=@Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(@Opcion,'') 
		  AND ISNULL(w.Excluido,0)=0 AND ISNULL(w1.Excluido,0)=0 AND w.Ciclo=@CicloMax AND w.Sucursal=w1.Sucursal
		  --IF @Articulo='68720' SELECT 'D',* FROM #WFGCantidadTraspasar WHERE Articulo=@Articulo
		  --Reparte Cantidad no excluidos
		  UPDATE w SET CantidadTraspasar=(ISNULL(w.Proporcion,0)*ISNULL(@CantidadRestante,0))+w1.CantidadTraspasar
		  FROM #WFGCantidadTraspasar w 
		  JOIN #WFGCantidadTraspasar w1 on w.Articulo=w1.Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(w1.Subcuenta,'') 
	      WHERE w1.Ciclo=@CicloMax-1 AND w.Articulo=@Articulo AND ISNULL(w.Subcuenta,'')=ISNULL(@Opcion,'') 
		  AND ISNULL(w.Excluido,0)=0 AND ISNULL(w1.Excluido,0)=0 AND w.Ciclo=@CicloMax AND w.Sucursal=w1.Sucursal


		END
	   --If @Articulo='68720' SELECT * FROM #WFGCantidadTraspasar WHERE Articulo=@Articulo
   
     END 
	 ---FIN EXCLUIR ITEMS CON EXISTENCIA SUFICIENTE  
   FETCH NEXT FROM crCantPos1 INTO  @Articulo, @Opcion
   END    
   CLOSE crCantPos1
   DEALLOCATE crCantPos1  
   --select 'm',* from #WFGCantidadTraspasar  where articulo='016up'

   CREATE TABLE #CicloMax (CicloMax int null, Articulo varchar(20) null, Subcuenta varchar(50) null, sucursal int null)
   INSERT #CicloMax (CicloMax, Articulo, Subcuenta, Sucursal)
   SELECT MAX(Ciclo), Articulo, ISNULL(Subcuenta,''), Sucursal 
   FROM #WFGCantidadTraspasar GROUP BY Articulo, Subcuenta, Sucursal   
   --select * from #CicloMax WHERE ARTICULO='016up'

   CREATE TABLE #WFGCantTraspasaCicloMax(Articulo varchar(20) null, Subcuenta varchar(50) null, Sucursal int null, Existencia float NULL, CalifFinal float null, InvXDia float null, Ciclo int null, Stock float null, CantidadTraspasar float null)
   CREATE TABLE #TotalInvXDia (InvXDia float null, Articulo varchar(20) null, Subcuenta varchar(50) null)
   CREATE TABLE #Recibir1 (Articulo varchar(20) null, Subcuenta varchar(50) null, Sucursal int null, Cantidad float null)
   CREATE TABLE #Recibir2 (Articulo varchar(20) null, Subcuenta varchar(50) null, Sucursal int null, Cantidad float null)
   CREATE TABLE #SumCalifFinal (CalifFinal float null, Articulo varchar(20) null, Subcuenta varchar(50) null)
   CREATE TABLE #Recibir3 (Articulo varchar(20) null, Subcuenta varchar(50) null, Sucursal int null, Cantidad float null)
   CREATE TABLE #Reparte (Cantidad float null, Articulo varchar(20) null, Subcuenta varchar(50) null, Sucursal int null, InvXDia float null )
   CREATE TABLE #PropCantidadTraspasa (CantidadTraspasar float null, Articulo varchar(20) null, Subcuenta varchar(50) null, Sucursal int null)

   
   INSERT INTO #WFGCantTraspasaCicloMax
   SELECT w.Articulo, w.Subcuenta, w.Sucursal, w.Existencia, w.califFinal, w.InvXDia, w.Ciclo, w.Stock, CantidadTraspasar
   FROM #WFGCantidadTraspasar w 
   JOIN #CicloMax c ON w.Ciclo=c.CicloMax AND w.Articulo=c.Articulo AND w.Sucursal=c.Sucursal AND ISNULL(w.Subcuenta,'')=ISNULL(c.Subcuenta,'')
   --AND ISNULL(Excluido,0)=0

   --SELECT 'H', * FROM #WFGCantTraspasaCicloMax WHERE ARTICULO='016UP'

   INSERT INTO #Recibir1
   SELECT DISTINCT w.Articulo, w.Subcuenta, w.Sucursal, 0
   FROM #WFGCantTraspasaCicloMax w   
   --SELECT * FROM #Recibir1 WHERE ARTICULO='016up'

   INSERT INTO #Recibir2
   SELECT DISTINCT w.Articulo, w.Subcuenta, w.Sucursal, 0
   FROM #WFGCantTraspasaCicloMax w      
   --SELECT * FROM #Recibir2 WHERE ARTICULO='FL900'

   INSERT INTO #Recibir3
   SELECT DISTINCT w.Articulo, w.Subcuenta, w.Sucursal, 0
   FROM #WFGCantTraspasaCicloMax w
   --SELECT * FROM #Recibir3 WHERE ARTICULO='016up'
   --Select * from #WFGCantTraspasaCicloMax WHERE ARTICULO='016up'

   declare @TotalExistInvXDia0 float,
           @Recibir1           float,
           @B                  float,
		   @Art2               varchar(20), 
		   @Subcuenta1         varchar(50), 
		   @Suc2                  int, 
		   @Diferencia            float,
		   @TotalExistInvXDia02   float,
		   @SumCalifFinal         float

		  --select '2',* from #WFGCantTraspasaCicloMax WHERE Articulo='016up'


   /*DECLARE crPlaneador CURSOR FAST_FORWARD FOR
   SELECT DISTINCT Articulo, Subcuenta
   FROM #WFGCantTraspasaCicloMax
	where articulo='016UP'
   OPEN crPlaneador 
   FETCH NEXT FROM crPlaneador INTO @Articulo, @Subcuenta
   WHILE @@FETCH_STATUS=0
   BEGIN
     IF EXISTS(SELECT * FROM #WFGCantTraspasaCicloMax w WHERE Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'') AND w.InvXDia=0)
	 BEGIN --(1)	      
       SELECT @TotalExistInvXDia0=SUM(t.Existencia) --(a)
       FROM #WFGCantTraspasaCicloMax t 
       WHERE ISNULL(t.InvXDia,0)=0 AND t.Articulo=@Articulo AND ISNULL(t.Subcuenta,'')=ISNULL(@Subcuenta,'')

       
	   IF EXISTS(SELECT * FROM #WFGCantTraspasaCicloMax w WHERE Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'') AND Existencia < InvXDia)
       BEGIN --(2)
	     SELECT @B=SUM(InvXDia-isnull(Existencia,0))
		 FROM #WFGCantTraspasaCicloMax 
		 WHERE Articulo=@Articulo AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'') AND Existencia < InvXDia
	   END --(2)
	   
	   --SELECT @TotalExistInvXDia0, @b
	   IF @TotalExistInvXDia0 - isnull(@B,0) >0
	   BEGIN --(3)
	     UPDATE r SET r.Cantidad=CASE WHEN w.InvXDia > w.Existencia THEN w.InvXDia-w.Existencia ELSE 0 END
	     FROM #Recibir1 r
	     JOIN #WFGCantTraspasaCicloMax w on r.Articulo=w.Articulo AND ISNULL(r.Subcuenta,'')=ISNULL(w.Subcuenta,'') and r.Sucursal=w.Sucursal
         WHERE r.Articulo=@Articulo AND ISNULL(r.Subcuenta,'')=ISNULL(@Subcuenta,'') 		 
	   END --(3)
	   ELSE
	   BEGIN --(4)
	       select @TotalExistInvXDia02=@TotalExistInvXDia0
	      DECLARE crReparte CURSOR FAST_FORWARD FOR
	       SELECT Articulo, Subcuenta, Sucursal, InvXDia-Existencia
		   FROM #WFGCantTraspasaCicloMax
		   WHERE (Existencia < InvXDia) AND Articulo=@Articulo and ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')
		   ORDER BY CalifFinal DESC
		  OPEN crReparte
		  FETCH NEXT FROM crReparte INTO @Art2, @Subcuenta1, @Suc2, @Diferencia
		  WHILE @@FETCH_STATUS=0 and @TotalExistInvXDia02 >0
		  BEGIN
		    IF (@TotalExistInvXDia02 >= @Diferencia)  
			BEGIN --(5)
			  UPDATE #Recibir1 SET Cantidad=@Diferencia
			  WHERE Articulo=@Art2 and ISNULL(Subcuenta,'')=ISNULL(@Subcuenta1,'') and Sucursal=@Suc2
			  SELECT @TotalExistInvXDia02=@TotalExistInvXDia02-@Diferencia			
			END --(5)
			ELSE
			BEGIN --(6)
			   UPDATE #Recibir1 SET Cantidad=@TotalExistInvXDia02
			   WHERE Articulo=@Art2 and ISNULL(Subcuenta,'')=ISNULL(@Subcuenta1,'') and Sucursal=@Suc2
			   SELECT @TotalExistInvXDia02=0
			END   --(6)
		   FETCH NEXT FROM crReparte INTO @Art2, @Subcuenta1, @Suc2, @Diferencia
		   END
		   CLOSE crReparte
           DEALLOCATE crReparte	  
	   END --(4)
	   IF @TotalExistInvXDia0 - isnull(@B,0) >0
	   BEGIN --(7)
	     SELECT @TotalExistInvXDia02=@TotalExistInvXDia0-isnull(@B,0)
         
		 SELECT @SumCalifFinal=SUM(CalifFinal)
		 FROM #WFGCantTraspasaCicloMax
		 WHERE InvXDia>0
		 GROUP BY Articulo, ISNULL(Subcuenta,'')

		 TRUNCATE TABLE #PropCantidadTraspasa
		 
         INSERT INTO #PropCantidadTraspasa (CantidadTraspasar, Articulo, Subcuenta, Sucursal)
         SELECT ((w.CalifFinal/@SumCalifFinal)*@TotalExistInvXDia02) Proporcion, w.Articulo, ISNULL(w.Subcuenta,''), w.Sucursal
         FROM #WFGCantTraspasaCicloMax w
		 WHERE w.InvXDia>0
        
        UPDATE r set Cantidad=CantidadTraspasar
		FROM #Recibir2 r
		JOIN #PropCantidadTraspasa p on r.Articulo=p.Articulo and ISNULL(r.Subcuenta,'')=ISNULL(p.Subcuenta,'') and r.Sucursal=p.Sucursal
		WHERE r.Articulo=@Articulo AND ISNULL(r.Subcuenta,'')=ISNULL(@Subcuenta,'')
	   END --(7) 
	 END --(1)

	 TRUNCATE TABLE #Reparte
	
	 INSERT INTO #Reparte
	 SELECT r1.Cantidad+r2.cantidad+w.Existencia, w.Articulo, ISNULL(w.Subcuenta,''), w.Sucursal, w.InvXDia
	 FROM #Recibir1 r1
	 JOIN #Recibir2 r2 on r1.Articulo=r2.Articulo and ISNULL(r1.Subcuenta,'')=ISNULL(r2.Subcuenta,'') and r1.Sucursal=r2.Sucursal
	 JOIN #WFGCantTraspasaCicloMax w on r1.Articulo=w.Articulo and ISNULL(r1.Subcuenta,'')=ISNULL(w.Subcuenta,'') and r1.Sucursal=w.Sucursal
	 WHERE r1.Articulo=@Articulo and ISNULL(r1.Subcuenta,'')=ISNULL(@Subcuenta,'')

	 UPDATE r set r.Cantidad=CASE WHEN re.Cantidad < re.InvXDia THEN re.InvXDia-re.Cantidad ELSE 0 END
	 FROM #Recibir3 r
	 join #Reparte re on r.Articulo=re.Articulo and ISNULL(r.Subcuenta,'')=ISNULL(re.Subcuenta,'') and r.Sucursal=re.Sucursal
	 WHERE r.Articulo=@Articulo and ISNULL(r.Subcuenta,'')=ISNULL(@Subcuenta,'')

	 --select * from #Recibir1
	 --select * from #Recibir2
	 --select * from #Recibir3

	 UPDATE w set w.CantidadTraspasar=r1.cantidad+r2.cantidad+r3.cantidad
	 FROM #WFGCantTraspasaCicloMax w
	 JOIN #Recibir1 r1 on w.Articulo=r1.Articulo and ISNULL(w.Subcuenta,'')=ISNULL(r1.Subcuenta,'') and w.Sucursal=r1.Sucursal
	 JOIN #Recibir2 r2 on r1.Articulo=r2.Articulo and ISNULL(r1.Subcuenta,'')=ISNULL(r2.Subcuenta,'') and r1.Sucursal=r2.Sucursal
	 JOIN #Recibir3 r3 on r1.Articulo=r3.Articulo and ISNULL(r1.Subcuenta,'')=ISNULL(r3.Subcuenta,'') and r1.Sucursal=r3.Sucursal
	 WHERE w.Articulo=@Articulo and ISNULL(w.Subcuenta,'')=ISNULL(@Subcuenta,'')

	 --IF @Articulo='0606' AND @SubCuenta='c4T1'
		select 1,* from #WFGCantTraspasaCicloMax WHERE Articulo='016UP'
	 
	 FETCH NEXT FROM crPlaneador INTO @Articulo, @Subcuenta
     END
	 CLOSE crPlaneador
     DEALLOCATE crPlaneador	 */
	 
	-- select * from #WFGCantidadTraspasar WHERE ARTICULO='016UP'
	 --select 1,* from #WFGCantTraspasaCicloMax WHERE Articulo='016UP'
	 --select * from #WFGCantTraspasaCicloMax WHERE Articulo=@Articulo AND Subcuenta=@Subcuenta

     CREATE TABLE #SucCalifMax (Sucursal int null, Articulo varchar(20) null, Subcuenta varchar(50) null, CalifMax float null)
     DECLARE @CalifFinalMax float,
             @SucMax        int

     --select * from WFGPlaneadorTraspaso where Articulo='68720'
     DECLARE crSucMax CURSOR FAST_FORWARD FOR
       SELECT DISTINCT Articulo, ISNULL(SubCuenta,'')
       FROM WFGPlaneadorTraspaso
	   --WHERE ARTICULO='016UP'
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
	 ---OBTIENE PARTE ENTERA
	 UPDATE w SET w.RecibeTraspaso=1, w.CantidadATraspasar=FLOOR(c.CantidadTraspasar)
     FROM WFGPlaneadorTraspaso w
     JOIN #WFGCantTraspasaCicloMax c ON w.Articulo=c.Articulo AND w.Sucursal=c.Sucursal AND  ISNULL(w.Subcuenta,'')=ISNULL(c.Subcuenta,'')
     WHERE w.Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND c.CantidadTraspasar>0

	 select * from WFGPlaneadorTraspaso where articulo='68720'

	 --OBTIENE PARTE DECIMAL
	 CREATE TABLE #SumaCantDec (CantidadTraspasaDec float null, Articulo varchar(20) null, Subcuenta varchar(20) null)
     INSERT INTO #SumaCantDec (CantidadTraspasaDec, Articulo, Subcuenta)
     SELECT SUM(c.CantidadTraspasar-FLOOR(c.CantidadTraspasar)), Articulo, ISNULL(Subcuenta,'')
     FROM #WFGCantTraspasaCicloMax c
     GROUP BY Articulo, ISNULL(Subcuenta,'')

	 --select * from #SumaCantDec where articulo='68720'

	 --select 'c',sucursal, TraspasaASuc, RecibeTraspaso, CantidadATraspasar, * from WFGPlaneadorTraspaso where articulo='68720'-- and subcuenta='c4t1' order by 1 
	 IF @Articulo='68720' SELECT c.CantidadATraspasar+d.CantidadTraspasaDec
     FROM WFGPlaneadorTraspaso c
     JOIN #SucCalifMax s on c.articulo=s.articulo and ISNULL(c.Subcuenta,'')=ISNULL(s.Subcuenta,'') and c.sucursal=s.sucursal
     JOIN #SumaCantDec d on c.articulo=d.articulo and ISNULL(c.Subcuenta,'')=ISNULL(d.Subcuenta,'')

     UPDATE c set c.CantidadATraspasar=c.CantidadATraspasar+d.CantidadTraspasaDec
     FROM WFGPlaneadorTraspaso c
     JOIN #SucCalifMax s on c.articulo=s.articulo and ISNULL(c.Subcuenta,'')=ISNULL(s.Subcuenta,'') and c.sucursal=s.sucursal
     JOIN #SumaCantDec d on c.articulo=d.articulo and ISNULL(c.Subcuenta,'')=ISNULL(d.Subcuenta,'') 

	 --select * from WFGPlaneadorTraspaso where articulo='68720'
	 
	 UPDATE w SET w.TraspasaASuc=1
     FROM WFGPlaneadorTraspaso w
     JOIN #WFGCantTraspasaCicloMax c ON w.Articulo=c.Articulo AND w.Sucursal=c.Sucursal AND  ISNULL(w.Subcuenta,'')=ISNULL(c.Subcuenta,'')
     WHERE w.Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad) AND isnull(c.CantidadTraspasar,0)=0

	 --select sucursal, TraspasaASuc, RecibeTraspaso, CantidadATraspasar, * from WFGPlaneadorTraspaso where articulo='016up' --and subcuenta='c4t1' order by 1 

	 /* R E P O R T E*/
	 TRUNCATE TABLE WFGRPTPlaneadorTraspaso
	 INSERT INTO WFGRPTPlaneadorTraspaso (Sucursal,         NombreSuc, Articulo,        Descripcion, VVP,             CalificacionVVP,   VelocidadMaxima, CalificacionVM, TotalVentas,
                                          ExistenciaActual, PeV,       CalificacionPeV, PeF,         CalificacionPeF, CalificacionFinal, TraspasaASuc,    RecibeTraspaso, CantidadATraspasar, Subcuenta,			DiasSurtir,	DOF)
                                   SELECT Sucursal,         NombreSuc, Articulo,        Descripcion, VVP,             CalificacionVVP,   VelocidadMaxima, CalificacionVM, TotalVentas,
								          ExistenciaActual, PeV,       CalificacionPeV, PeF,         CalificacionPeF, CalificacionFinal, TraspasaASuc,    RecibeTraspaso, CantidadATraspasar, ISNULL(Subcuenta,''), @DiasSurtir,@DiasSurtir*vvp
                                   FROM WFGPlaneadorTraspaso w
                                   WHERE w.Sucursal IN (SELECT DISTINCT SucursalO FROM WFGPrioridad)     
	 
     --select * from WFGPlaneadorTraspaso where articulo='fl900' /*and subcuenta='c1t2'*/ and traspasaasuc=1
     --select * from WFGPlaneadorTraspaso where articulo='fl900' /*and subcuenta='c1t2'*/ and recibetraspaso=1
     --select * from WFGRPTPlaneadorTraspaso /*where ARTICULO='0606' AND subcuenta='C4T1'*/ ORDER BY Articulo,Subcuenta,Sucursal
	 
	 CREATE  TABLE #WfgPrioridadNum ( Prioridad int, SucursalO int, NombreSucO varchar(255), SucursalD int, NombreSucD varchar(255))
     CREATE  TABLE #WfgPrioridadNum2 (ID int ,  SucursalO int, NombreSucO varchar(255), SucursalD int, NombreSucD varchar(255))

     DECLARE @CantDisponible float
	 --@SucursalO int,
     --        @sucursalD int


     DECLARE crWfgSucP CURSOR FAST_FORWARD FOR
	   SELECT DISTINCT SucursalO FROM wFGPRIORIDAD
     OPEN crWfgSucP
     FETCH NEXT FROM crWfgSucP INTO 	@SucursalO
     WHILE @@FETCH_STATUS=0
     BEGIN
	   INSERT INTO #WfgPrioridadNum	  	
	   SELECT  ROW_NUMBER() OVER (ORDER BY ID) as num, SucursalO as so, NombreSucO as nomso, SucursalD as sd, NombreSucD as nomsd
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
 	   INSERT INTO #WfgPrioridadNum2 (ID,SucursalO,NombreSucO,SucursalD,NombreSucD)
		                       SELECT ROW_NUMBER() OVER (Order BY Prioridad),SucursalO,NombreSucO,SucursalD,NombreSucD 
			                   FROM #WfgPrioridadNum WHERE SucursalD=@SucursalD
	
	 FETCH NEXT FROM crWFGSuc2 INTO @SucursalD
     END
     CLOSE crWFGSuc2
     DEALLOCATE crWFGSuc2

	 CREATE TABLE #Disponible (Sucursal int, Articulo varchar(20), Subcuenta varchar(50) NULL, Disponible float)
	 INSERT INTO #Disponible
		 SELECT  Sucursal, Articulo, Subcuenta, Existencia
		 FROM #WFGCantTraspasaCicloMax
		 WHERE ISNULL(CantidadTraspasar,0)=0
		--SELECT * FROM #Disponible where articulo='016UP'

     UPDATE WFGPlaneadorTraspaso SET CantidadATraspasar=ISNULL(CantidadATraspasar,0)-ISNULL(ExistenciaActual,0) WHERE ISNULL(CantidadATraspasar,0)>0	 
	 --SELECT * FROM WFGPlaneadorTraspaso WHERE Articulo='016UP'

	 --------------------------------------------------------------------------------------------
     ------Obtiene existenciaActual sucursales que traspasan
     --select 'P'
	
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
	 --SELECT 'P'
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
       --SELECT @@FETCH_STATUS
	   WHILE @@FETCH_STATUS = 0 AND ISNULL(@TotalCantidadTraspaso,0)<>@CantTraspasa
       BEGIN 
        --SELECT @SucursalD,@SucursalO 
		 --SELECT @CantDisponible=Existencia-InvXDia from #WFGCantTraspasaCicloMax WHERE Sucursal=@SucursalO and Articulo=@ArticuloD and ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')
		 SELECT @CantDisponible=Disponible FROM #Disponible WHERE Sucursal=@SucursalO and Articulo=@ArticuloD and ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')
		 IF @CantDisponible <= @CantTraspasa-ISNULL(@TotalCantidadTraspaso,0) AND @CantDisponible>0
		 BEGIN
		   INSERT INTO #Traspasos (AlmacenO,   AlmacenD,   SucursalO,  SucursalD,  Articulo,   Subcuenta,  CantidadTraspasada)
                            SELECT @AlmacenO,  @AlmacenD,  @SucursalO, @SucursalD, @ArticuloD, @Subcuenta, @CantDisponible		   	
		   
		   ---HASTA AQUI REVISAMOS

		   --SELECT 2.1,@SucursalD SucD,@SucursalO SucO,@CantTraspasa CT,@CantDisponible CD,ISNULL(@TotalCantidadTraspaso,0) TCT,* FROM #Disponible
		   UPDATE #Disponible SET Disponible=ROUND(Disponible-@CantDisponible,2) WHERE Sucursal=@SucursalO AND Articulo=@ArticuloD AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')
		   	--SELECT 2.2,@SucursalD SucD,@SucursalO SucO,@CantTraspasa CT,@CantDisponible CD,ISNULL(@TotalCantidadTraspaso,0) TCT,* FROM #Disponible
			
			SELECT  @TotalCantidadTraspaso=ISNULL(SUM(ISNULL(CantidadTraspasada,0)),0) FROM #Traspasos WHERE SucursalD=@SucursalD AND Articulo=@ArticuloD AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')		 	  
	       SELECT  @RestaCantidadTraspaso=ISNULL(@CantTraspasa-ISNULL(@TotalCantidadTraspaso,0),0)
		 
		 END
		 ELSE IF @CantDisponible > @CantTraspasa-ISNULL(@TotalCantidadTraspaso,0)
		 BEGIN
		   
		   INSERT INTO #Traspasos (AlmacenO,   AlmacenD,   SucursalO,  SucursalD,  Articulo,   Subcuenta,  CantidadTraspasada)
                            SELECT @AlmacenO,  @AlmacenD,  @SucursalO, @SucursalD, @ArticuloD, @Subcuenta, @CantTraspasa-ISNULL(@TotalCantidadTraspaso,0)

         -- SELECT 3.1,@SucursalD SucD,@SucursalO SucO,@CantTraspasa CT,@CantDisponible CD,ISNULL(@TotalCantidadTraspaso,0) TCT,Disponible,Disponible-(@CantTraspasa-ISNULL(@TotalCantidadTraspaso,0)) FROM #Disponible --WHERE Sucursal=@SucursalO AND Articulo=@ArticuloD AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')
		  
		  UPDATE #Disponible set Disponible=ROUND(Disponible-(@CantTraspasa-ISNULL(@TotalCantidadTraspaso,0)),2) WHERE Sucursal=@SucursalO AND Articulo=@ArticuloD AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')
			--SELECT 3.2,@SucursalD SucD,@SucursalO SucO,@CantTraspasa CT,@CantDisponible CD,ISNULL(@TotalCantidadTraspaso,0) TCT,Disponible,Disponible-(@CantTraspasa-ISNULL(@TotalCantidadTraspaso,0))  FROM #Disponible-- WHERE Sucursal=@SucursalO AND Articulo=@ArticuloD AND ISNULL(Subcuenta,'')=ISNULL(@Subcuenta,'')
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

  -- SELECT '1', * FROM #Traspasos 
  --SELECT * FROM WFGPlaneadorTraspaso WHERE TraspasaASuc=1 AND ARTICULO='0606' AND SUBCUENTA='C1T2'
  --select * from #Traspasos where subcuenta='c1t2' --order by SucursalD

  INSERT INTO WFGTraspaso ( AlmacenO,   AlmacenD,   SucursalO,   NomSucO,   SucursalD,   NomSucD,   Articulo,   ArtDescripcion,  Subcuenta, CantidadTraspaso,     Accion,     Estado, Fecha)
                     SELECT t.AlmacenO, t.AlmacenD, t.SucursalO, so.Nombre, t.SucursalD, sd.Nombre, t.Articulo, a.Descripcion1,  Subcuenta, t.CantidadTraspasada, 'Traspaso', 'Plan', @Fecha
					 FROM #Traspasos t
					 JOIN Sucursal so on t.SucursalO=so.Sucursal
					 JOIN Sucursal sd on t.SucursalD=sd.Sucursal
					 JOIN Art a on t.Articulo=a.Articulo
					 --where a.articulo='0606' */
	SELECT * FROM WFGTraspaso

 --SELECT * FROM WFGTraspaso where articulo='zta-bb-233' and subcuenta='t1' order by articulo
 --select * from WFGPlaneadorTraspaso where articulo='0606' AND Subcuenta='C1T2' and traspasaasuc=1
 -- select * from WFGPlaneadorTraspaso where articulo='0606' AND Subcuenta='C1T2' and recibetraspaso=1
-- SELECT * FROM #WFGPlaneadorTraspasoJob*/

RETURN
END
GO

BEGIN TRANSACTION
EXEC spWFGPlaneadorTraspaso '20180101', '20180108', 'E001', 7
--EXEC xpWFGVisRPTCalif
ROLLBACK

