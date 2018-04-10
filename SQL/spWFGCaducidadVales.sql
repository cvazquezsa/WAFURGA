SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
GO

/**************** spWFGCaducidadVales ****************/
IF EXISTS (select * from sysobjects where id = object_id('dbo.spWFGCaducidadVales') and type = 'P') drop procedure dbo.spWFGCaducidadVales
GO
CREATE PROCEDURE spWFGCaducidadVales
@Fecha    datetime,
@Tipo     varchar(50),
@Usuario  varchar(20),
@Sucursal int
AS BEGIN
   DECLARE @Estatus       varchar(20),
           @Serie         varchar(50),
		   @Mov           varchar(20), 
		   @Moneda        varchar(20), 
		   @TipoCambio    float,
		   @EstatusMov    varchar(20),
		   @Empresa       varchar(5),
		   @FechaEmision  datetime,
		   @Saldo         float,
		   @FechaRegistro datetime,
		   @Articulo      varchar(20),
		   @IDVale        int,
		   @Modulo        varchar(5),
		   @MovTipo       varchar(20),
		   @EstatusNuevo  varchar(20),
		   @MovID         varchar(20),
		   @Proyecto      varchar(50), 
		   @Autorizacion  varchar(10), 
		   @DocFuente     int, 
		   @Observaciones varchar(100), 
		   @Ejercicio     int, 
		   @Periodo       int, 
           @Precio        float, 
		   @OK            int,
		   @OKRef             varchar(255),
		   @TipoTieneVigencia int, 
		   @FechaTermino      datetime,
           @Cliente           varchar(20), 
		   @Agente            varchar(20), 
		   @Condicion         varchar(50), 
		   @Descuento         varchar(30), 
		   @Concepto          varchar(50), 
		   @Referencia        varchar(50), 
		   @CtaDinero         varchar(10), 
		   @FormaPago         varchar(50),
		   @MovNCredito       varchar(20), 
		   @MovNCargo         varchar(20),
		   @SucursalDestino    int, 
		   @SucursalOrigen     int,
		   @CfgContX           bit, 
		   @CfgContXGenerar    varchar(20), 
		   @GenerarPoliza      bit,
           @GenerarMov         varchar(20), 
		   @IDGenerar          int, 
		   @GenerarMovID       varchar(20)
          


   SELECT @Estatus='CIRCULACION'
   SELECT @Mov='Caducidad Saldo', @EstatusMov='SINAFECTAR', @Moneda='Pesos', @FechaEmision=dbo.fnFechaSinHora(GETDATE()), @FechaRegistro=GETDATE(),
   @Modulo='VALE', @MovTipo='VALE.CS', @EstatusNuevo='CONCLUIDO', @Proyecto=NULL, @Autorizacion=NULL, @DocFuente=NULL, @Observaciones=NULL,
   @GenerarPoliza=0

   EXEC spMovTipo @Modulo, @Mov, @FechaEmision, NULL, NULL, NULL, @MovTipo OUTPUT, @Periodo OUTPUT, @Ejercicio OUTPUT, @Ok OUTPUT

   SELECT @TipoCambio=TipoCambio FROM Mon WHERE Moneda=@Moneda
   

   CREATE TABLE #CaducidadSaldo (Empresa varchar(5) NULL, Serie varchar(20) NULL, FechaTermino datetime NULL, Cliente varchar(20) NULL, Articulo varchar(20) NULL, Saldo float)

   INSERT INTO #CaducidadSaldo (Empresa,  Serie, FechaTermino, Cliente, Articulo, Saldo)
                         SELECT Empresa,  Serie, FechaTermino, Cliente, Articulo, dbo.fnVerSaldoVale(Serie)
                         FROM ValeSerie
                         WHERE Estatus=@Estatus
                         AND Tipo=@Tipo AND
                         FechaTermino < @Fecha

   --select * from #CaducidadSaldo
   BEGIN TRANSACTION
   DECLARE crCadSaldo CURSOR FAST_FORWARD FOR
     SELECT Serie
     FROM #CaducidadSaldo
   OPEN crCadSaldo
   FETCH NEXT FROM crCadSaldo INTO @Serie
   WHILE @@FETCH_STATUS = 0 
   BEGIN
     SELECT @Saldo=NULL, @IDVale=NULL
     
     SELECT @Empresa=Empresa, @Saldo=Saldo, @Articulo=Articulo FROM #CaducidadSaldo WHERE Serie=@Serie

     INSERT INTO Vale (Empresa,       Mov,           FechaEmision,  UltimoCambio,   Estatus,     Moneda, TipoCambio,   Usuario,  Importe, Cantidad, FechaRegistro,  FechaConclusion,
                       Vencimiento,   FechaInicio,   Articulo)
                SELECT @Empresa,      @Mov,          @FechaEmision, @FechaRegistro, @EstatusMov, @Moneda, @TipoCambio, @Usuario, @Saldo,  1,        @FechaRegistro, @FechaEmision,
                       @FechaEmision, @FechaEmision, @Articulo   
     
	 SELECT @IDVale = SCOPE_IDENTITY()

     INSERT INTO ValeD (ID,      Serie,  Sucursal,  Importe)
	             SELECT @IDVale, @Serie, @Sucursal, @Saldo
     
	 IF ISNULL(@IDVale,0) > 0 --AND ISNULL(@Ok,0) = 0
     BEGIN
       EXEC spAfectar 'VALE', @IDVale, 'AFECTAR', 'Todo', @Usuario = @Usuario, @EnSilencio = 1, @Conexion = 1, @Ok = @Ok OUTPUT, @OkRef = @OkRef OUTPUT 
     END

   FETCH NEXT FROM crCadSaldo INTO @Serie
   END    
   CLOSE crCadSaldo
   DEALLOCATE crCadSaldo 

  IF EXISTS(SELECT * FROM MensajeLista WHERE Mensaje = @Ok AND Tipo = 'INFO') OR ISNULL(@OK,0) = 0
   BEGIN ---- O K		        
     COMMIT  
     SELECT 'El Proceso se generó correctamente' 
   END   ---- O K
	ELSE
	BEGIN
	   ROLLBACK 
	   SELECT 'Hubo errores en el proceso ' + Descripcion  + ' ' + @OKRef  FROM MensajeLista WHERE Mensaje = @ok 
	 END


END
GO
/*begin transaction
EXEC spWFGCaducidadVales '20480226', 'Monedero Electronico', 'S2C1', 1
				select * from vale where mov='caducidad saldo' and id > 1524627
					 select * from valed where id in (select id from vale where mov='caducidad saldo' and id > 1524627)
					 select * from AuxiliarValeSerie
					 select dbo.fnVerSaldoVale('MON-C00009')
					 select dbo.fnVerSaldoVale('MON-M00003')--
rollback
*/
