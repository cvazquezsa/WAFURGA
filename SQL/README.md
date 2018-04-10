# Objetos #
1. spWFGPlaneadorTraspaso.sql
2. WfgVisInventarioFisico.sql
3. spWFGCaducidadVales.sql
4. WfgCfg.sql
5. spACDevengarIntereses
6. spReporteCredito
7. spReporteEdoCuenta
8. spWfgCorteCredito
9. xpAcCerrardía

# Descripción #
## 1. spWFGPlaneadorTraspaso.sql ##
Este sp controla la funcionalidad principal del planeador de traspasos.
### Modificaciones ###
1. **ultima** - Se corrigió planeador a fin de que calculo de la cantidad a traspasar fuese coherente con las existencias, las calificaciones, la VVP. El archivo proporcionado se llamaba **spWFGPlaneadorTraspaso16MARZO18**
## 2. WfgVisInventarioFisico.sql ##
Sp responsable del reporte de inventario físico que se puede visualizar desde una acción adicional en un movimiento inventario físico en estatus concluido.
### Modificaciones ###
1. **Ultima** - Se modifico la vista a fin de que en el reporte la columna de existencias muestre unicamente el disponible y no las existencias totales.
## 3. spWFGCaducidadVales.sql ##
Sp correspondiente a la herrmaienta **caducidad de saldo de tarjetas**
## 4. WfgCfg.sql ##
Este query contiene la creación de la tabla WfgCfg en cual se deben ingresar las configuraciones especificas para los desarrollos de Wafurga.
### Modificaciones ###
1. Crea tabla considerando el campo **ActivarCorteCredito**, este campo se utilizará para que al procesar el spWfgCorteCredito mediante un job, se genere o no el corte de crédito.
## 5. spACDevengarIntereses ##
Se modifico debido a error de división por cero, se controlo la excepción
## 6. spReporteCredito ##
Se corrigió sp para que tome en cuenta los movimientos *Amortización, Factura Credito, Cargo Moratorio*
## 7. spReporteEdoCuenta ##
Se corrigió sp para que tome en cuenta los movimientos *Amortización, Factura Credito, Cargo Moratorio*
## 8. spWfgCorteCredito ##
sp a utilizarse en job para el proceso de corte de crédito
## 9. xpAcCerrardía ##
