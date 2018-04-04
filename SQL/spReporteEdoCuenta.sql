SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE spReporteEdoCuenta  
  
  @Empresa		Varchar(5),  
  @Estacion		Int,    
  @ClienteD		Varchar(50),    
  @ClienteA		Varchar(50),    
  @Accion		Varchar(50)    
  
--//WITH ENCRYPTION  
  
AS BEGIN  
      
CREATE TABLE #ClientesEdoCuenta (    
     TipoColumna	Varchar(50) Null,    
     Empresa		Varchar(250) Null,    
     CalleEmp		Varchar(250) Null,    
     NumeroEmp		Varchar(250) Null,    
     NumeroIntEmp	Varchar(250) Null,    
     ColoniaEmp		Varchar(250) Null,    
     CiudadEmp		Varchar(250) Null,    
     EstadoEmp		Varchar(250) Null,    
     PaisEmp		Varchar(250) Null,    
     CPEmp			Int Null,    
     Nombre			Varchar(250) Null,    
     Calle			Varchar(250) Null,    
     Colonia		Varchar(250) Null,    
     Ciudad			Varchar(250) Null,    
     Estado			Varchar(250) Null,    
     CP				INT Null,    
     Cliente		Varchar(50) Null,    
     FEmision		Datetime Null,    
     FLimite		Datetime Null,    
     SaldoActual	Money Null,    
     MinimoPagar	Money Null,    
     Cargos			Money Null,    
     Abonos			Money Null,    
     InteresesMoratorios	Money Null,    
     CargosMoratorios		Money Null,    
     MovIdCargo				Varchar(50) Null,    
     FechaCargo				Datetime Null,    
     CargoDetalle			Money Null,    
     MovIdAbono				Varchar(50) Null,    
     FechaAbono				Datetime Null,    
     AbonoDetalle			Money Null)  
          
CREATE TABLE #MinimoPagar (Cliente Varchar(50) Null, FechaCorte Datetime Null, MontoPagar Money Null)    
CREATE TABLE #Cargos (Cliente Varchar(50) NUll, Cargos Money Null)    
CREATE TABLE #Abonos (Cliente Varchar(50) NUll, Abonos Money Null)    
CREATE TABLE #InteresesMoratorios (Cliente Varchar(50) NUll, InteresesMoratorios Money Null)    
CREATE TABLE #CargosMora (Cliente Varchar(50) NUll, CargosMora Money Null)    
    
Declare @FechaPeriodo Datetime    
Declare @FechaCorte  Datetime    
Declare @MinimoPagar Money    
Declare @Cliente  Varchar(50)
Declare @DiaPago  datetime    
    
--Select @ClienteD = min(cliente) from cte where Tipo = 'CLIENTE' And estatus = 'ALTA'  
--Select @ClienteA = Max(cliente) from cte where Tipo = 'CLIENTE' And estatus = 'ALTA'  
--Delete from WafurgaGenerarPDF Where EstacionTrabajo = @Estacion           
--- SACAMOS DATOS BASICOS DE CLIENTES ---  
  
Insert Into #ClientesEdoCuenta (Nombre, Calle, Colonia, Ciudad, Estado, CP, Cliente)    
select     
c.PersonalNombres+' '+c.PersonalApellidoPaterno+' '+c.PersonalApellidoMaterno as Nombre,    
c.Direccion+' '+c.DireccionNumero+' '+c.DireccionNumeroInt as Direccion,     
c.Colonia,    
c.Poblacion,   
c.Estado,    
c.CodigoPostal,     
c.Cliente    
from cte c    
where c.Tipo = 'CLIENTE'    
And c.estatus = 'ALTA'    
And c.Cliente between @ClienteD And @ClienteA    
And c.PersonalNombres is not null
AND CreditoEspecial=1  
  
  
  
---  INSERTAMOS DATOS DE LA EMPRESA  
  
 Update #ClientesEdoCuenta set  Empresa = @Empresa,     
        CalleEmp = e.Direccion,     
        NumeroEmp = e.DireccionNumero,     
        NumeroIntEmp = e.DireccionNumeroInt,     
        ColoniaEmp = e.Colonia,     
        CiudadEmp =  e.Poblacion,     
        EstadoEmp = e.Estado,     
        PaisEmp = e.Pais,     
        CPEmp = e.CodigoPostal,    
        TipoColumna = 'Cabecero'    
 From Empresa e Where e.Empresa = @Empresa      
  
