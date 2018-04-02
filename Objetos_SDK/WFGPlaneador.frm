[Forma]
Clave=WFGPlaneador
Nombre=Planeador Traspasos
Icono=4
Modulos=(Todos)
ListaCarpetas=Lista
CarpetaPrincipal=Lista
PosicionInicialAltura=502
PosicionInicialAncho=1292
PosicionInicialIzquierda=0
PosicionInicialArriba=0
VentanaTipoMarco=Normal
VentanaPosicionInicial=Centrado
BarraHerramientas=S
AccionesTamanoBoton=15x5
AccionesDerecha=S
ListaAcciones=(Lista)
Menus=S
PosicionSeccion1=77
PosicionInicialAlturaCliente=962
VentanaEstadoInicial=Normal

ExpresionesAlMostrar=EjecutarSQL(<T>EXEC spWFGPlaneadorTraspaso :tfechad, :tfechaa, :temp, :ndias <T>, FechaFormatoServidor(Info.FechaD), FechaFormatoServidor(Info.FechaA), Empresa, 7 )
MenuPrincipal=(Lista)
[Lista]
Estilo=Hoja
Clave=Lista
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=WFGTraspaso
Fuente={MS Sans Serif, 8, Negro, []}
CampoColorLetras=Negro
CampoColorFondo=Blanco
ListaEnCaptura=(Lista)
CarpetaVisible=S
PermiteEditar=S
HojaTitulos=S
HojaMostrarColumnas=S
HojaMostrarRenglones=S
HojaColoresPorEstatus=S
HojaVistaOmision=Automática
ValidarCampos=S
ListaCamposAValidar=(Lista)
Filtros=S
FiltroPredefinido=S
FiltroGrupo1=(Validaciones Memoria)
FiltroValida1=ArtCat
FiltroGrupo2=(Validaciones Memoria)
FiltroValida2=ArtGrupo
FiltroGrupo3=(Validaciones Memoria)
FiltroValida3=ArtFam
FiltroGrupo4=(Validaciones Memoria)
FiltroValida4=ArtLinea
FiltroAplicaEn1=Art.Categoria
FiltroAplicaEn2=Art.Grupo
FiltroAplicaEn3=Art.Familia
FiltroAplicaEn4=Art.Linea
FiltroNullNombre=(sin clasificar)
FiltroEnOrden=S
FiltroTodoNombre=Todos
FiltroAncho=20
FiltroListas=S
FiltroListasRama=INV
FiltroListasAplicaEn=WFGTraspaso.Articulo
FiltroRespetar=S
FiltroTipo=Múltiple (por Grupos)
FiltroTodo=S
FiltroArbol=Articulos
FiltroArbolAplica=Art.Rama
BusquedaRapidaControles=S
FiltroModificarEstatus=S
FiltroCambiarPeriodo=S
FiltroBuscarEn=S
FiltroFechasCambiar=S
FiltroFechasCampo=WFGTraspaso.Fecha
FiltroFechasDefault=Esta Semana
FiltroFechasVencimiento=S
BusquedaRapida=S
BusquedaInicializar=S
BusquedaRespetarControles=S
BusquedaAncho=20
BusquedaEnLinea=S
OtroOrden=S
ListaOrden=(Lista)
MenuLocal=S
ListaAcciones=(Lista)
HojaIndicador=S
Pestana=S
PestanaOtroNombre=S
PestanaNombre=Traspasos
HojaAjustarColumnas=S
FiltroGrupo5=(Validaciones Memoria)
FiltroValida5=Fabricante
FiltroAplicaEn5=Art.Fabricante






[Lista.Columnas]
0=61
1=114
Articulo=83
SubCuenta=74
FechaLiberacion=85
FechaEntrega=76
Cantidad=48
Ruta=68
Descripcion=98
EnFirme=48
Descripcion1=244
Accion=71
Liberar=38
Proveedor=75
Almacen=70
Estado=68
Unidad=38
AlmacenDestino=65
Sucursal=46


SucursalO=64
SucursalD=64
CantidadTraspaso=101
NomSucO=96
NomSucD=209
ArtDescripcion=152
Fecha=94
Subcuenta=74
DescripcionOpcion=304
[Acciones.Cerrar]
Nombre=Cerrar
Boton=23
NombreDesplegar=&Cerrar
TipoAccion=Ventana
ClaveAccion=Cerrar
Activo=S
Visible=S
Menu=&Archivo
UsaTeclaRapida=S
TeclaRapida=Alt+F4
EspacioPrevio=S


