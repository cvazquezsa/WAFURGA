
[Forma]
Clave=WFGFiltroCadSaldo
Icono=0
Modulos=(Todos)
Nombre=Caducidad Saldo

ListaCarpetas=Lista
CarpetaPrincipal=Lista
PosicionInicialAlturaCliente=114
PosicionInicialAncho=299
PosicionInicialIzquierda=533
PosicionInicialArriba=293
VentanaTipoMarco=Normal
VentanaPosicionInicial=Centrado
VentanaExclusiva=S
VentanaEstadoInicial=Normal
VentanaExclusivaOpcion=0
BarraHerramientas=S
AccionesTamanoBoton=15x5
AccionesDerecha=S
ListaAcciones=Herramienta
ExpresionesAlMostrar=Asigna(Info.fecha, NULO)<BR>Asigna(Info.TipoVale, NULO)
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

[Lista.Info.Fecha]
Carpeta=Lista
Clave=Info.Fecha
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco


[Lista.Info.TipoVale]
Carpeta=Lista
Clave=Info.TipoVale
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco


[Lista.Columnas]
Tipo=304
Precio=98
Moneda=107
TieneVigencia=74



[Lista.ListaEnCaptura]
(Inicio)=Info.Fecha
Info.Fecha=Info.TipoVale
Info.TipoVale=(Fin)

[Acciones.Herramienta]
Nombre=Herramienta
Boton=6
NombreDesplegar=&Generar Caducidad Saldo
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S
NombreEnBoton=S

Multiple=S
ListaAccionesMultiples=(Lista)
[Acciones.Herramienta.Variables]
Nombre=Variables
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Variables Asignar
Activo=S
Visible=S

[Acciones.Herramienta.Expresion]
Nombre=Expresion
Boton=0
TipoAccion=Expresion
Activo=S
Visible=S

Expresion=ProcesarSQL(<T>EXEC spWFGCaducidadVales :tfecha, :ttipo, :tusuario, :nsuc<T>,  FechaFormatoServidor(Info.Fecha), Info.TipoVale, Usuario, Sucursal)



[Acciones.Herramienta.Aceptar]
Nombre=Aceptar
Boton=0
TipoAccion=Ventana
ClaveAccion=Aceptar
Activo=S
Visible=S

[Acciones.Herramienta.ListaAccionesMultiples]
(Inicio)=Variables
Variables=Expresion
Expresion=Aceptar
Aceptar=(Fin)
