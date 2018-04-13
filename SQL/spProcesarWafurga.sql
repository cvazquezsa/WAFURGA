/**************** spProcesarWafurga ****************/
if exists (select * from sysobjects where id = object_id('dbo.spProcesarWafurga') and type = 'P') drop procedure dbo.spProcesarWafurga
GO             
CREATE PROCEDURE spProcesarWafurga
            @Estacion		int,
		    @Empresa		char(5),		   
			@Modulo  		char(20),
		    @FechaEmision	datetime,
		    @Usuario		char(10),		    
		    @Sucursal           int             = NULL

--//WITH ENCRYPTION
AS BEGIN
  -- SET nocount ON
  DECLARE
    @FacturaGlobalPeriodo money,
    @CfgArtInteresMora    varchar(20),
    @cfgMovVTASFatGlobal  varchar(20),
    @cgfMovCXCFatGlobal   varchar(20),
	@NotaID               int,
	@GenerarProcesar      int,
	@FacturaFechaEmision  datetime,
	@FacturaID            int,
	@Renglon              float,
	@Moneda               varchar(40),
	@RenglonID            float,
	@TipoCambio           money,
	@Almacen              varchar(40),
	@Precio               money,
	@Costo                money,
	@Proveedor            varchar(40),
	@AlmacenEncabezado    varchar(40),
	@Cliente              varchar(40),
	@EnviarA              int,
	@Articulo             varchar(40),
	@RenglonTipo          varchar(40),
	@Condicion            varchar(50),
	@DescuentoGlobal      float,
	@Concepto             varchar(40),
	@SubCuenta            varchar(40),
	@VentaEstatus         varchar(40),
	@Unidad               varchar(40),
	@Agente               varchar(40),
	@Impuesto1            money,
	@UEN                  varchar(40),
	@ZonaImpuesto         varchar(10),
	@Cantidad             float,
	@Impuesto2            money,
	@PrecioNeto           money,
	@InteresesMoratorios  money, 
	@InteresesMoratoriosIVA  money, 
	@InteresesOrdinarios     money, 
	@InteresesOrdinariosIVA  money,
	@Mov                  varchar(20),
	@MovID                varchar(20)
	 

  SET @FacturaGlobalPeriodo=0 
  IF NOT EXISTS(SELECT * FROM ListaID WHERE Estacion = @Estacion) OR (@Modulo not in ('VTAS','CXC'))
  BEGIN
    SELECT NULL
    RETURN
  END


   SELECT @CfgArtInteresMora = ArtInteresMora,
         @cfgMovVTASFatGlobal            = NULLIF(RTRIM(MovVTASFatGlobal), ''),
         @cgfMovCXCFatGlobal          = NULLIF(RTRIM(MovCXCFatGlobal), '')         
    FROM EmpresaCfg
   WHERE Empresa = @Empresa
   
   SELECT @GenerarProcesar = 0 

  IF @Modulo = 'VTAS'
  BEGIN
     
	
    SELECT top 1 @NotaID = v.id, @Sucursal = Sucursal
       FROM Venta v, ListaID l
      WHERE l.Estacion = @Estacion AND v.ID = l.ID
      	  
      IF @GenerarProcesar = 0
      BEGIN

	    SELECT @Moneda = Moneda, @TipoCambio = TipoCambio, @AlmacenEncabezado = Almacen, @Cliente = 'C0000', @EnviarA = 0, @Condicion = Condicion, 
	           @Concepto =Concepto , @Usuario = Usuario, @VentaEstatus = 'SINAFECTAR', @Agente = Agente, @UEN = UEN, @ZonaImpuesto = ZonaImpuesto
	    FROM VENTA WHERE ID = @NotaID


        INSERT Venta (Sucursal,  SucursalOrigen, Empresa,  Mov,         FechaEmision,         Moneda,  TipoCambio,  Almacen,            Cliente,  EnviarA,  Condicion,  Concepto,  Usuario,  Estatus,       OrigenTipo, Agente,  UEN, FormaPagoTipo,ZonaImpuesto, Observaciones )
              VALUES (@Sucursal, @Sucursal,      @Empresa, @cfgMovVTASFatGlobal, @FechaEmision, @Moneda, @TipoCambio, @AlmacenEncabezado, @Cliente, @EnviarA, @Condicion, @Concepto, @Usuario, @VentaEstatus, 'VMOS',     @Agente, @UEN, 'Varios',@ZonaImpuesto,'Herramienta Ventas')
        SELECT @FacturaID = SCOPE_IDENTITY()
        SELECT @GenerarProcesar = 1

      END
  
  IF @GenerarProcesar = 1 AND @FacturaID > 0
  BEGIN
        SELECT @Renglon = 0, @RenglonID = 0
        -- Devoluciones
        DECLARE crNotas CURSOR LOCAL
            FOR SELECT v.Almacen, v.RenglonTipo,v.Articulo, v.Unidad, v.Impuesto1, v.Mov + ' ' + v.MovID, sum(v.Cantidad), sum(PrecioTotal)
                  FROM VentaTCalc v, ListaID l
                 WHERE v.ID = l.ID  --AND v.ESTATUS = 'CONCLUIDO'                   
                   AND l.Estacion = @Estacion
                   AND v.Cantidad > 0.0                  
                 GROUP BY v.Almacen, v.Articulo, v.SubCuenta, v.RenglonTipo, v.Unidad, v.Impuesto1, v.Mov,  v.MovID
                 ORDER BY v.Almacen, v.Articulo, v.SubCuenta, v.RenglonTipo, v.Unidad, v.Impuesto1, v.Mov,  v.MovID
    
        OPEN crNotas
        FETCH NEXT FROM crNotas INTO @Almacen, @RenglonTipo,@Articulo, @Unidad, @Impuesto1, @Mov, @Cantidad, @PrecioNeto
        WHILE @@FETCH_STATUS <> -1 
        BEGIN
          IF @@FETCH_STATUS <> -2 
          BEGIN
		                       
            SELECT @Renglon = @Renglon + 2048, @RenglonID = @RenglonID + 1
            INSERT VentaD (Sucursal,  SucursalOrigen, ID,         Renglon, RenglonSub, RenglonID,  RenglonTipo,  Almacen,  Posicion,  Articulo,  SubCuenta,  Unidad,  Impuesto1,  Impuesto2,  Impuesto3,  Cantidad,  CantidadInventario,  DescuentoTipo,  DescuentoLinea,  Precio,      Costo,  UEN,  Agente, PrecioMoneda, PrecioTipoCambio, CantidadObsequio, OfertaID, PrecioSugerido, DescuentoImporte, Puntos, Comision, DescripcionExtra)
                   VALUES (@Sucursal, @Sucursal,      @FacturaID, @Renglon,         0, @RenglonID, @RenglonTipo, @AlmacenEncabezado, null, @Articulo, NULL, @Unidad, @Impuesto1, @Impuesto2, NULL, @Cantidad, @Cantidad, NULL, NULL, @PrecioNeto, @Costo, @UEN, @Agente, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @Mov)           

				   
          END
          FETCH NEXT FROM crNotas INTO @Almacen, @RenglonTipo,@Articulo, @Unidad, @Impuesto1, @Mov, @Cantidad, @PrecioNeto
        END -- While
        CLOSE crNotas
        DEALLOCATE crNotas
        -- Ventas

 END