[Acciones.Guardar Cambios]
Nombre=Guardar Cambios
Boton=3
NombreDesplegar=Guardar Cambios
EnBarraHerramientas=S
TipoAccion=Controles Captura
ClaveAccion=Guardar Cambios
Activo=S
Visible=S
Menu=&Archivo
UsaTeclaRapida=S
TeclaRapida=Ctrl+G
EnMenu=S





[Centro.Columnas]
0=90
1=250

2=-2
[Centro.Centro.Descripcion]
Carpeta=Centro
Clave=Centro.Descripcion
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=100
ColorFondo=Blanco
ColorFuente=Negro

[Acciones.ArtInfo]
Nombre=ArtInfo
Boton=0
UsaTeclaRapida=S
TeclaRapida=Ctrl+I
NombreDesplegar=Información Artículo
EnMenu=S
EspacioPrevio=S
TipoAccion=Formas
ClaveAccion=ArtInfo
Activo=S
Antes=S
Visible=S
ConCondicion=S
GuardarAntes=S

EjecucionCondicion=ConDatos(WFGTraspaso:WFGTraspaso.Articulo)
AntesExpresiones=Asigna(Info.Articulo, WFGTraspaso:WFGTraspaso.Articulo)

[Centro.Centro.Tipo]
Carpeta=Centro
Clave=Centro.Tipo
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco
ColorFuente=Negro

[Acciones.CentroGrafica]
Nombre=CentroGrafica
Boton=0
UsaTeclaRapida=S
TeclaRapida=Ctrl+G
NombreDesplegar=&Gráfica Centro Trabajo
EnMenu=S
TipoAccion=Expresion
Activo=S
ConCondicion=S
Visible=S
GuardarAntes=S
Expresion=VerCRP(Centro:Centro.Centro+<T> - <T>+Centro:Centro.Descripcion, Centro:Centro.Centro)
EjecucionCondicion=ConDatos(Centro:Centro.Centro)


[Acciones.PlanCentro]
Nombre=PlanCentro
Boton=0
NombreDesplegar=Plan Centro Trabajo
EnMenu=S
TipoAccion=Reportes Pantalla
ClaveAccion=PlanCentro
Activo=S
ConCondicion=S
Antes=S
Visible=S
UsaTeclaRapida=S
TeclaRapida=Shift+Ctrl+P
EjecucionCondicion=ConDatos(Centro:Centro.Centro)
AntesExpresiones=Asigna(Info.Centro, Centro:Centro.Centro)<BR>Asigna(Info.Descripcion, <T>Plan - Centro Trabajo<T>)


[Acciones.CorridaPlaneacion.CorridaPlaneacion]
Nombre=CorridaPlaneacion
Boton=0
TipoAccion=Expresion
Activo=S
Visible=S

Expresion= Forma(<T>EspecificarFechas<T>)
[Acciones.CorridaPlaneacion.Actualizar Vista]
Nombre=Actualizar Vista
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Actualizar Vista
Activo=S
Visible=S

[Acciones.VerOpcion]
Nombre=VerOpcion
Boton=0
NombreDesplegar=&Interpretar Opción
EnMenu=S
TipoAccion=Expresion
EspacioPrevio=S

Expresion=//VerOpcionesArticulo(WFGTraspaso:WFGTraspaso.Articulo, PlanArtOP:PlanArtOP.SubCuenta )
ActivoCondicion=//ConDatos(PlanArtOP:PlanArtOP.SubCuenta)
VisibleCondicion=//PlanArtOP:Art.TipoOpcion=TipoSi


[Acciones.PlanPos]
Nombre=PlanPos
Boton=0
NombreDesplegar=&Posición Artículo
EnMenu=S
TipoAccion=Formas
ClaveAccion=PlanPos
Activo=S
Visible=S
ConCondicion=S
Antes=S
UsaTeclaRapida=S
TeclaRapida=Ctrl+O

EjecucionCondicion=ConDatos(WFGTraspaso:WFGTraspaso.Articulo)
AntesExpresiones=Asigna(Info.Articulo, WFGTraspaso:WFGTraspaso.Articulo)<BR>Asigna(Info.Descripcion,WFGTraspaso:WFGTraspaso.ArtDescripcion)<BR>//Asigna(Info.Almacen, PlanArtOP:PlanArtOP.Almacen)

[Acciones.Proyectos]
Nombre=Proyectos
Boton=0
UsaTeclaRapida=S
TeclaRapida=Ctrl+Y
NombreDesplegar=Pro&yectos
EnMenu=S
TipoAccion=Formas
ClaveAccion=ProyAlm
Antes=S

