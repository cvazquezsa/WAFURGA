# Objetos #
1. spWFGPlaneadorTraspaso.sql
2. WfgVisInventarioFisico.sql
3. spWFGCaducidadVales.sql

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