--- SACAMOS DIAS CORTE PARA SABER FECHA EMISION  
  
Select     
lc.Acreditado, lc.Condicion, c.CorteDia, ta.PagoDias DiaPago    
Into #DiasCorte    
from LC    
Left Join Condicion c On c.Condicion = lc.Condicion    
Join TipoAmortizacion ta on ta.TipoAmortizacion = lc.TipoAmortizacion    
Where lc.Estatus IN ('ALTA','CONFIRMAR') and VigenciaHasta >= GETDATE()    
And lc.Acreditado between @ClienteD And @ClienteA      
  
--select * from #DiasCorte      
  
Select     
Acreditado,     
case    when CorteDia = 1 then DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)   
  When CorteDia = 15 And Datepart(dd,Getdate()) < 15 Then DATEADD(mm,-1,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0))+14    
  When CorteDia = 15 And Datepart(dd,Getdate()) between 15 and 31 Then DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)+14    
else Null end FechaCorte, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)+DiaPago-1 DiaPago    
Into #FechaCorte    
from #DiasCorte      
  --select * from #FechaCorte        
Select     
Acreditado, Max(FechaCorte)FechaCorte, DiaPago, DateAdd(DD,1,(DateAdd(MM,-1,Max(FechaCorte))))Periodo    
Into #FechaCorte1    
from #FechaCorte    
Group by Acreditado, DiaPago      
  
Update #ClientesEdoCuenta set FEmision = FechaCorte, FLimite = DiaPago    
from #FechaCorte1    
Where #FechaCorte1.Acreditado = #ClientesEdoCuenta.Cliente      
  
--select * from #FechaCorte1      
  
------*****************----CURSOR  
  
DECLARE crMinimoPagar CURSOR FOR           
 Select cc.Cliente, fc.FechaCorte,fc.DiaPago, fc.Periodo from #ClientesEdoCuenta cc    
 Left Join #FechaCorte1 fc on fc.Acreditado = cc.Cliente      
  
