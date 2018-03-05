# Descripción
## Indice
1. 03 spGenerarAsisteAusencia
2. spWfgIntelisisNominaProcesa
## 03 spGenerarAsisteAusencia
Este sp se utiliza en el proceso de corte de asistencias es el responsable de generar los movimientos de faltas y retardos.
Procesa el tiempo de comida independientemente de la hora de salida y entrada de comida
### Importante
Es necesario que en la tabla de **JornadaTiempo** solo exista un registro por día.
## spWfgIntelisisNominaProcesa
Este sp se desarrollo para Wafurga, forma parte de la interfaz con el *Sistema Rosa* y es el responsable de actualizar el la Jornada en la tabla **JornadaTiempo**
### Modificaciones
1. 04/03/2018 - Se modificó el sp para que pudiese reconocer el formato de tiempo "hh:mm:ss" cuando la hora es 00:00:00