AntesExpresiones=//Asigna(Info.Almacen, PlanArtOP:PlanArtOP.Almacen)
[Acciones.LiberarOrdenes]
Nombre=LiberarOrdenes
Boton=7
NombreEnBoton=S
Menu=&Archivo
UsaTeclaRapida=S
TeclaRapida=F12
NombreDesplegar=&Liberar Ordenes
GuardarAntes=S
EnBarraHerramientas=S
EspacioPrevio=S
TipoAccion=Expresion
Visible=S


Expresion=ProcesarSQL(<T>EXEC spWFGInsertaTraspaso :tempresa, :tusr<T>,  Empresa, Usuario)<BR>ActualizarVista
ActivoCondicion=Usuario.Afectar
[Acciones.CorridaVenta.RefVenta]
Nombre=RefVenta
Boton=0
TipoAccion=Formas
ClaveAccion=CorridaPlaneacionRefVenta
Activo=S
Visible=S

[Acciones.CorridaVenta.Actualizar Vista]
Nombre=Actualizar Vista
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Actualizar Vista
Activo=S
Visible=S


[Acciones.CorridaInv.RefInv]
Nombre=RefInv
Boton=0
TipoAccion=Formas
ClaveAccion=CorridaPlaneacionRefInv
Activo=S
Visible=S

[Acciones.CorridaInv.Actualizar Vista]
Nombre=Actualizar Vista
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Actualizar Vista
Activo=S
Visible=S


[Centro.ListaEnCaptura]
(Inicio)=Centro.Descripcion
Centro.Descripcion=Centro.Tipo
Centro.Tipo=(Fin)

[Centro.ListaAcciones]
(Inicio)=PlanCentro
PlanCentro=CentroGrafica
CentroGrafica=(Fin)




[Acciones.CorridaProy.RefProy]
Nombre=RefProy
Boton=0
TipoAccion=Formas
ClaveAccion=CorridaPlaneacionRefProy
Activo=S
Visible=S

[Acciones.CorridaProy.ActualizarVista]
Nombre=ActualizarVista
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Actualizar Vista
Activo=S
Visible=S


[Acciones.CorridaProy.ListaAccionesMultiples]
(Inicio)=RefProy
RefProy=ActualizarVista
ActualizarVista=(Fin)






















[Lista.WFGTraspaso.CantidadTraspaso]
Carpeta=Lista
Clave=WFGTraspaso.CantidadTraspaso
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Blanco

[Lista.WFGTraspaso.NomSucO]
Carpeta=Lista
Clave=WFGTraspaso.NomSucO
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=100
ColorFondo=Blanco

[Lista.WFGTraspaso.NomSucD]
Carpeta=Lista
Clave=WFGTraspaso.NomSucD
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=100
ColorFondo=Blanco

[Lista.WFGTraspaso.ArtDescripcion]
Carpeta=Lista
Clave=WFGTraspaso.ArtDescripcion
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=100
ColorFondo=Blanco

[Lista.WFGTraspaso.Accion]
Carpeta=Lista
Clave=WFGTraspaso.Accion
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=50
ColorFondo=Blanco

[Lista.WFGTraspaso.Estado]
Carpeta=Lista
Clave=WFGTraspaso.Estado
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=50
ColorFondo=Blanco


[Forma.ListaCarpetas]
(Inicio)=Lista
Lista=Centro
Centro=(Fin)






















































[Acciones.CorridaPlaneacion.ListaAccionesMultiples]
(Inicio)=CorridaPlaneacion
CorridaPlaneacion=Actualizar Vista
Actualizar Vista=(Fin)

































































