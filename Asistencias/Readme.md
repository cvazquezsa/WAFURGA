# Descripción
## Indice
1. 03 spGenerarAsisteAusencia
2. spWfgIntelisisNominaProcesa
3. spWfgGenerarAsisteDomingo
4. spGenerarAsisteCorte
5. spGenerarAsisteCorteMov
## 03 spGenerarAsisteAusencia
Este sp se utiliza en el proceso de corte de asistencias es el responsable de generar los movimientos de faltas y retardos.
Procesa el tiempo de comida independientemente de la hora de salida y entrada de comida
### Importante
Es necesario que en la tabla de **JornadaTiempo** solo exista un registro por día.
## spWfgIntelisisNominaProcesa
Este sp se desarrollo para Wafurga, forma parte de la interfaz con el *Sistema Rosa* y es el responsable de actualizar el la Jornada en la tabla **JornadaTiempo**
### Modificaciones
1. 04/03/2018 - Se modificó el sp para que pudiese reconocer el formato de tiempo "hh:mm:ss" cuando la hora es 00:00:00
## spWfgGenerarAsisteDomingo ##
Este sp de desarrollo para Wafurga, permite considerar los domingos laborados a fin de posteriormente facilitar la emisión de la incidencia Prima Dominical
## spGenerarAsisteCorte ##
### Modificaciones ###
1. 24/03/2018 - Este sp se modificó a fin de que ejecute el **spWfgGenerarAsisteDomingo**
## spGenerarAsisteCorteMov ##
### Modificaciones ###
1. 24/03/2018 - Este sp se modificó a fin de que considere la emisión de la prima dominical independientemente de si el dia labroado fue un día festivo o un descanso laborado
