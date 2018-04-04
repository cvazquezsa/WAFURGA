
[Forma]
Clave=WFGReimpresion
Icono=0
Modulos=(Todos)

ListaCarpetas=Lista
CarpetaPrincipal=Lista
PosicionInicialIzquierda=741
PosicionInicialArriba=428
PosicionInicialAlturaCliente=144
PosicionInicialAncho=438
BarraHerramientas=S
AccionesTamanoBoton=15x5
AccionesDerecha=S
ListaAcciones=(Lista)
Nombre=Reimpresión de Etiquetas
VentanaTipoMarco=Normal
VentanaPosicionInicial=Centrado
VentanaExclusiva=S
VentanaEstadoInicial=Normal
VentanaExclusivaOpcion=0

ExpresionesAlMostrar=EjecutarSQL(<T>spWFGDeleteDatos :nest<T>, Estaciontrabajo)
[Lista.Columnas]
Cuenta=124
SubCuenta=304
Articulo=131
Descripcion1=244

[Acciones.Cerrar]
Nombre=Cerrar
Boton=21
NombreEnBoton=S
NombreDesplegar=&Cerrar
EnBarraHerramientas=S
TipoAccion=Ventana
ClaveAccion=Aceptar
Activo=S
Visible=S

GuardarAntes=S
[Acciones.Preliminar.Variables]
Nombre=Variables
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Variables Asignar
Activo=S
Visible=S

[Acciones.Preliminar.RPT]
Nombre=RPT
Boton=0
TipoAccion=Reportes Pantalla
ClaveAccion=WFGEtiquetas
Activo=S
Visible=S

[Acciones.Preliminar]
Nombre=Preliminar
Boton=6
NombreDesplegar=&Preliminar
EnBarraHerramientas=S
TipoAccion=Reportes Pantalla
ClaveAccion=WFGReimpresionEtiquetas

Activo=S
Visible=S
NombreEnBoton=S


EspacioPrevio=S


GuardarAntes=S
[Acciones.Preliminar.ListaAccionesMultiples]
(Inicio)=Variables
Variables=RPT
RPT=(Fin)



















[(Variables).ListaEnCaptura]
(Inicio)=WFGReimpresionEtiqueta.Articulo
WFGReimpresionEtiqueta.Articulo=WFGReimpresionEtiqueta.Subcuenta
WFGReimpresionEtiqueta.Subcuenta=WFGReimpresionEtiqueta.Cantidad
WFGReimpresionEtiqueta.Cantidad=(Fin)




[Lista]
Estilo=Ficha
Clave=Lista
PermiteEditar=S
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=WFGReimpresionEtiqueta
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

Filtros=S
FiltroPredefinido=S
FiltroNullNombre=(sin clasificar)
FiltroEnOrden=S
FiltroTodoNombre=(Todo)
FiltroAncho=20
FiltroRespetar=S
FiltroTipo=General
FiltroGeneral=WFGReimpresionEtiqueta.Estacion={EstacionTrabajo}
[Lista.WFGReimpresionEtiqueta.Articulo]
Carpeta=Lista
Clave=WFGReimpresionEtiqueta.Articulo
Editar=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco

[Lista.WFGReimpresionEtiqueta.Subcuenta]
Carpeta=Lista
Clave=WFGReimpresionEtiqueta.Subcuenta
Editar=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco

[Lista.WFGReimpresionEtiqueta.Cantidad]
Carpeta=Lista
Clave=WFGReimpresionEtiqueta.Cantidad
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco
















[Lista.ListaEnCaptura]
(Inicio)=WFGReimpresionEtiqueta.Articulo
WFGReimpresionEtiqueta.Articulo=WFGReimpresionEtiqueta.Subcuenta
WFGReimpresionEtiqueta.Subcuenta=WFGReimpresionEtiqueta.Cantidad
WFGReimpresionEtiqueta.Cantidad=(Fin)

[Forma.ListaAcciones]
(Inicio)=Cerrar
Cerrar=Preliminar
Preliminar=(Fin)