[Acciones.RPTCalificaciones]
Nombre=RPTCalificaciones
Boton=6
NombreEnBoton=S
NombreDesplegar=RPT Calificaciones
EnBarraHerramientas=S
TipoAccion=Expresion
Expresion=URL(<T>http://624761-intstar/ReportServer/Pages/ReportViewer.aspx?%2fWafurga%2fWfgCalificaciones&rs:Command=Render<T>)
Activo=S
Visible=S
EspacioPrevio=S
ConCondicion=S
EjecucionConError=S
EjecucionCondicion=(SQL(<T>EXEC spWFGValidaStockMinimo<T>)=0)
EjecucionMensaje=<T>Falta Configurar el Stock Mínimo Para Alguna(s) Sucursal(es)<T>

[Acciones.Prioridad]
Nombre=Prioridad
Boton=45
NombreEnBoton=S
NombreDesplegar=&Prioridades
EnBarraHerramientas=S
TipoAccion=Formas
ClaveAccion=WFGPrioridad
Activo=S
Visible=S
EspacioPrevio=S

[Acciones.Ponderacion]
Nombre=Ponderacion
Boton=61
NombreEnBoton=S
NombreDesplegar=&Ponderaciones
EnBarraHerramientas=S
TipoAccion=Formas
ClaveAccion=WFGPonderacion
Activo=S
Visible=S

[Acciones.Otros1]
Nombre=Otros1
Boton=0
NombreDesplegar=Otros
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S



[Acciones.Otros2]
Nombre=Otros2
Boton=0
NombreDesplegar=Otros2
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S





[Acciones.Otros3]
Nombre=Otros3
Boton=0
NombreDesplegar=Otros3
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S







[Acciones.Otros4]
Nombre=Otros4
Boton=0
NombreDesplegar=Otros
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S



[Acciones.Otros5]
Nombre=Otros5
Boton=0
NombreDesplegar=Otros
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S



[Acciones.Otros6]
Nombre=Otros6
Boton=0
NombreDesplegar=Otros
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S



[Acciones.Otros7]
Nombre=Otros7
Boton=0
NombreDesplegar=Otros
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S









[Acciones.Otros8]
Nombre=Otros8
Boton=0
NombreDesplegar=Otros
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S



[Acciones.Otros9]
Nombre=Otros9
Boton=0
NombreDesplegar=Otros
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S




[Acciones.Recalcular]
Nombre=Recalcular
Boton=92
NombreEnBoton=S
NombreDesplegar=Re&Calcula Plan
EnBarraHerramientas=S
TipoAccion=Formas
Activo=S
Visible=S













GuardarAntes=S
ClaveAccion=WFGEspecificarFechas










































ConCondicion=S
EjecucionConError=S
EjecucionCondicion=(SQL(<T>EXEC spWFGValidaStockMinimo<T>)=0)
EjecucionMensaje=<T>Falta Configurar el Stock Mínimo Para Alguna(s) Sucursal(es)<T>
[Lista.ListaEnCaptura]
(Inicio)=WFGTraspaso.NomSucO
WFGTraspaso.NomSucO=WFGTraspaso.NomSucD
WFGTraspaso.NomSucD=WFGTraspaso.ArtDescripcion
WFGTraspaso.ArtDescripcion=DescripcionOpcion
DescripcionOpcion=WFGTraspaso.CantidadTraspaso
WFGTraspaso.CantidadTraspaso=WFGTraspaso.Accion
WFGTraspaso.Accion=WFGTraspaso.Estado
WFGTraspaso.Estado=(Fin)

[Lista.ListaCamposAValidar]
(Inicio)=WFGTraspaso.Articulo
WFGTraspaso.Articulo=WFGTraspaso.ArtDescripcion
WFGTraspaso.ArtDescripcion=(Fin)

[Lista.ListaOrden]
(Inicio)=WFGTraspaso.SucursalO	(Acendente)
WFGTraspaso.SucursalO	(Acendente)=WFGTraspaso.NomSucO	(Acendente)
WFGTraspaso.NomSucO	(Acendente)=WFGTraspaso.SucursalD	(Acendente)
WFGTraspaso.SucursalD	(Acendente)=WFGTraspaso.NomSucD	(Acendente)
WFGTraspaso.NomSucD	(Acendente)=WFGTraspaso.Articulo	(Acendente)
WFGTraspaso.Articulo	(Acendente)=WFGTraspaso.ArtDescripcion	(Acendente)
WFGTraspaso.ArtDescripcion	(Acendente)=(Fin)

[Lista.ListaAcciones]
(Inicio)=Proyectos
Proyectos=VerOpcion
VerOpcion=ArtInfo
ArtInfo=PlanPos
PlanPos=(Fin)

[Lista.DescripcionOpcion]
Carpeta=Lista
Clave=DescripcionOpcion
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=50
ColorFondo=Blanco

























































[Forma.ListaAcciones]
(Inicio)=Guardar Cambios
Guardar Cambios=LiberarOrdenes
LiberarOrdenes=Recalcular
Recalcular=Cerrar
Cerrar=Prioridad
Prioridad=Ponderacion
Ponderacion=Otros1
Otros1=Otros2
Otros2=Otros3
Otros3=Otros4
Otros4=Otros5
Otros5=Otros6
Otros6=Otros7
Otros7=Otros8
Otros8=Otros9
Otros9=RPTCalificaciones
RPTCalificaciones=(Fin)

[Forma.MenuPrincipal]
(Inicio)=&Archivo
&Archivo=Ve&r
Ve&r=(Fin)
