# Descripción
## Indice
1. 03 spGenerarAsisteAusencia
2. spWfgIntelisisNominaProcesa
3. xpMovFinal
4. spWfgHorasExtras
## 1. 03 spGenerarAsisteAusencia
Este sp se utiliza en el proceso de corte de asistencias es el responsable de generar los movimientos de faltas y retardos.
Procesa el tiempo de comida independientemente de la hora de salida y entrada de comida
### Importante
Es necesario que en la tabla de **JornadaTiempo** solo exista un registro por día.
## 2. spWfgIntelisisNominaProcesa
Este sp se desarrollo para Wafurga, forma parte de la interfaz con el *Sistema Rosa* y es el responsable de actualizar el la Jornada en la tabla **JornadaTiempo**
### Modificaciones
1. 04/03/2018 - Se modificó el sp para que pudiese reconocer el formato de tiempo "hh:mm:ss" cuando la hora es 00:00:00
## 3. xpMovFinal
### Modificaciones
1. 06/03/2018 - Se agregaron lineas para llamar el **spWfgHorasExtras** cuando el movimiento Corte del módulo de asistencias pase a estatus concluido
## 4. spWfgHorasExtras
### Descripción
Este sp calcula el total de minutos laborados y los compara contra las horas por semana indicadas en la Jornada del Empleado, cuando las horas laboradas superan a las horas de la jornada, inserta movimientos de horas extras por día distribuyendo 3 horas por empleado en los dias 1, 2 y 3 y el restante en el cuarto dia.
Por ejemplo: si un empleado tu 10 horas extras, aplica, 3 horas el dia 1, 3 horas el dia 2, 3 horas el dia 3 y 1 hora el día 4.
