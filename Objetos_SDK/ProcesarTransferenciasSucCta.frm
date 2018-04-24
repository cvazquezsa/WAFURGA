
[Forma]
Clave=ProcesarTransferenciasSucCta
Icono=0
Modulos=(Todos)
Nombre=Configurar Sucursal Cuenta

ListaCarpetas=Lista
VentanaTipoMarco=Normal
VentanaPosicionInicial=Centrado
VentanaEscCerrar=S
VentanaEstadoInicial=Normal
CarpetaPrincipal=Lista
PosicionInicialIzquierda=536
PosicionInicialArriba=208
PosicionInicialAlturaCliente=273
PosicionInicialAncho=293
BarraHerramientas=S
AccionesTamanoBoton=15x5
AccionesDerecha=S
ListaAcciones=(Lista)
[Lista]
Estilo=Hoja
Clave=Lista
PermiteEditar=S
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=ProcesarTransferenciasSucCta
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
[Lista.ListaEnCaptura]
(Inicio)=ProcesarTransferenciasSucCta.Sucursal
ProcesarTransferenciasSucCta.Sucursal=ProcesarTransferenciasSucCta.Moneda
ProcesarTransferenciasSucCta.Moneda=ProcesarTransferenciasSucCta.CuentaDinero
ProcesarTransferenciasSucCta.CuentaDinero=(Fin)

[Lista.ProcesarTransferenciasSucCta.Sucursal]
Carpeta=Lista
Clave=ProcesarTransferenciasSucCta.Sucursal
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Blanco

[Lista.ProcesarTransferenciasSucCta.Moneda]
Carpeta=Lista
Clave=ProcesarTransferenciasSucCta.Moneda
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=10
ColorFondo=Blanco

[Lista.ProcesarTransferenciasSucCta.CuentaDinero]
Carpeta=Lista
Clave=ProcesarTransferenciasSucCta.CuentaDinero
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco

[Lista.Columnas]
Sucursal=64
Moneda=64
CuentaDinero=124
0=84
1=178
TipoCambio=69
2=-2

[Acciones.Guardar]
Nombre=Guardar
Boton=23
NombreEnBoton=S
NombreDesplegar=Aceptar
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
ClaveAccion=Cancelar
Activo=S
Visible=S











[Forma.ListaAcciones]
(Inicio)=Guardar
Guardar=Cerrar
Cerrar=(Fin)