OPEN crMinimoPagar          
FETCH NEXT FROM crMinimoPagar    
INTO @Cliente, @FechaCorte,@DiaPago, @FechaPeriodo      
  
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
  And Vencimiento <= @DiaPago    
  Group by Cliente
  
  --IF @Cliente='PC0020'
  --BEGIN
	 -- SELECT @DiaPago
	 -- Select     
	 -- @Cliente, @FechaCorte ,Round(Sum(Isnull(Saldo,0)+Isnull(SaldoInteresesOrdinarios,0)+Isnull(SaldoInteresesOrdinariosIVA,0)+Isnull(SaldoInteresesMoratorios,0)+ Isnull(SaldoInteresesMoratoriosIVA,0)),2) Importe    
	 -- from CXC     
	 -- Where mov = 'Amortizacion'    
	 -- And Estatus = 'PENDIENTE'    
	 -- And Cliente = @Cliente    
	 -- And FechaEmision <= @DiaPago    
	 -- Group by Cliente
  --END
  --SELECT * FROM #MinimoPagar             
  ---CARGOS  
  
  Insert Into #Cargos (Cliente, Cargos)    
  select     
  v.Cliente, Sum(v.Importe+v.Impuestos)Cargos    
  from Venta v    
  --Join Movtipo mt on mt.mov = v.mov    
  Where v.Estatus = 'CONCLUIDO'    
  And v.Mov = 'Factura Credito'    
  And v.FechaEmision Between @FechaPeriodo And @FechaCorte     
  And v.Cliente = @Cliente    
  Group By v.Cliente    
  
  ---ABONOS  
  
  Insert Into #Abonos (Cliente, Abonos)    
  select     
  CXC.Cliente, sum(CXC.Importe * Cxc.TIPOCAMBIO) Abonos    
  from CXC     
  where CXC.Estatus = 'CONCLUIDO'    
  And CXC.Mov = 'Abono Credito'    
  And CXC.FechaEmision Between @FechaPeriodo And @FechaCorte    
  And CXC.Cliente = @Cliente    
  Group by CXC.Cliente      
  
  ---INTERESES MORATORIOS  
  
  --Insert Into #InteresesMoratorios (Cliente, InteresesMoratorios)    
  --Select     
  --Cliente, Sum(Importe)InteresesMoratorios    
  --from CXC     
  --Where mov = 'Intereses Vencidos'    
  --And Estatus = 'CONCLUIDO'    
  --And FechaEmision Between @FechaPeriodo And @FechaCorte    
  --And Cliente = @Cliente    
  --Group by Cliente
  
  INSERT INTO #InteresesMoratorios (Cliente, InteresesMoratorios) 
  SELECT c2.Cliente,SUM(ISNULL(cd.InteresesMoratorios,0)+ISNULL(cd.InteresesMoratoriosIVA,0))
	FROM Cxc c
		JOIN CxcD cd ON C.ID=cd.ID
		JOIN Cxc c2 ON c2.Mov=cd.Aplica AND c2.MovID=cd.AplicaID
	WHERE 
		c.Mov='Intereses Vencidos' 
		AND c.Estatus='CONCLUIDO' 
		AND c.FechaEmision BETWEEN @FechaPeriodo AND @FechaCorte
		AND c2.Cliente=@Cliente  
	GROUP BY c2.Cliente      
  


  ---CARGOS POR MORA  
  
  --Insert Into #CargosMora (Cliente, CargosMora)    
  --SELECT C2.CLIENTE, isnull(SUM(CXCD.INTERESESMORATORIOS),0) + isnull(SUM(CXCD.InteresesMoratoriosIVA),0)    
  --      FROM CXC JOIN CXCD ON CXC.ID = CXCD.ID AND CXC.MOV = 'Intereses Vencidos'    
  --       JOIN CXC C2 ON CXCD.APLICA = C2.MOV AND CXCD.AplicaID = C2.MOVID     
  --      And cxc.Estatus = 'CONCLUIDO'    
  --And c2.FechaEmision Between (@FechaPeriodo) And @FechaCorte    
  --And c2.Cliente = @Cliente    
  --      GROUP BY C2.CLIENTE      
  
  Insert Into #CargosMora (Cliente, CargosMora)    
  Select     
  Cliente, Sum(ISNULL(Importe,0)+ISNULL(Impuestos,0)) CargosMora    
  from CXC     
  Where mov = 'Cargo Moratorio'    
  And Estatus = 'PENDIENTE'    
  And FechaEmision Between (@FechaPeriodo) And @FechaCorte    
  And Cliente = @Cliente    
  Group by Cliente          
  
  --IF @Cliente='PC0021'
  --Select     
  --Cliente, Sum(ISNULL(Importe,0)+ISNULL(Impuestos,0)) CargosMora    
  --from CXC     
  --Where mov = 'Cargo Moratorio'    
  --And Estatus = 'PENDIENTE'    
  --And FechaEmision Between (@FechaPeriodo) And @FechaCorte    
  --And Cliente = @Cliente    
  --Group by Cliente   

    FETCH NEXT FROM crMinimoPagar    
    INTO @Cliente, @FechaCorte,@DiaPago, @FechaPeriodo  
  
END     
  
CLOSE crMinimoPagar    
DEALLOCATE crMinimoPagar    
--SELECT * fROM #MinimoPagar 
--Actualizamos tabla final con Minimo a pagar  
  
Update #ClientesEdoCuenta set MinimoPagar = Isnull(#MinimoPagar.MontoPagar,0)    
From #MinimoPagar     
Where #MinimoPagar.Cliente = #ClientesEdoCuenta.Cliente      
  
--Actualizamos Cargos  
  
Update #ClientesEdoCuenta set Cargos = Isnull(#Cargos.Cargos,0)    
From #Cargos    
Where #Cargos.Cliente = #ClientesEdoCuenta.Cliente      
  
-- Actualizamos Abonos  
  
Update #ClientesEdoCuenta set Abonos = Isnull(#Abonos.Abonos,0)    
From #Abonos    
Where #Abonos.Cliente = #ClientesEdoCuenta.Cliente      
  
-- Actualizamos Intereses Moratorios  
  
Update #ClientesEdoCuenta set InteresesMoratorios = Isnull(#InteresesMoratorios.InteresesMoratorios,0)    
From #InteresesMoratorios    
Where #InteresesMoratorios.Cliente = #ClientesEdoCuenta.Cliente      
  
-- Actualizamos Cargos Moratorios  
  
Update #ClientesEdoCuenta set CargosMoratorios = Isnull(#CargosMora.CargosMora,0)    
From #CargosMora    
Where #CargosMora.Cliente = #ClientesEdoCuenta.Cliente          
  
