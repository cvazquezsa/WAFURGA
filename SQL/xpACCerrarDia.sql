SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
/**************** xpACCerrarDia ****************/
if exists (select * from sysobjects where id = object_id('dbo.xpACCerrarDia') and type = 'P') drop procedure dbo.xpACCerrarDia
GO
CREATE PROCEDURE xpACCerrarDia

@Empresa		char(5),
@Usuario		char(10),
@Hoy			datetime,
@Ok			int		OUTPUT,
@OkRef		varchar(255)	OUTPUT
AS BEGIN
 DECLARE
  @Periodo int,
  @Ejercicio int,
  @Saldo money,
  @Cliente varchar(20)

  SELECT @Periodo = MONTH(@Hoy), @Ejercicio = YEAR(@Hoy)
  DECLARE crNotas CURSOR LOCAL
            FOR Select     
									Cliente, Round(Sum(Isnull(Saldo,0)+Isnull(SaldoInteresesOrdinarios,0)+Isnull(SaldoInteresesOrdinariosIVA,0)+Isnull(SaldoInteresesMoratorios,0)+Isnull(SaldoInteresesMoratoriosIVA,0)),2) Importe       
									from CXC     
									Where Empresa=@Empresa AND mov IN ('Amortizacion','Factura Credito','Cargo Moratorio')   
									And Estatus = 'PENDIENTE'     
									GROUP BY CLIENTE
									ORDER BY CLIENTE      
    
        OPEN crNotas
        FETCH NEXT FROM crNotas INTO @Cliente, @Saldo
        WHILE @@FETCH_STATUS <> -1 
        BEGIN
          IF @@FETCH_STATUS <> -2 
          BEGIN
		    
			IF EXISTS (SELECT * FROM wSaldoAnterior WHERE Empresa = @Empresa AND Ejercicio = @Ejercicio AND Periodo = @Periodo AND CLIENTE = @Cliente)        
			 BEGIN
			   UPDATE wSaldoAnterior SET Saldo = @Saldo, UltimoCambio = GETDATE() 
			   WHERE Empresa = @Empresa AND Ejercicio = @Ejercicio AND Periodo = @Periodo AND CLIENTE = @Cliente

			 END
			ELSE
			 BEGIN
			   INSERT INTO wSaldoAnterior (Empresa,UltimoCambio,Cliente,Saldo,Periodo,Ejercicio)
			   SELECT @Empresa, GETDATE(), @Cliente, @Saldo, @Periodo, @Ejercicio
			 END
			
               
          END
          FETCH NEXT FROM crNotas INTO @Cliente, @Saldo
        END -- While
        CLOSE crNotas
        DEALLOCATE crNotas
        -- Ventas

RETURN

END
GO
DECLARE @Ok int, @okRef varchar(255)
EXEC xpACCerrarDia 'E001', 'INTELISIS', '20180201',@Ok, @OkRef  
SELECT * FROM wSaldoAnterior WHERE cliente='C00007'