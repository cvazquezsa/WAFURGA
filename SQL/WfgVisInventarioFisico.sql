IF EXISTS (SELECT * FROM SysObjects WHERE Name='WfgVisInventarioFisico' AND Type='V') DROP VIEW WfgVisInventarioFisico
GO
CREATE VIEW WfgVisInventarioFisico
AS
SELECT i.ID,i.Empresa,e.Nombre AS 'EmpresaNombre',id.Articulo,Art.Categoria,Art.Fabricante,art.Descripcion1,id.Renglon,id.RenglonID, id.SubCuenta,a.Almacen, 
	a.Nombre AS 'AlmacenNombre', 
	a.Sucursal,s.Nombre AS 'SucursalNombre', ISNULL(wi.Cantidad,0) AS 'CantidadCapturada',ISNULL(su.SaldoU,0) AS 'CantidadReservada', 
	ISNULL(id.Cantidad,0) AS 'CantidadTotal', (ISNULL(su2.SaldoU,0)-ISNULL(su3.SaldoU,0))-ISNULL(su.SaldoU,0) AS 'Existencias',
	ISNULL(wi.Cantidad,0)-ISNULL(su2.SaldoU,0) AS 'Diferencias',ac.CostoPromedio, ac.CostoPromedio*id.Cantidad AS 'CostoTotal'--,id2.CostoTotalInv,
	--id3.CostoTotalDiferencias*ac.CostoPromedio AS 'CostoTotalDiferencias'  
	FROM Inv i 
		JOIN InvD id ON i.ID=id.ID
		JOIN Alm a ON i.Almacen=a.Almacen
		LEFT JOIN SaldoU su ON i.Empresa=su.Empresa AND a.Sucursal=su.Sucursal AND su.Rama='RESV' AND a.Almacen=su.Grupo AND id.Articulo=su.Cuenta
			AND ISNULL(id.SubCuenta,'')=ISNULL(su.SubCuenta,'')
		LEFT JOIN WfgInventario wi ON i.ID=wi.ID AND id.Renglon=wi.Renglon AND id.RenglonID=wi.RenglonID AND id.Articulo=wi.Articulo 
			--AND id.SubCuenta=wi.SubCuenta
		JOIN Art ON art.Articulo=id.Articulo
		JOIN Sucursal s ON s.Sucursal=a.Sucursal
		JOIN Empresa e ON e.Empresa=i.Empresa
		JOIN MovTipo mt ON i.Mov=mt.Mov AND mt.Clave='INV.IF' AND mt.SubClave='INV.IF.W'
		LEFT JOIN SaldoU su2 ON i.Empresa=su2.Empresa AND a.Sucursal=su2.Sucursal AND su2.Rama='INV' AND a.Almacen=su2.Grupo AND id.Articulo=su2.Cuenta
			AND ISNULL(id.SubCuenta,'')=ISNULL(su2.SubCuenta,'')
		LEFT JOIN SaldoU su3 ON i.Empresa=su3.Empresa AND a.Sucursal=su3.Sucursal AND su3.Rama='VMOS' AND a.Almacen=su3.Grupo AND id.Articulo=su3.Cuenta
			AND ISNULL(id.SubCuenta,'')=ISNULL(su3.SubCuenta,'')
		JOIN ArtCosto ac ON a.Sucursal=ac.Sucursal AND i.Empresa=ac.Empresa AND id.Articulo=ac.Articulo
		--JOIN (SELECT ID,SUM(Costo*Cantidad) AS CostoTotalInv FROM InvD GROUP BY ID) id2 ON id.ID=id2.ID
		--JOIN (SELECT Inv.ID,SUM((WfgInventario.Cantidad-SaldoU.SaldoU)) AS CostoTotalDiferencias FROM Inv 
		--		JOIN InvD ON Inv.ID=InvD.ID JOIN Alm ON Inv.Almacen=Alm.Almacen
		--		JOIN WfgInventario ON Inv.ID=WfgInventario.ID AND InvD.Renglon=WfgInventario.Renglon AND InvD.RenglonID=WfgInventario.RenglonID
		--			AND InvD.Articulo=WfgInventario.Articulo AND InvD.SubCuenta=WfgInventario.SubCuenta 
		--		JOIN SaldoU ON Inv.Empresa=SaldoU.Empresa AND Alm.Sucursal=SaldoU.Sucursal AND SaldoU.Rama='INV' 
		--			AND Alm.Almacen=SaldoU.Grupo AND InvD.Articulo=SaldoU.Cuenta AND InvD.SubCuenta=SaldoU.SubCuenta
		--		GROUP BY Inv.ID) AS id3 ON i.ID=id3.ID
			
GO
--SELECT * FROM WfgVisInventarioFisico

IF EXISTS (SELECT * FROM sysObjects WHERE Type='P' AND name='spWFGRepInventarioFisico')
	DROP PROCEDURE spWFGRepInventarioFisico
GO
CREATE PROCEDURE spWFGRepInventarioFisico
	@ID	int,
	@Articulo	varchar(20)='',
	@Categoria	varchar(50)='',
	@Descripcion	varchar(255)='',
	@Proveedor	varchar(50)=''
AS
BEGIN
	DECLARE
		@cmd	nvarchar(max),
		@cmdArt	nvarchar(max),
		@cmdCat	nvarchar(max),
		@cmdDesc	nvarchar(max),
		@cmdProv	nvarchar(max)

	IF NOT ISNULL(@Articulo,'')=''
		SELECT @cmdArt=CONCAT(' AND Articulo=''',@Articulo,'''')
	IF NOT ISNULL(@Categoria,'')=''
		SELECT @cmdCat=CONCAT(' AND Categoria=''',@Categoria,'''')
	IF NOT ISNULL(@Proveedor,'')=''
		SELECT @cmdProv=CONCAT(' AND Fabricante=''',@Proveedor,'''')
	IF NOT ISNULL(@Descripcion,'')=''
		SELECT @cmdDesc=CONCAT(' AND Descripcion1 LIKE ''%',@Descripcion,'%''')
	SELECT  @cmd=CONCAT('SELECT * FROM WfgVisInventarioFisico WHERE ID=',@ID,@cmdArt,@cmdCat,@cmdDesc,@cmdProv)
	
	EXEC(@cmd)

RETURN
END
GO

 --EXEC spWFGRepInventarioFisico 17470,'10272MIC'         