---SALDO ACTUAL  
  
Select     
Cliente, Round(Sum(Isnull(Saldo,0)+Isnull(SaldoInteresesOrdinarios,0)+Isnull(SaldoInteresesOrdinariosIVA,0)+Isnull(SaldoInteresesMoratorios,0)+Isnull(SaldoInteresesMoratoriosIVA,0)),2) Importe    
Into #SaldoActual    
from CXC     
Where mov IN ('Amortizacion','Factura Credito','Cargo Moratorio')   
And Estatus = 'PENDIENTE'    
And Cliente between @ClienteD And @ClienteA    
Group by Cliente      
  
--Actualizamos Saldo Actual  
  
Update #ClientesEdoCuenta set SaldoActual = Isnull(#SaldoActual.Importe,0)    
From #SaldoActual    
Where #SaldoActual.Cliente = #ClientesEdoCuenta.Cliente          
  
---CARGOS DETALLE  
  
select     
v.ID, v.movid, v.Cliente, v.FechaEmision  ,Sum(v.Importe)Cargos    
Into #CargosDetalle    
from Venta v    
--Join VentaTCalc vt on vt.ID = v.ID    
--Join Movtipo mt on mt.mov = v.mov    
Where v.Estatus = 'CONCLUIDO'    
And v.Mov = 'Factura Credito'    
And v.FechaEmision Between @FechaPeriodo And @FechaCorte    
And v.Cliente Between @ClienteD And @ClienteA    
Group By v.Cliente, v.id, v.movid, v.FechaEmision    
Order by 3  
      
-- INSERTAMOS CARGOS A DETALLE  
  
Insert Into #ClientesEdoCuenta (TipoColumna, Cliente, MovIdCargo, FechaCargo, CargoDetalle)    
Select 'Cargo', Cliente, MovID, FechaEmision, Cargos from #CargosDetalle         
  
---ABONOS DETALLE  
  
select     
ID, Movid, Cliente, FechaEmision, Sum(Importe*TipoCambio)Abonos    
Into #AbonosDetalle    
from CXC    
where Estatus = 'CONCLUIDO'    
And Mov = 'Abono Credito'    
And FechaEmision Between @FechaPeriodo And @FechaCorte    
And Cliente Between @ClienteD And @ClienteA    
Group by Cliente, id, movid, FechaEmision    
Order by 3      
  
--- INSERTAMOS ABONOS A DETALLE  
  
Insert Into #ClientesEdoCuenta (TipoColumna, Cliente, MovIdAbono, FechaAbono, AbonoDetalle)    
Select 'ZAbono', Cliente, MovID, FechaEmision, Abonos from #AbonosDetalle          
  
IF @Accion = 'GUARDAR'    
BEGIN    
---- INSERTAMOS REGISTROS QUE SE GENERARAN LOS PDFS  
  
INSERT INTO WafurgaGenerarPDF (Contacto, Tipo, Accion, EstacionTrabajo)    
Select     
Distinct    
Cliente, 'Cliente','EdoCuentaCXC',@Estacion    
From #ClientesEdoCuenta  
  
END      
  
Select Cliente, FEmision, FLimite     
Into #Fechas    
from #ClientesEdoCuenta    
Where TipoColumna = 'Cabecero'          
  
Update #ClientesEdoCuenta set FEmision = f.FEmision, FLimite = f.FLimite    
From #Fechas f    
Where f.Cliente = #ClientesEdoCuenta.Cliente And #ClientesEdoCuenta.TipoColumna <> 'Cabecero'      
  
----- CONSULTA FINAL  
  
Select     
*    
from #ClientesEdoCuenta     
Order by Cliente, TipoColumna          
  
--Select ced.*, cd.MovID MovIDCargo, cd.FechaEmision FechaCargo, cd.Cargos CargoDetalle    
--Into #ClientesEdoCuenta1    
--from #ClientesEdoCuenta ced    
--Left Join #CargosDetalle cd on cd.Cliente = ced.Cliente    
----Left Join #AbonosDetalle ad on ad.Cliente = ced.Cliente      
  
--select     
--ced.*, ad.MovID MovIDAbono, ad.FechaEmision FechaAbono, ad.Abonos AbonoDetalle    
--from #ClientesEdoCuenta1 ced    
--Left Join #AbonosDetalle ad on ad.Cliente = ced.Cliente      
  
RETURN   
  
END
