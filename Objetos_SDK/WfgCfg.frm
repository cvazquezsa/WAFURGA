
[Forma]
Clave=WfgCfg
Icono=0
Modulos=(Todos)
MovModulo=(Todos)
Nombre=Wafurga Configuraci�n

ListaCarpetas=Cr�ditos
CarpetaPrincipal=Cr�ditos
PosicionInicialIzquierda=699
PosicionInicialArriba=364
PosicionInicialAlturaCliente=273
PosicionInicialAncho=521
BarraHerramientas=S
AccionesTamanoBoton=15x5
AccionesDerecha=S
ListaAcciones=(Lista)
Comentarios=e(<T>Empresa<T>)+<T>: <T>+Empresa
VentanaTipoMarco=Normal
VentanaPosicionInicial=Centrado
VentanaEscCerrar=S
VentanaEstadoInicial=Normal
[Cr�ditos]
Estilo=Ficha
Pestana=S
Clave=Cr�ditos
PermiteEditar=S
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=WfgCfg
Fuente={Tahoma, 8, Negro, []}
FichaEspacioEntreLineas=6
FichaEspacioNombres=154
FichaNombres=Arriba
FichaAlineacion=Izquierda
FichaColorFondo=Plata
FichaAlineacionDerecha=S
CampoColorLetras=Negro
CampoColorFondo=Blanco
ListaEnCaptura=WfgCfg.ActivarCorteCredito
CarpetaVisible=S

PestanaOtroNombre=S
PestanaNombre=Cr�dito
Filtros=S
FiltroPredefinido=S
FiltroNullNombre=(sin clasificar)
FiltroEnOrden=S
FiltroTodoNombre=(Todo)
FiltroAncho=20
FiltroRespetar=S
FiltroTipo=General
FiltroGeneral=WfgCfg.Empresa=<T>{Empresa}<T>
[Cr�ditos.WfgCfg.ActivarCorteCredito]
Carpeta=Cr�ditos
Clave=WfgCfg.ActivarCorteCredito
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Blanco

[Acciones.Guardar]
Nombre=Guardar
Boton=23
NombreEnBoton=S
NombreDesplegar=&Guardar y Cerrar
GuardarAntes=S
EnBarraHerramientas=S
TipoAccion=Ventana
ClaveAccion=Aceptar
Activo=S
Visible=S

[Acciones.Cancelar]
Nombre=Cancelar
Boton=5
NombreEnBoton=S
NombreDesplegar=&Cancelar
EnBarraHerramientas=S
TipoAccion=Ventana
ClaveAccion=Cancelar/Cancelar Cambios
Activo=S
Visible=S































[Forma.ListaAcciones]
(Inicio)=Guardar
Guardar=Cancelar
Cancelar=(Fin)