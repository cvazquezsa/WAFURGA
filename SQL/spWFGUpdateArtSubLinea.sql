SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
SET NOCOUNT ON
SET ANSI_WARNINGS OFF


/**************** spWFGUpdateArtSubLinea ****************/
IF EXISTS (select * from sysobjects where id = object_id('dbo.spWFGUpdateArtSubLinea') and type = 'P') drop procedure dbo.spWFGUpdateArtSubLinea
GO
CREATE PROCEDURE spWFGUpdateArtSubLinea
@ID int

AS BEGIN
   DECLARE @Articulo  varchar(20),
           @Categoria varchar(50),
		   @Renglon   float,
		   @SubLinea  varchar(50)

   SELECT @Categoria='ACCESORIOS' 


   DECLARE crArtSubLinea CURSOR FAST_FORWARD FOR
     SELECT cd.Articulo, cd.Renglon
     FROM Compra c
     JOIN CompraD cd on c.ID=cd.ID
	 JOIN Art a on cd.Articulo=a.Articulo
     WHERE c.ID=@ID AND a.WfgArtForma=@Categoria
   OPEN crArtSubLinea
   FETCH NEXT FROM crArtSubLinea INTO @Articulo, @Renglon
   WHILE @@FETCH_STATUS = 0 
   BEGIN
     SELECT @SubLinea=NULL
	 SELECT @SubLinea=WFGArtSubLinea FROM Art WHERE Articulo=@Articulo

	 IF ISNULL(@SubLinea,'') <> ''
	 UPDATE CompraD SET Articulo=@SubLinea WHERE ID=@ID AND Renglon=@Renglon

   FETCH NEXT FROM crArtSubLinea INTO @Articulo, @Renglon
   END    
   CLOSE crArtSubLinea
   DEALLOCATE crArtSubLinea 

END
GO
