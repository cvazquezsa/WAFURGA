
[Forma]
Clave=ProcesarTransferenciasFP
Icono=0
Modulos=(Todos)
Nombre=ProcesarTransferenciasFP

ListaCarpetas=lista
CarpetaPrincipal=lista
PosicionInicialIzquierda=528
PosicionInicialArriba=208
PosicionInicialAlturaCliente=273
PosicionInicialAncho=309
VentanaTipoMarco=Normal
VentanaPosicionInicial=Centrado
VentanaEscCerrar=S
VentanaEstadoInicial=Normal
BarraHerramientas=S
AccionesTamanoBoton=15x5
AccionesDerecha=S
ListaAcciones=(Lista)
[lista]
Estilo=Hoja
Clave=lista
PermiteEditar=S
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=ProcesarTransferenciasFP
Fuente={Tahoma, 8, Negro, []}
HojaTitulos=S
HojaMostrarColumnas=S
HojaMostrarRenglones=S
HojaColoresPorEstatus=S
HojaPermiteInsertar=S
HojaPermiteEliminar=S
HojaVistaOmision=Automática
CampoColorLetras=Negro
CampoColorFondo=Blanco
ListaEnCaptura=(Lista)

CarpetaVisible=S

[lista.ProcesarTransferenciasFP.FormaPago]
Carpeta=lista
Clave=ProcesarTransferenciasFP.FormaPago
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=50
ColorFondo=Blanco

[lista.ProcesarTransferenciasFP.CuentaDinero]
Carpeta=lista
Clave=ProcesarTransferenciasFP.CuentaDinero
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco


[lista.Columnas]
FormaPago=145
CuentaDinero=124
0=84
1=178
2=-2

[Acciones.Guardar]
Nombre=Guardar
Boton=23
NombreEnBoton=S
NombreDesplegar=Guardar y Cerrar
GuardarAntes=S
EnBarraHerramientas=S
TipoAccion=Ventana
ClaveAccion=Aceptar
Activo=S
Visible=S

[Acciones.Cerrar]
Nombre=Cerrar
Boton=5
NombreEnBoton=S
NombreDesplegar=Cerrar
EnBarraHerramientas=S
TipoAccion=Ventana
ClaveAccion=Cancelar/Cancelar Cambios
Activo=S
Visible=S




[lista.ListaEnCaptura]
(Inicio)=ProcesarTransferenciasFP.FormaPago
ProcesarTransferenciasFP.FormaPago=ProcesarTransferenciasFP.CuentaDinero
ProcesarTransferenciasFP.CuentaDinero=(Fin)















[Forma.ListaAcciones]
(Inicio)=Guardar
Guardar=Cerrar
Cerrar=(Fin)