END

  IF @Modulo = 'CXC'
  BEGIN

     SELECT @GenerarProcesar = 0
     
    SELECT top 1 @NotaID =  v.id,  @Sucursal = v.Sucursal
     --SELECT DISTINCT FechaEmision, Sucursal
       FROM cxc v, ListaID l
      WHERE l.Estacion = @Estacion AND v.ID = l.ID
     
	 SELECT  @Moneda = Moneda, @TipoCambio = TipoCambio,  @Cliente = 'C0000', @EnviarA = 0, @Condicion = Condicion, 
	           @Concepto =Concepto , @Usuario = Usuario, @VentaEstatus = 'SINAFECTAR', @Agente = Agente, @UEN = UEN
	 FROM CXC WHERE ID = @NotaID
	 
		
      IF @GenerarProcesar = 0
      BEGIN
	    SELECT @FacturaID = 0
        --INSERT CXC (Sucursal,  SucursalOrigen, Empresa,  Mov,         FechaEmision, UltimoCambio,       Moneda,  TipoCambio,   Cliente,  Condicion,  Concepto,  Usuario,  Estatus,     Agente,  UEN, ClienteMoneda, ClienteTipoCambio, Importe, Impuestos, FormaCobro1,AplicaManual, Observaciones)
        --      VALUES (@Sucursal, @Sucursal,      @Empresa, @cgfMovCXCFatGlobal, @FechaEmision,@FechaEmision, @Moneda, @TipoCambio,  @Cliente, @Condicion, @Concepto, @Usuario, @VentaEstatus,     @Agente, @UEN,  @Moneda, @TipoCambio, 0,0,'Efectivo Pesos',1, 'Herramienta CXC')
        --SELECT @FacturaID = SCOPE_IDENTITY()
	   SELECT @AlmacenEncabezado='001'
		 INSERT Venta (Sucursal,  SucursalOrigen, Empresa,  Mov,         FechaEmision,         Moneda,  TipoCambio,  Almacen,            Cliente,  EnviarA,  Condicion,  Concepto,  Usuario,  Estatus,       OrigenTipo, Agente,  UEN, FormaPagoTipo,ZonaImpuesto, Observaciones )
              VALUES (@Sucursal, @Sucursal,      @Empresa, @cfgMovVTASFatGlobal, @FechaEmision, @Moneda, @TipoCambio, @AlmacenEncabezado, @Cliente, @EnviarA, @Condicion, @Concepto, @Usuario, @VentaEstatus, 'VMOS',     @Agente, @UEN, 'Varios',@ZonaImpuesto,'Herramienta Ventas')
        SELECT @FacturaID = SCOPE_IDENTITY()
        SELECT @GenerarProcesar = 1
  

        SELECT @Renglon = 0, @RenglonID = 0
        
	    SELECT @GenerarProcesar = 1
       END
  
  IF @GenerarProcesar = 1 AND @FacturaID > 0
  BEGIN

		-- Devoluciones
        DECLARE crNotas CURSOR LOCAL
            FOR SELECT 'Abono credito' ,null, sum(D.InteresesMoratorios) , sum(d.InteresesMoratoriosIVA) , sum(d.InteresesOrdinarios) , sum(d.InteresesOrdinariosIVA) 
                  FROM CXC v, CxcD d, ListaID l
                 WHERE v.ID = d.ID AND v.ID = l.ID                  
                   --AND v.FechaEmision = @FacturaFechaEmision
                   AND l.Estacion = @Estacion                                     
                 --GROUP BY v.Mov , v.MovID -- InteresesMoratorios) + sum(d.InteresesMoratoriosIVA) + sum(d.InteresesOrdinarios) + sum(d.InteresesOrdinariosIVA) 
                 --ORDER BY v.Mov , v.MovID --sum(D.InteresesMoratorios) + sum(d.InteresesMoratoriosIVA) + sum(d.InteresesOrdinarios) + sum(d.InteresesOrdinariosIVA) 
    
        OPEN crNotas
        FETCH NEXT FROM crNotas INTO @Mov, @MovID, @InteresesMoratorios, @InteresesMoratoriosIVA, @InteresesOrdinarios, @InteresesOrdinariosIVA
        WHILE @@FETCH_STATUS <> -1 
        BEGIN
          IF @@FETCH_STATUS <> -2 
          BEGIN
            
            SELECT @Renglon = @Renglon + 2048, @RenglonID = @RenglonID + 1
            --INSERT CXCD (Sucursal,  SucursalOrigen, ID,         Renglon, RenglonSub, InteresesOrdinarios, InteresesOrdinariosIVA, InteresesMoratorios,InteresesMoratoriosIVA, Aplica, AplicaID)
            --       VALUES (@Sucursal, @Sucursal, @FacturaID, @Renglon, 0, @InteresesOrdinarios, @InteresesOrdinariosIVA, @InteresesMoratorios, @InteresesMoratoriosIVA, @Mov, @MovID)
						INSERT VentaD (Sucursal,  SucursalOrigen, ID,         Renglon, RenglonSub, RenglonID,  RenglonTipo,  Almacen,  Posicion,  Articulo,  SubCuenta,  Unidad,  Impuesto1,  Impuesto2,  Impuesto3,  Cantidad,  CantidadInventario,  DescuentoTipo,  DescuentoLinea,  Precio,      Costo,  UEN,  Agente, PrecioMoneda, PrecioTipoCambio, CantidadObsequio, OfertaID, PrecioSugerido, DescuentoImporte, Puntos, Comision, DescripcionExtra)
                   VALUES (@Sucursal, @Sucursal,      @FacturaID, @Renglon,         0, @RenglonID, @RenglonTipo, @AlmacenEncabezado, null, @CfgArtInteresMora, NULL, 'pza', ISNULL(@InteresesOrdinariosIVA,0)+ISNULL(@InteresesMoratoriosIVA,0), @Impuesto2, NULL, 1, 1, NULL, NULL, ISNULL(@InteresesOrdinarios,0)+ISNULL(@InteresesMoratorios,0), 0, @UEN, @Agente, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @Mov)           
   
              
          END
          FETCH NEXT FROM crNotas INTO @Mov, @MovID, @InteresesMoratorios, @InteresesMoratoriosIVA, @InteresesOrdinarios, @InteresesOrdinariosIVA
        END -- While
        CLOSE crNotas
        DEALLOCATE crNotas
        -- Ventas

  END
 END

      SELECT 'Proceso Terminado'
  RETURN
END
GO	

