
[Forma]
Clave=WFGCargaSistRosa
Icono=0
Modulos=(Todos)
Nombre=Carga Sistema Rosa
VentanaTipoMarco=Normal
VentanaPosicionInicial=Centrado
VentanaExclusiva=S
VentanaEstadoInicial=Normal
VentanaExclusivaOpcion=0

ListaCarpetas=Lista
CarpetaPrincipal=Lista
PosicionInicialIzquierda=433
PosicionInicialArriba=288
PosicionInicialAlturaCliente=123
PosicionInicialAncho=500
BarraHerramientas=S
AccionesTamanoBoton=15x5
AccionesDerecha=S
ListaAcciones=Preliminar
ExpresionesAlMostrar=Asigna(Info.FechaD, PrimerDiaMes)<BR>Asigna(Info.FechaA, UltimoDiaMes)<BR>Asigna(Info.ArtCat, NULO)<BR>Asigna(Info.WFGReporte, NULO)
[Lista]
Estilo=Ficha
Clave=Lista
PermiteEditar=S
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=(Variables)
Fuente={Tahoma, 8, Negro, []}
FichaEspacioEntreLineas=6
FichaEspacioNombres=100
FichaEspacioNombresAuto=S
FichaNombres=Izquierda
FichaAlineacion=Izquierda
FichaColorFondo=Plata
FichaAlineacionDerecha=S
CampoColorLetras=Negro
CampoColorFondo=Blanco
ListaEnCaptura=(Lista)

CarpetaVisible=S

[Lista.Info.FechaD]
Carpeta=Lista
Clave=Info.FechaD
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco

[Lista.Info.FechaA]
Carpeta=Lista
Clave=Info.FechaA
Editar=S
LineaNueva=N
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco

[Lista.Info.ArtCat]
Carpeta=Lista
Clave=Info.ArtCat
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco

[Lista.Columnas]
Categoria=234

[Acciones.Preliminar.Variables]
Nombre=Variables
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Variables Asignar
Activo=S
Visible=S


[Acciones.Preliminar.Variables1]
Nombre=Variables1
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Variables Asignar
Activo=S
Visible=S

[Acciones.Preliminar]
Nombre=Preliminar
Boton=6
NombreEnBoton=S
NombreDesplegar=&Preliminar
Multiple=S
EnBarraHerramientas=S
ListaAccionesMultiples=(Lista)
Activo=S
Visible=S

[Acciones.Preliminar.Expresion]
Nombre=Expresion
Boton=0
TipoAccion=Expresion
Activo=S
Visible=S

Expresion=Caso Info.WFGReporte<BR>  Es <T>Reporte ACC<T> Entonces ReportePantalla(<T>WFGRPTACC<T>)<BR>  Es <T>Reporte BL<T> Entonces ReportePantalla(<T>WFGRPTBL<T>)<BR>  Es <T>Reporte NP<T> Entonces ReportePantalla(<T>WFGRPTNP<T>)<BR>  Es <T>Reporte Ventas<T> Entonces ReportePantalla(<T>WFGRPTVentas<T>)<BR>Fin
[Acciones.Preliminar.Aceptar]
Nombre=Aceptar
Boton=0
TipoAccion=Ventana
ClaveAccion=Aceptar
Activo=S
Visible=S


[Lista.Info.WFGReporte]
Carpeta=Lista
Clave=Info.WFGReporte
Editar=S
LineaNueva=N
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco

[Lista.ListaEnCaptura]
(Inicio)=Info.FechaD
Info.FechaD=Info.FechaA
Info.FechaA=Info.ArtCat
Info.ArtCat=Info.WFGReporte
Info.WFGReporte=(Fin)

[Acciones.Preliminar.ListaAccionesMultiples]
(Inicio)=Variables1
Variables1=Expresion
Expresion=Aceptar
Aceptar=(Fin)
