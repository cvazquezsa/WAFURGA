ALTER PROCEDURE spReportecredito
		@Empresa			Varchar(5),
		@RFC				Varchar(2)

--//WITH ENCRYPTION

AS BEGIN

CREATE TABLE #ClientesCredito (
					Email				Varchar(250) Null,
					Apellidos			Varchar(250) Null,
					Nombre				Varchar(250) Null,
					RFC					Varchar(250) Null,
					Calle				Varchar(250) Null,
					Colonia				Varchar(250) Null,
					CP					INT Null,
					Cliente				Varchar(50) Null,
					MinimoPagar			Money Null,
					FAperturaCredito	Varchar(20) Null,
					FUltimoPago			Varchar(20) Null,
					FUltimaCompra		Varchar(20) Null,
					AcumuladoCompra		Money Null,
					SaldoActual			Money Null,
					LimiteCredito		Money Null,
					Abonos              Money Null)

CREATE TABLE #MinimoPagar (Cliente Varchar(50) Null, FechaCorte Datetime Null, MontoPagar Money Null)
CREATE TABLE #BONOS(Cliente Varchar(50) Null, MontoAbono Money Null)

Declare @Cliente		Varchar(50)
Declare @FechaCorte		Datetime
Declare @MinimoPagar	Money
Declare @FechaDia		Datetime

---FECHA VIGENCIA Y LIMITE DE CREDITO

Select 
Acreditado, Max(VigenciaDesde)FApersura, Max(Importe)ImporteCredito
Into #FechaVigencia
from LC
Where Estatus in ('ALTA', 'CONFIRMAR')
Group by Acreditado

--- SACAMOS DATOS BASICOS DE CLIENTES ---
Insert Into #ClientesCredito (Email, Apellidos, Nombre, RFC, Calle, Colonia, CP, Cliente)
select 
c.eMail1,
c.PersonalApellidoPaterno+' '+c.PersonalApellidoMaterno as Apellido,
c.PersonalNombres as Nombre,
c.RFC, 
c.Direccion+' '+c.DireccionNumero+' '+c.DireccionNumeroInt as Direccion, 
c.Colonia,
c.CodigoPostal, 
c.Cliente
from cte c
Join #FechaVigencia fv on fv.Acreditado = c.Cliente
where c.Tipo = 'CLIENTE'
And c.estatus = 'ALTA'

--And c.PersonalApellidoPaterno is not null



-----FECHA VIGENCIA Y LIMITE DE CREDITO

--Select 

--Acreditado, Max(VigenciaDesde)FApersura, Max(Importe)ImporteCredito

--Into #FechaVigencia

--from LC

--Where Estatus ='ALTA'

--Group by Acreditado



--Actualizamos la fecha de Apertura de Credito

Update #ClientesCredito set FAperturaCredito = Convert(varchar,#FechaVigencia.FApersura,103), LimiteCredito = Isnull(ImporteCredito,0)

From #FechaVigencia

Where #FechaVigencia.Acreditado = #ClientesCredito.Cliente



---ULTIMO PAGO

select 

Cliente, Max(FechaEmision)FUltimoPago

Into #FUltimoPago

from CXC

where Estatus = 'Concluido'

And Mov = 'Abono Credito'

Group by Cliente



-- Actualizamos Fecha de ultimo Pago

Update #ClientesCredito set FUltimoPago = Convert(varchar,#FUltimoPago.FUltimoPago,103)

From #FUltimoPago

Where #FUltimoPago.Cliente = #ClientesCredito.Cliente



--- ULTIMA COMPRA

select 

v.Cliente, v.Mov, Max(v.movid)MovID, Max(v.FechaEmision)Fecha

Into #UltimaCompra

from Venta v

Join Movtipo mt on mt.mov = v.mov

And mt.clave = 'VTAS.F' And mt.mov = 'Factura Credito'

Where v.Estatus = 'CONCLUIDO'

Group by v.cliente, v.Mov



--Actualizamos la fecha de ultima compra

update #ClientesCredito set FUltimaCompra = Convert(varchar,#UltimaCompra.Fecha,103)

From #UltimaCompra 

Where #UltimaCompra.Cliente = #ClientesCredito.Cliente





---ACUMULADO DE COMPRA

select 

v.Cliente, Sum(v.Importe+v.Impuestos)SumaCompra

Into #CompraAcum

from Venta v

Join Movtipo mt on mt.mov = v.mov AND mt.Modulo = 'VTAS'

Where v.Estatus = 'CONCLUIDO'

And v.Mov = 'Factura Credito'

Group By v.Cliente



--SELECT * FROM #CompraAcum



--Actualizamos Acumulado de Compra

Update #ClientesCredito set AcumuladoCompra = Isnull(#CompraAcum.Sumacompra,0)

From #CompraAcum

Where #CompraAcum.Cliente = #ClientesCredito.Cliente



---SALDO ACTUAL

Select 

