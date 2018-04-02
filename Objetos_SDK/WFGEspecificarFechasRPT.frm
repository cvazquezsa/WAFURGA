[Forma]
Clave=WFGEspecificarFechasRPT
Nombre=Fechas Especificas
Icono=5
Modulos=(Todos)
ListaCarpetas=(Variables)
CarpetaPrincipal=(Variables)
PosicionInicialIzquierda=560
PosicionInicialArriba=280
PosicionInicialAltura=131
PosicionInicialAncho=246
VentanaTipoMarco=Diálogo
VentanaPosicionInicial=Centrado
BarraAcciones=S
AccionesTamanoBoton=15x5
ListaAcciones=(Lista)
AccionesDivision=S
VentanaExclusiva=S
AccionesCentro=S
PosicionInicialAlturaCliente=139

VentanaEstadoInicial=Normal
VentanaExclusivaOpcion=0
[(Variables)]
Estilo=Ficha
Clave=(Variables)
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=(Variables)
Fuente={MS Sans Serif, 8, Negro, []}
CampoColorLetras=Negro
CampoColorFondo=Blanco
CarpetaVisible=S
FichaEspacioEntreLineas=4
FichaEspacioNombres=65
FichaEspacioNombresAuto=S
FichaNombres=Izquierda
FichaAlineacion=Izquierda
FichaColorFondo=Plata
ListaEnCaptura=(Lista)
PermiteEditar=S

[(Variables).Info.FechaD]
Carpeta=(Variables)
Clave=Info.FechaD
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco

[(Variables).Info.FechaA]
Carpeta=(Variables)
Clave=Info.FechaA
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco

[Acciones.Aceptar]
Nombre=Aceptar
Boton=0
NombreDesplegar=&Aceptar
EnBarraAcciones=S
TipoAccion=Controles Captura
ClaveAccion=Variables Asignar / Ventana Aceptar
Activo=S
Visible=S
Antes=S

Multiple=S
ListaAccionesMultiples=(Lista)
AntesExpresiones=Asigna(Info.VerPendientes, Falso)
[Acciones.Cancelar]
Nombre=Cancelar
Boton=0
NombreDesplegar=Cancelar
EnBarraAcciones=S
TipoAccion=Ventana
ClaveAccion=Cancelar
Activo=S
Visible=S



[Acciones.Aceptar.VariablesAsigna]
Nombre=VariablesAsigna
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Variables Asignar / Ventana Aceptar
Activo=S
Visible=S


[Acciones.Aceptar.Actualiza]
Nombre=Actualiza
Boton=0
TipoAccion=Expresion
Activo=S
Visible=S












Expresion=OtraForma(<T>WFGPlaneador<T>, Forma.ActualizarForma )
[(Variables).ListaEnCaptura]
(Inicio)=Info.FechaD
Info.FechaD=Info.FechaA
Info.FechaA=Info.Dias
Info.Dias=(Fin)

[(Variables).Info.Dias]
Carpeta=(Variables)
Clave=Info.Dias
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco










[Acciones.Aceptar.Reporte]
Nombre=Reporte
Boton=0
TipoAccion=Reportes Pantalla
ClaveAccion=WFGCalificaciones
Activo=S
Visible=S

[Acciones.Aceptar.ListaAccionesMultiples]
(Inicio)=VariablesAsigna
VariablesAsigna=Reporte
Reporte=Actualiza
Actualiza=(Fin)

[Forma.ListaAcciones]
(Inicio)=Aceptar
Aceptar=Cancelar
Cancelar=(Fin)
