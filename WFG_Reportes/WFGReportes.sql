SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
GO

/**************** spWFGRPTACC ****************/
IF EXISTS (select * from sysobjects where id = object_id('dbo.spWFGRPTACC') and type = 'P') drop procedure dbo.spWFGRPTACC
GO
CREATE PROCEDURE spWFGRPTACC
@FechaD    datetime,
@FechaA    datetime,
@Categoria varchar(50)
AS BEGIN
  DECLARE @Promedio float

  DECLARE @RPTACC TABLE (ClaveSucursal int NULL, NombreSucursal varchar(20) NULL, Grupo varchar(50) NULL, NombreGrupo varchar(20) NULL, Categoria varchar(50) NULL, SubLinea varchar(50) NULL, OH float NULL, OO float NULL, Sold float NULL, Sales float NULL, COGS float NULL,
                         Profit float NULL,	Mkdn1 float NULL, Mkdn2 float NULL,	Mrg float NULL, PromedioWFG float NULL)

  CREATE TABLE #ArtSucCat  (Sucursal int NULL,    Articulo varchar(20) NULL,  Grupo     varchar(50) NULL, Categoria varchar(50) NULL,  SubLinea   varchar(50) NULL)
  CREATE TABLE #Disponible (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, SubLinea varchar(50)  NULL,  Disponible float NULL)
  CREATE TABLE #Ventas     (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, SubLinea varchar(50)  NULL,  Sold       float NULL, Sales float NULL, COGS float NULL,
                            Profit   float NULL,  Mkdn1    float       NULL,  Mkdn2     float       NULL, Mrg      float        NULL)
  CREATE TABLE #VentaTotal (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, SubLinea varchar(50)  NULL,  Sold       float NULL, Sales float NULL, COGS float NULL,
                            Profit   float NULL,  Mkdn1    float       NULL,  Mkdn2     float       NULL, Mrg      float        NULL)
  

  INSERT INTO #ArtSucCat (Sucursal,   Articulo,   Grupo,   Categoria,   SubLinea )
                   SELECT s.Sucursal, a.Articulo, a.Grupo, a.Categoria, a.WFGArtSubLinea
                   FROM Sucursal s
                   CROSS JOIN Art a	 
				   WHERE a.Categoria=@Categoria AND a.Estatus='ALTA' AND s.Estatus='ALTA'
  --select * from #ArtSucCat order by Sucursal  

  INSERT INTO #Disponible (Sucursal, Grupo, Categoria, SubLinea, Disponible)
  SELECT s.Sucursal, s.Grupo, s.Categoria, s.SubLinea, SUM((ISNULL(su2.SaldoU,0)-ISNULL(su3.SaldoU,0))-ISNULL(su.SaldoU,0)) Disponible
  FROM #ArtSucCat s
  LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea, SUM(SaldoU) SaldoU
             FROM SaldoU su  
             JOIN Art a ON su.Cuenta=a.Articulo
			 WHERE su.Rama='RESV' AND a.Categoria=@Categoria
			 GROUP BY su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea)su ON s.Sucursal=su.Sucursal AND s.Articulo=su.Cuenta  
  LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea, SUM(SaldoU) SaldoU
             FROM SaldoU su  
             JOIN Art a ON su.Cuenta=a.Articulo
			 WHERE su.Rama='INV' AND a.Categoria=@Categoria
			 GROUP BY su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea)su2 ON s.Sucursal=su2.Sucursal AND s.Articulo=su2.Cuenta		
  LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea, SUM(SaldoU) SaldoU
             FROM SaldoU su  
             JOIN Art a ON su.Cuenta=a.Articulo
			 WHERE su.Rama='VMOS' AND a.Categoria=@Categoria
			 GROUP BY su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea)su3 ON s.Sucursal=su3.Sucursal AND s.Articulo=su3.Cuenta	 			  
   GROUP BY s.Sucursal, s.Grupo, s.Categoria, s.SubLinea

   INSERT INTO #Ventas (Sucursal,   Grupo,   Categoria,   SubLinea,         Sold,                              Sales,                      COGS, 
                        Profit,                                Mkdn1,       Mkdn2,                             Mrg)
                 SELECT v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea, SUM((ISNULL(vd.Cantidad,0))) Sold, SUM(Cantidad*Precio) Sales, SUM(Costo) COGS, 
                       SUM(Cantidad*Precio)- SUM(Costo) Profit, null,       SUM(DescuentoImporte) Mkdns2,      (SUM(Cantidad*Precio)- SUM(Costo)/SUM(Cantidad*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on vd.ID=v.ID
                 JOIN Art a on vd.Articulo=a.Articulo
                 WHERE v.Mov='Nota' 
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus IN ('CONCLUIDO','PROCESAR')
                 AND a.Categoria=@Categoria
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea
				 UNION
                 SELECT v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea, SUM((ISNULL(vd.Cantidad,0))) Sold, SUM(Cantidad*Precio) Sales, SUM(Costo) COGS, 
                       SUM(Cantidad*Precio)- SUM(Costo) Profit, null,       SUM(DescuentoImporte) Mkdns2,      (SUM(Cantidad*Precio)- SUM(Costo)/SUM(Cantidad*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on v.ID=vd.ID
                 JOIN Art a on vd.Articulo=a.Articulo 
                 WHERE Mov='Factura Credito'
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus='CONCLUIDO'
                 AND a.Categoria=@Categoria
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea
				 UNION
                 SELECT v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea, SUM((ISNULL(vd.CantidadReservada,0))) Sold, SUM(CantidadReservada*Precio) Sales, SUM(Costo) COGS, 
                       SUM(CantidadReservada*Precio)- SUM(Costo) Profit, null,  SUM(DescuentoImporte) Mkdns2,      (SUM(CantidadReservada*Precio)- SUM(Costo)/SUM(CantidadReservada*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on v.ID=vd.ID
                 JOIN Art a on vd.Articulo=a.Articulo
                 WHERE Mov='Pedido'
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus='PENDIENTE'
                 AND a.Categoria=@Categoria
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea

   INSERT INTO #VentaTotal (Sucursal,     Grupo,   Categoria,   SubLinea,         Sold,         Sales,        COGS, 
                            Profit,       Mkdn1,   Mkdn2,       Mrg)
					SELECT  Sucursal,     Grupo,   Categoria,   SubLinea,         SUM(Sold),    SUM(Sales),   SUM(COGS),
					        SUM(Profit),  NULL,    SUM(Mkdn2),  SUM(Mrg)
					FROM #Ventas v
					GROUP BY v.Sucursal, v.Grupo, v.Categoria, v.SubLinea

   --SELECT * FROM #Disponible ORDER BY Sucursal
  INSERT INTO @RPTACC (ClaveSucursal, Grupo, Categoria, SubLinea, Sold, Sales, COGS, Profit, Mkdn1, Mkdn2, Mrg)
  SELECT DISTINCT sc.Sucursal, sc.Grupo, sc.Categoria, sc.SubLinea, ISNULL(n.Sold,0), ISNULL(n.Sales,0), ISNULL(n.COGS,0),
         ISNULL(n.Profit,0), NULL, ISNULL(n.Mkdn2,0), ISNULL(n.Mrg,0)
  FROM #ArtSucCat sc 
  LEFT JOIN #VentaTotal n on ISNULL(sc.Categoria,'')=ISNULL(n.Categoria,'') AND ISNULL(sc.Grupo,'')=ISNULL(n.Grupo,'') AND ISNULL(sc.SubLinea,'')=ISNULL(n.SubLinea,'') AND sc.Sucursal=n.Sucursal
  ORDER BY Sucursal  

  SELECT @Promedio=CAST((SUM(Mrg)/COUNT(*)) AS DECIMAL(10,2)) FROM @RPTACC 

  UPDATE a SET a.OH=ISNULL(d.Disponible,0), a.OO=0.0, a.NombreSucursal=CAST(a.ClaveSucursal AS varchar(5))+' - '+'TDA', a.NombreGrupo=a.Grupo+' - '+'Genero',
               a.PromedioWFG=@Promedio
  FROM @RPTACC a
  LEFT JOIN #Disponible d on a.ClaveSucursal=d.Sucursal AND ISNULL(a.Grupo,'')=ISNULL(d.Grupo,'') AND ISNULL(a.Categoria,'')=ISNULL(d.Categoria,'') AND ISNULL(a.SubLinea,'')=ISNULL(d.SubLinea,'')

 SELECT * FROM @RPTACC ORDER BY ClaveSucursal


END
GO
--exec spWFGRPTACC '20180101', '20180331', 'ACCESORIOS'

/**************** spWFGRPTBL ****************/
IF EXISTS (select * from sysobjects where id = object_id('dbo.spWFGRPTBL') and type = 'P') drop procedure dbo.spWFGRPTBL
GO
CREATE PROCEDURE spWFGRPTBL
@FechaD    datetime,
@FechaA    datetime,
@Categoria varchar(50)
AS BEGIN
  DECLARE @Promedio float

  DECLARE @RPTBL TABLE (ClaveSucursal int NULL, NombreSucursal varchar(20) NULL, Grupo varchar(50) NULL, NombreGrupo varchar(20) NULL, Categoria varchar(50) NULL, Material varchar(50) NULL, OH float NULL, OO float NULL, Sold float NULL, Sales float NULL, COGS float NULL,
                         Profit float NULL,	Mkdn1 float NULL, Mkdn2 float NULL,	Mrg float NULL, PromedioWFG float NULL)
  CREATE TABLE #PorcMax    (Cuenta varchar(20) NULL, PorcMax float NULL)
  CREATE TABLE #Material   (Cuenta varchar(20) NULL, Material varchar(50) NULL, Grupo varchar(50) NULL, Categoria varchar(50) NULL)
  CREATE TABLE #ArtSucMat  (Sucursal int NULL,    Articulo varchar(20) NULL,  Grupo     varchar(50) NULL, Categoria varchar(50) NULL,  Material   varchar(50) NULL)


  CREATE TABLE #Disponible (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, Material varchar(50)  NULL,  Disponible float NULL)
  CREATE TABLE #Ventas     (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, Material varchar(50)  NULL,  Sold       float NULL, Sales float NULL, COGS float NULL,
                            Profit   float NULL,  Mkdn1    float       NULL,  Mkdn2     float       NULL, Mrg      float        NULL)
  CREATE TABLE #VentaTotal (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, Material varchar(50)  NULL,  Sold       float NULL, Sales float NULL, COGS float NULL,
                            Profit   float NULL,  Mkdn1    float       NULL,  Mkdn2     float       NULL, Mrg      float        NULL)
  
  /**************** OBTENER PORCENTAJE MAYOR DE MATERIAL POR ARTICULO ***************/ 
  INSERT INTO #PorcMax (Cuenta, PorcMax)
                  SELECT p.Cuenta, MAX(CAST(REPLACE(Propiedad,'%','') AS float))
                  FROM Prop p
				  JOIN Art a on p.Cuenta=a.Articulo
				  WHERE a.Categoria=@Categoria AND a.Estatus='ALTA'
                  GROUP BY p.Cuenta
                 --SELECT * FROM #PorcMax

  /************* OBTENER MATERIAL CON PORCENTAJE MAYOR POR ARTICULO ***************/
  INSERT INTO #Material (Cuenta,   Material, Grupo,   Categoria)
                  SELECT p.Cuenta, p.Tipo,   a.Grupo, a.Categoria
                  FROM Prop p
                  JOIN #PorcMax m on p.Cuenta=m.Cuenta AND CAST(REPLACE(p.Propiedad,'%','') AS float)=m.PorcMax
				  JOIN Art a on p.Cuenta=a.Articulo
				  WHERE a.Categoria=@Categoria AND a.Estatus='ALTA'
                  --select * from #Material

  /************** CONJUNTO DE DATOS *****************/
  INSERT INTO #ArtSucMat (Sucursal,   Articulo,   Grupo,   Categoria,   Material )
                   SELECT s.Sucursal, a.Cuenta,   a.Grupo, a.Categoria, a.Material
                   FROM Sucursal s
                   CROSS JOIN #Material a
				   WHERE s.Estatus='ALTA'
				   --select * from #ArtSucMat
				  
  /************** DISPONIBLE DEL CONJUNTO DE DATOS *****************/
  INSERT INTO #Disponible (Sucursal,   Grupo,   Categoria,   Material,   Disponible)
                    SELECT s.Sucursal, s.Grupo, s.Categoria, s.Material, SUM((ISNULL(su2.SaldoU,0)-ISNULL(su3.SaldoU,0))-ISNULL(su.SaldoU,0)) Disponible
                    FROM #ArtSucMat s
                    LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, m.Material, SUM(SaldoU) SaldoU
                               FROM SaldoU su  
                               JOIN Art a ON su.Cuenta=a.Articulo
							   JOIN #Material m on a.Articulo=m.Cuenta
			                   WHERE su.Rama='RESV' AND a.Categoria=@Categoria
			                   GROUP BY su.Sucursal, su.Cuenta, a.Grupo, m.Material)su ON s.Sucursal=su.Sucursal AND s.Articulo=su.Cuenta  
                    LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, m.Material, SUM(SaldoU) SaldoU
                               FROM SaldoU su  
                               JOIN Art a ON su.Cuenta=a.Articulo
					           JOIN #Material m on a.Articulo=m.Cuenta
			                   WHERE su.Rama='INV' AND a.Categoria=@Categoria
			                   GROUP BY su.Sucursal, su.Cuenta, a.Grupo, m.Material)su2 ON s.Sucursal=su2.Sucursal AND s.Articulo=su2.Cuenta		
                    LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, m.Material, SUM(SaldoU) SaldoU
                               FROM SaldoU su  
                               JOIN Art a ON su.Cuenta=a.Articulo
					           JOIN #Material m on a.Articulo=m.Cuenta
			                   WHERE su.Rama='VMOS' AND a.Categoria=@Categoria
			                   GROUP BY su.Sucursal, su.Cuenta, a.Grupo, m.Material)su3 ON s.Sucursal=su3.Sucursal AND s.Articulo=su3.Cuenta	 			  
                    GROUP BY s.Sucursal, s.Grupo, s.Categoria, s.Material

   INSERT INTO #Ventas (Sucursal,   Grupo,   Categoria,   Material,    Sold,                              Sales,                      COGS, 
                        Profit,                           Mkdn1,       Mkdn2,                             Mrg)
                 SELECT v.Sucursal, a.Grupo, a.Categoria, m.Material,  SUM((ISNULL(vd.Cantidad,0))) Sold, SUM(Cantidad*Precio) Sales, SUM(Costo) COGS, 
                       SUM(Cantidad*Precio)- SUM(Costo) Profit, null,  SUM(DescuentoImporte) Mkdns2,      (SUM(Cantidad*Precio)- SUM(Costo)/SUM(Cantidad*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on vd.ID=v.ID
                 JOIN Art a on vd.Articulo=a.Articulo
				 JOIN #Material m on a.Articulo=m.Cuenta
                 WHERE v.Mov='Nota' 
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus IN ('CONCLUIDO','PROCESAR')
                 AND a.Categoria=@Categoria
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, m.Material
				 UNION
                 SELECT v.Sucursal, a.Grupo, a.Categoria, m.Material, SUM((ISNULL(vd.Cantidad,0))) Sold, SUM(Cantidad*Precio) Sales, SUM(Costo) COGS, 
                       SUM(Cantidad*Precio)- SUM(Costo) Profit, null,       SUM(DescuentoImporte) Mkdns2,      (SUM(Cantidad*Precio)- SUM(Costo)/SUM(Cantidad*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on v.ID=vd.ID
                 JOIN Art a on vd.Articulo=a.Articulo 
				 JOIN #Material m on a.Articulo=m.Cuenta
                 WHERE Mov='Factura Credito'
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus='CONCLUIDO'
                 AND a.Categoria=@Categoria
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, m.Material
				 UNION
                 SELECT v.Sucursal, a.Grupo, a.Categoria, m.Material, SUM((ISNULL(vd.CantidadReservada,0))) Sold, SUM(CantidadReservada*Precio) Sales, SUM(Costo) COGS, 
                       SUM(CantidadReservada*Precio)- SUM(Costo) Profit, null,  SUM(DescuentoImporte) Mkdns2,      (SUM(CantidadReservada*Precio)- SUM(Costo)/SUM(CantidadReservada*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on v.ID=vd.ID
                 JOIN Art a on vd.Articulo=a.Articulo
				 JOIN #Material m on a.Articulo=m.Cuenta
                 WHERE Mov='Pedido'
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus='PENDIENTE'
                 AND a.Categoria=@Categoria
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, m.Material

   INSERT INTO #VentaTotal (Sucursal,     Grupo,   Categoria,   Material,         Sold,         Sales,        COGS, 
                            Profit,       Mkdn1,   Mkdn2,       Mrg)
					SELECT  Sucursal,     Grupo,   Categoria,   Material,         SUM(Sold),    SUM(Sales),   SUM(COGS),
					        SUM(Profit),  NULL,    SUM(Mkdn2),  SUM(Mrg)
					FROM #Ventas v
					GROUP BY v.Sucursal, v.Grupo, v.Categoria, v.Material

  INSERT INTO @RPTBL (ClaveSucursal,           Grupo,    Categoria,         Material,       Sold,             Sales,             COGS, 
                      Profit,             Mkdn1,    Mkdn2,             Mrg)
      SELECT DISTINCT sc.Sucursal,        sc.Grupo, sc.Categoria,      sc.Material,    ISNULL(n.Sold,0), ISNULL(n.Sales,0), ISNULL(n.COGS,0),
                      ISNULL(n.Profit,0), NULL,     ISNULL(n.Mkdn2,0), ISNULL(n.Mrg,0)
      FROM #ArtSucMat sc 
      LEFT JOIN #VentaTotal n on ISNULL(sc.Categoria,'')=ISNULL(n.Categoria,'') AND ISNULL(sc.Grupo,'')=ISNULL(n.Grupo,'') AND ISNULL(sc.Material,'')=ISNULL(n.Material,'') AND sc.Sucursal=n.Sucursal
      ORDER BY Sucursal  

  SELECT @Promedio=CAST((SUM(Mrg)/COUNT(*)) AS DECIMAL(10,2)) FROM @RPTBL


  UPDATE a SET a.OH=ISNULL(d.Disponible,0), a.OO=0.0, a.NombreSucursal=CAST(a.ClaveSucursal AS varchar(5))+' - '+'TDA', a.NombreGrupo=a.Grupo+' - '+'Genero',
               a.PromedioWFG=@Promedio
  FROM @RPTBL a
  LEFT JOIN #Disponible d on a.ClaveSucursal=d.Sucursal AND ISNULL(a.Grupo,'')=ISNULL(d.Grupo,'') AND ISNULL(a.Categoria,'')=ISNULL(d.Categoria,'') AND ISNULL(a.Material,'')=ISNULL(d.Material,'')

 SELECT * FROM @RPTBL ORDER BY ClaveSucursal


END
GO
--exec spWFGRPTBL '20180101', '20180331', 'BLUSA'


/**************** spWFGRPTNP ****************/
IF EXISTS (select * from sysobjects where id = object_id('dbo.spWFGRPTNP') and type = 'P') drop procedure dbo.spWFGRPTNP
GO
CREATE PROCEDURE spWFGRPTNP
@FechaD    datetime,
@FechaA    datetime,
@Categoria varchar(50)
AS BEGIN
  DECLARE @Promedio float

  DECLARE @RPTNP TABLE (ClaveSucursal int NULL, NombreSucursal varchar(20) NULL, Grupo varchar(50) NULL, NombreGrupo varchar(20) NULL, Categoria varchar(50) NULL, NivelPrecio float NULL, OH float NULL, OO float NULL, Sold float NULL, Sales float NULL, COGS float NULL,
                         Profit float NULL,	Mkdn1 float NULL, Mkdn2 float NULL,	Mrg float NULL, PromedioWFG float NULL)
  CREATE TABLE #ArtSucNP  (Sucursal int NULL,    Articulo varchar(20) NULL,  Grupo     varchar(50) NULL,  Categoria varchar(50) NULL,  NivelPrecio float NULL)
  CREATE TABLE #Disponible (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, NivelPrecio float  NULL,  Disponible float NULL)
  CREATE TABLE #Ventas     (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, NivelPrecio float  NULL,  Sold       float NULL, Sales float NULL, COGS float NULL,
                            Profit   float NULL,  Mkdn1    float       NULL,  Mkdn2     float       NULL, Mrg      float        NULL)
  CREATE TABLE #VentaTotal (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, NivelPrecio float  NULL,  Sold       float NULL, Sales float NULL, COGS float NULL,
                            Profit   float NULL,  Mkdn1    float       NULL,  Mkdn2     float       NULL, Mrg      float        NULL)
  

  /************** CONJUNTO DE DATOS *****************/
  INSERT INTO #ArtSucNP (Sucursal,    Articulo,    Grupo,   Categoria,   NivelPrecio )
                   SELECT s.Sucursal, a.Articulo,  a.Grupo, a.Categoria, a.WFGArtNivelPrecio
                   FROM Sucursal s
                   CROSS JOIN Art a
				   WHERE a.Estatus='ALTA' AND s.Estatus='ALTA'
				   AND a.Categoria=@Categoria
				   --select * from #ArtSucNP
				  
  /************** DISPONIBLE DEL CONJUNTO DE DATOS *****************/
  INSERT INTO #Disponible (Sucursal,   Grupo,   Categoria,   NivelPrecio,   Disponible)
                    SELECT s.Sucursal, s.Grupo, s.Categoria, s.NivelPrecio, SUM((ISNULL(su2.SaldoU,0)-ISNULL(su3.SaldoU,0))-ISNULL(su.SaldoU,0)) Disponible
                    FROM #ArtSucNP s
                    LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtNivelPrecio, SUM(SaldoU) SaldoU
                               FROM SaldoU su  
                               JOIN Art a ON su.Cuenta=a.Articulo
							   WHERE su.Rama='RESV' AND a.Categoria=@Categoria
			                   GROUP BY su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtNivelPrecio)su ON s.Sucursal=su.Sucursal AND s.Articulo=su.Cuenta  
                    LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtNivelPrecio, SUM(SaldoU) SaldoU
                               FROM SaldoU su  
                               JOIN Art a ON su.Cuenta=a.Articulo
			                   WHERE su.Rama='INV' AND a.Categoria=@Categoria
			                   GROUP BY su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtNivelPrecio)su2 ON s.Sucursal=su2.Sucursal AND s.Articulo=su2.Cuenta		
                    LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtNivelPrecio, SUM(SaldoU) SaldoU
                               FROM SaldoU su  
                               JOIN Art a ON su.Cuenta=a.Articulo
			                   WHERE su.Rama='VMOS' AND a.Categoria=@Categoria
			                   GROUP BY su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtNivelPrecio)su3 ON s.Sucursal=su3.Sucursal AND s.Articulo=su3.Cuenta	 			  
                    GROUP BY s.Sucursal, s.Grupo, s.Categoria, s.NivelPrecio


   INSERT INTO #Ventas (Sucursal,   Grupo,   Categoria,   NivelPrecio,          Sold,                              Sales,                      COGS, 
                        Profit,                           Mkdn1,                Mkdn2,                             Mrg)
                 SELECT v.Sucursal, a.Grupo, a.Categoria, a.WFGArtNivelPrecio,  SUM((ISNULL(vd.Cantidad,0))) Sold, SUM(Cantidad*Precio) Sales, SUM(Costo) COGS, 
                       SUM(Cantidad*Precio)- SUM(Costo) Profit, null,  SUM(DescuentoImporte) Mkdns2,      (SUM(Cantidad*Precio)- SUM(Costo)/SUM(Cantidad*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on vd.ID=v.ID
                 JOIN Art a on vd.Articulo=a.Articulo
                 WHERE v.Mov='Nota' 
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus IN ('CONCLUIDO','PROCESAR')
                 AND a.Categoria=@Categoria
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, a.WFGArtNivelPrecio
				 UNION
                 SELECT v.Sucursal, a.Grupo, a.Categoria, a.WFGArtNivelPrecio, SUM((ISNULL(vd.Cantidad,0))) Sold, SUM(Cantidad*Precio) Sales, SUM(Costo) COGS, 
                       SUM(Cantidad*Precio)- SUM(Costo) Profit, null,       SUM(DescuentoImporte) Mkdns2,      (SUM(Cantidad*Precio)- SUM(Costo)/SUM(Cantidad*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on v.ID=vd.ID
                 JOIN Art a on vd.Articulo=a.Articulo 
                 WHERE Mov='Factura Credito'
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus='CONCLUIDO'
                 AND a.Categoria=@Categoria
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, a.WFGArtNivelPrecio
				 UNION
                 SELECT v.Sucursal, a.Grupo, a.Categoria, a.WFGArtNivelPrecio, SUM((ISNULL(vd.CantidadReservada,0))) Sold, SUM(CantidadReservada*Precio) Sales, SUM(Costo) COGS, 
                       SUM(CantidadReservada*Precio)- SUM(Costo) Profit, null,  SUM(DescuentoImporte) Mkdns2,      (SUM(CantidadReservada*Precio)- SUM(Costo)/SUM(CantidadReservada*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on v.ID=vd.ID
                 JOIN Art a on vd.Articulo=a.Articulo
                 WHERE Mov='Pedido'
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus='PENDIENTE'
                 AND a.Categoria=@Categoria
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, a.WFGArtNivelPrecio

   INSERT INTO #VentaTotal (Sucursal,     Grupo,   Categoria,   NivelPrecio,         Sold,         Sales,        COGS, 
                            Profit,       Mkdn1,   Mkdn2,       Mrg)
					SELECT  Sucursal,     Grupo,   Categoria,   NivelPrecio,         SUM(Sold),    SUM(Sales),   SUM(COGS),
					        SUM(Profit),  NULL,    SUM(Mkdn2),  SUM(Mrg)
					FROM #Ventas v
					GROUP BY v.Sucursal, v.Grupo, v.Categoria, v.NivelPrecio

  INSERT INTO @RPTNP (ClaveSucursal,           Grupo,    Categoria,         NivelPrecio,       Sold,             Sales,             COGS, 
                      Profit,             Mkdn1,    Mkdn2,             Mrg)
      SELECT DISTINCT sc.Sucursal,        sc.Grupo, sc.Categoria,      sc.NivelPrecio,    ISNULL(n.Sold,0), ISNULL(n.Sales,0), ISNULL(n.COGS,0),
                      ISNULL(n.Profit,0), NULL,     ISNULL(n.Mkdn2,0), ISNULL(n.Mrg,0)
      FROM #ArtSucNP sc 
      LEFT JOIN #VentaTotal n on ISNULL(sc.Categoria,'')=ISNULL(n.Categoria,'') AND ISNULL(sc.Grupo,'')=ISNULL(n.Grupo,'') AND ISNULL(sc.NivelPrecio,'')=ISNULL(n.NivelPrecio,'') AND sc.Sucursal=n.Sucursal
      ORDER BY Sucursal  

  SELECT @Promedio=CAST((SUM(Mrg)/COUNT(*)) AS DECIMAL(10,2)) FROM @RPTNP

  UPDATE a SET a.OH=ISNULL(d.Disponible,0), a.OO=0.0, a.NombreSucursal=CAST(a.ClaveSucursal AS varchar(5))+' - '+'TDA', a.NombreGrupo=a.Grupo+' - '+'Genero',
               a.PromedioWFG=@Promedio
  FROM @RPTNP a
  LEFT JOIN #Disponible d on a.ClaveSucursal=d.Sucursal AND ISNULL(a.Grupo,'')=ISNULL(d.Grupo,'') AND ISNULL(a.Categoria,'')=ISNULL(d.Categoria,'') AND ISNULL(a.NivelPrecio,'')=ISNULL(d.NivelPrecio,'')

 SELECT * FROM @RPTNP ORDER BY ClaveSucursal


END
GO
--exec spWFGRPTNP '20180101', '20180331', 'BLUSA'

/**************** spWFGRPTVentas ****************/
IF EXISTS (select * from sysobjects where id = object_id('dbo.spWFGRPTVentas') and type = 'P') drop procedure dbo.spWFGRPTVentas
GO
CREATE PROCEDURE spWFGRPTVentas
@FechaD    datetime,
@FechaA    datetime
AS BEGIN
  DECLARE @Promedio float

  DECLARE @RPTVentas TABLE (ClaveSucursal int NULL, NombreSucursal varchar(20) NULL, Grupo varchar(50) NULL, NombreGrupo varchar(20) NULL, Categoria varchar(50) NULL, SubLinea varchar(50) NULL, OH float NULL, OO float NULL, Sold float NULL, Sales float NULL, COGS float NULL,
                         Profit float NULL,	Mkdn1 float NULL, Mkdn2 float NULL,	Mrg float NULL, PromedioWFG float NULL)

  CREATE TABLE #ArtSucCat  (Sucursal int NULL,    Articulo varchar(20) NULL,  Grupo     varchar(50) NULL, Categoria varchar(50) NULL,  SubLinea   varchar(50) NULL)
  CREATE TABLE #Disponible (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, SubLinea varchar(50)  NULL,  Disponible float NULL)
  CREATE TABLE #Ventas     (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, SubLinea varchar(50)  NULL,  Sold       float NULL, Sales float NULL, COGS float NULL,
                            Profit   float NULL,  Mkdn1    float       NULL,  Mkdn2     float       NULL, Mrg      float        NULL)
  CREATE TABLE #VentaTotal (Sucursal int NULL,    Grupo    varchar(50) NULL,  Categoria varchar(50) NULL, SubLinea varchar(50)  NULL,  Sold       float NULL, Sales float NULL, COGS float NULL,
                            Profit   float NULL,  Mkdn1    float       NULL,  Mkdn2     float       NULL, Mrg      float        NULL)

  INSERT INTO #ArtSucCat (Sucursal,   Articulo,   Grupo,   Categoria,   SubLinea )
                   SELECT s.Sucursal, a.Articulo, a.Grupo, a.Categoria, a.WFGArtSubLinea
                   FROM Sucursal s
                   CROSS JOIN Art a	 
				   WHERE /*a.Categoria=@Categoria AND*/ a.Estatus='ALTA' AND s.Estatus='ALTA'
  --select * from #ArtSucCat order by Sucursal  

  INSERT INTO #Disponible (Sucursal, Grupo, Categoria, SubLinea, Disponible)
  SELECT s.Sucursal, s.Grupo, s.Categoria, s.SubLinea, SUM((ISNULL(su2.SaldoU,0)-ISNULL(su3.SaldoU,0))-ISNULL(su.SaldoU,0)) Disponible
  FROM #ArtSucCat s
  LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea, SUM(SaldoU) SaldoU
             FROM SaldoU su  
             JOIN Art a ON su.Cuenta=a.Articulo
			 WHERE su.Rama='RESV' --AND a.Categoria=@Categoria
			 GROUP BY su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea)su ON s.Sucursal=su.Sucursal AND s.Articulo=su.Cuenta  
  LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea, SUM(SaldoU) SaldoU
             FROM SaldoU su  
             JOIN Art a ON su.Cuenta=a.Articulo
			 WHERE su.Rama='INV' --AND a.Categoria=@Categoria
			 GROUP BY su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea)su2 ON s.Sucursal=su2.Sucursal AND s.Articulo=su2.Cuenta		
  LEFT JOIN (SELECT su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea, SUM(SaldoU) SaldoU
             FROM SaldoU su  
             JOIN Art a ON su.Cuenta=a.Articulo
			 WHERE su.Rama='VMOS' --AND a.Categoria=@Categoria
			 GROUP BY su.Sucursal, su.Cuenta, a.Grupo, a.WFGArtSubLinea)su3 ON s.Sucursal=su3.Sucursal AND s.Articulo=su3.Cuenta	 			  
   GROUP BY s.Sucursal, s.Grupo, s.Categoria, s.SubLinea

   INSERT INTO #Ventas (Sucursal,   Grupo,   Categoria,   SubLinea,         Sold,                              Sales,                      COGS, 
                        Profit,                                Mkdn1,       Mkdn2,                             Mrg)
                 SELECT v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea, SUM((ISNULL(vd.Cantidad,0))) Sold, SUM(Cantidad*Precio) Sales, SUM(Costo) COGS, 
                       SUM(Cantidad*Precio)- SUM(Costo) Profit, null,       SUM(DescuentoImporte) Mkdns2,      (SUM(Cantidad*Precio)- SUM(Costo)/SUM(Cantidad*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on vd.ID=v.ID
                 JOIN Art a on vd.Articulo=a.Articulo
                 WHERE v.Mov='Nota' 
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus IN ('CONCLUIDO','PROCESAR')
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea
				 UNION
                 SELECT v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea, SUM((ISNULL(vd.Cantidad,0))) Sold, SUM(Cantidad*Precio) Sales, SUM(Costo) COGS, 
                       SUM(Cantidad*Precio)- SUM(Costo) Profit, null,       SUM(DescuentoImporte) Mkdns2,      (SUM(Cantidad*Precio)- SUM(Costo)/SUM(Cantidad*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on v.ID=vd.ID
                 JOIN Art a on vd.Articulo=a.Articulo 
                 WHERE Mov='Factura Credito'
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus='CONCLUIDO'
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea
				 UNION
                 SELECT v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea, SUM((ISNULL(vd.CantidadReservada,0))) Sold, SUM(CantidadReservada*Precio) Sales, SUM(Costo) COGS, 
                       SUM(CantidadReservada*Precio)- SUM(Costo) Profit, null,  SUM(DescuentoImporte) Mkdns2,      (SUM(CantidadReservada*Precio)- SUM(Costo)/SUM(CantidadReservada*Precio))/100
                 FROM Venta v
                 JOIN VentaD vd on v.ID=vd.ID
                 JOIN Art a on vd.Articulo=a.Articulo
                 WHERE Mov='Pedido'
                 AND v.FechaEmision BETWEEN @FechaD AND @FechaA
                 AND v.Estatus='PENDIENTE'
                 GROUP BY v.Sucursal, a.Grupo, a.Categoria, a.WFGArtSubLinea

   INSERT INTO #VentaTotal (Sucursal,     Grupo,   Categoria,   SubLinea,         Sold,         Sales,        COGS, 
                            Profit,       Mkdn1,   Mkdn2,       Mrg)
					SELECT  Sucursal,     Grupo,   Categoria,   SubLinea,         SUM(Sold),    SUM(Sales),   SUM(COGS),
					        SUM(Profit),  NULL,    SUM(Mkdn2),  SUM(Mrg)
					FROM #Ventas v
					GROUP BY v.Sucursal, v.Grupo, v.Categoria, v.SubLinea

  INSERT INTO @RPTVentas (ClaveSucursal, Grupo, Categoria, SubLinea, Sold, Sales, COGS, Profit, Mkdn1, Mkdn2, Mrg)
  SELECT DISTINCT sc.Sucursal, sc.Grupo, sc.Categoria, sc.SubLinea, ISNULL(n.Sold,0), ISNULL(n.Sales,0), ISNULL(n.COGS,0),
         ISNULL(n.Profit,0), NULL, ISNULL(n.Mkdn2,0), ISNULL(n.Mrg,0)
  FROM #ArtSucCat sc 
  LEFT JOIN #VentaTotal n on ISNULL(sc.Categoria,'')=ISNULL(n.Categoria,'') AND ISNULL(sc.Grupo,'')=ISNULL(n.Grupo,'') AND ISNULL(sc.SubLinea,'')=ISNULL(n.SubLinea,'') AND sc.Sucursal=n.Sucursal
  ORDER BY Sucursal  

  SELECT @Promedio=CAST((SUM(Mrg)/COUNT(*)) AS DECIMAL(10,2)) FROM @RPTVentas 

  UPDATE a SET a.OH=ISNULL(d.Disponible,0), a.OO=0.0, a.NombreSucursal=CAST(a.ClaveSucursal AS varchar(5))+' - '+'TDA', a.NombreGrupo=a.Grupo+' - '+'Genero',
               a.PromedioWFG=@Promedio
  FROM @RPTVentas a
  LEFT JOIN #Disponible d on a.ClaveSucursal=d.Sucursal AND ISNULL(a.Grupo,'')=ISNULL(d.Grupo,'') AND ISNULL(a.Categoria,'')=ISNULL(d.Categoria,'') AND ISNULL(a.SubLinea,'')=ISNULL(d.SubLinea,'')

 SELECT * FROM @RPTVentas ORDER BY ClaveSucursal, Grupo


END
GO
--exec spWFGRPTVentas '20180101', '20180331'