Cliente, Round(Sum(Isnull(Saldo,0)+Isnull(SaldoInteresesOrdinarios,0)+Isnull(SaldoInteresesOrdinariosIVA,0)+Isnull(SaldoInteresesMoratorios,0)+Isnull(SaldoInteresesMoratoriosIVA,0)),2) Importe

Into #SaldoActual

from CXC 

Where mov IN ('Amortizacion','Factura Credito','Cargo Moratorio')

And Estatus = 'PENDIENTE'

Group by Cliente



--Actualizamos Saldo Actual

Update #ClientesCredito set SaldoActual = Isnull(#SaldoActual.Importe,0)

From #SaldoActual

Where #SaldoActual.Cliente = #ClientesCredito.Cliente





--- SACAMOS DIAS CORTE PARA SABER EL MINIMO A PAGAR

Select 

lc.Acreditado, lc.Condicion, c.CorteDia

Into #DiasCorte

from LC

Left Join Condicion c On c.Condicion = lc.Condicion

Where lc.Estatus in ('ALTA', 'CONFIRMAR')



Select 

Acreditado, 

case    when CorteDia = 1 then DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)

		When CorteDia = 15 And Datepart(dd,Getdate()) < 15 Then DATEADD(mm,-1,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0))+14

		When CorteDia = 15 And Datepart(dd,Getdate()) between 15 and 31 Then DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)+14

else Null end FechaCorte

Into #FechaCorte

from #DiasCorte



Select 

Acreditado, Max(FechaCorte)FechaCorte

Into #FechaCorte1

from #FechaCorte

Group by Acreditado



------*****************----CURSOR

DECLARE crMinimoPagar CURSOR FOR   



	Select cc.Cliente, fc.FechaCorte from #ClientesCredito cc

	Left Join #FechaCorte1 fc on fc.Acreditado = cc.Cliente



OPEN crMinimoPagar

  

FETCH NEXT FROM crMinimoPagar

INTO @Cliente, @FechaCorte 



WHILE @@FETCH_STATUS = 0  

BEGIN 



		---Sacamos Monto a pagar a la fecha de corte

		Insert Into #MinimoPagar (Cliente, FechaCorte, MontoPagar)
		Select 
		@Cliente, @FechaCorte ,Round(Sum(Isnull(Saldo,0)+Isnull(SaldoInteresesOrdinarios,0)+Isnull(SaldoInteresesOrdinariosIVA,0)+Isnull(SaldoInteresesMoratorios,0)+ Isnull(SaldoInteresesMoratoriosIVA,0)),2) Importe
		from CXC 
		Where mov IN ('Amortizacion','Factura Credito','Cargo Moratorio')
		And Estatus = 'PENDIENTE'
		And Cliente = @Cliente
		And FechaEmision <= @FechaCorte
		Group by Cliente

		-- COBROS GENERADOS A LA FECHA DE CORTE
		INSERT INTO #BONOS(Cliente, MontoAbono)
		select 
		Cliente, Round(Sum(Isnull(Saldo,0)+Isnull(SaldoInteresesOrdinarios,0)+Isnull(SaldoInteresesOrdinariosIVA,0)+Isnull(SaldoInteresesMoratorios,0)+ Isnull(SaldoInteresesMoratoriosIVA,0)),2) Importe
		from CXC
		where Estatus = 'Concluido'
		And Mov = 'Abono Credito'
		And Cliente = @Cliente
		And FechaEmision >= @FechaCorte and FechaEmision <= getdate()
		Group by Cliente




    FETCH NEXT FROM crMinimoPagar

    INTO @Cliente, @FechaCorte

END   

CLOSE crMinimoPagar

DEALLOCATE crMinimoPagar



--Actualizamos tabla final con Minimo a pagar

Update #ClientesCredito set MinimoPagar = Isnull(#MinimoPagar.MontoPagar,0)

From #MinimoPagar 

Where #MinimoPagar.Cliente = #ClientesCredito.Cliente

-- Abonos
Update #ClientesCredito set Abonos = Isnull(#BONOS.MontoAbono,0)
From #BONOS 
Where #BONOS.Cliente = #ClientesCredito.Cliente




----- CONSULTA FINAL

IF @RFC = 'SI'

BEGIN

Select 

@Empresa Empresa, Email, Apellidos, Nombre, RFC, Calle, Colonia, CP, Cliente, MinimoPagar, FAperturaCredito, FUltimoPago, FUltimaCompra, 

AcumuladoCompra, SaldoActual, LimiteCredito, Abonos

from #ClientesCredito 

END

ELSE

IF @RFC = 'NO'

BEGIN

Select 

@Empresa Empresa, Email, Apellidos, Nombre, Calle, Colonia, CP, Cliente, MinimoPagar, FAperturaCredito, FUltimoPago, FUltimaCompra, 

AcumuladoCompra, SaldoActual, LimiteCredito, Abonos

from #ClientesCredito 

END



RETURN 

END
GO