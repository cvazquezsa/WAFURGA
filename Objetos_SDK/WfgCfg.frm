
[Forma]
Clave=WfgCfg
Icono=0
Modulos=(Todos)
MovModulo=(Todos)
Nombre=Wafurga Configuración

ListaCarpetas=(Lista)
CarpetaPrincipal=Créditos
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
[Créditos]
Estilo=Ficha
Pestana=S
Clave=Créditos
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
ListaEnCaptura=(Lista)
CarpetaVisible=S

PestanaOtroNombre=S
PestanaNombre=Crédito
Filtros=S
FiltroPredefinido=S
FiltroNullNombre=(sin clasificar)
FiltroEnOrden=S
FiltroTodoNombre=(Todo)
FiltroAncho=20
FiltroRespetar=S
FiltroTipo=General
FiltroGeneral=WfgCfg.Empresa=<T>{Empresa}<T>
[Créditos.WfgCfg.ActivarCorteCredito]
Carpeta=Créditos
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
































[Créditos.ListaEnCaptura]
(Inicio)=WfgCfg.ActivarCorteCredito
WfgCfg.ActivarCorteCredito=WfgCfg.DiaCorteCredito
WfgCfg.DiaCorteCredito=(Fin)

[Créditos.WfgCfg.DiaCorteCredito]
Carpeta=Créditos
Clave=WfgCfg.DiaCorteCredito
Editar=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco




































[Nomina]
Estilo=Ficha
Pestana=S
PestanaOtroNombre=S
PestanaNombre=Nómina
Clave=Nomina
PermiteEditar=S
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=WfgCfg
Fuente={Tahoma, 8, Negro, []}
FichaEspacioEntreLineas=6
FichaEspacioNombres=100
FichaEspacioNombresAuto=S
FichaNombres=Arriba
FichaAlineacion=Izquierda
FichaColorFondo=Plata
FichaAlineacionDerecha=S
CampoColorLetras=Negro
CampoColorFondo=Blanco
ListaEnCaptura=(Lista)

CarpetaVisible=S

[Nomina.WfgCfg.NomConceptoSiVale]
Carpeta=Nomina
Clave=WfgCfg.NomConceptoSiVale
Editar=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco

[Nomina.WfgCfg.NomPropiedadSiVale]
Carpeta=Nomina
Clave=WfgCfg.NomPropiedadSiVale
Editar=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Blanco



[Nomina.ListaEnCaptura]
(Inicio)=WfgCfg.NomConceptoSiVale
WfgCfg.NomConceptoSiVale=WfgCfg.NomPropiedadSiVale
WfgCfg.NomPropiedadSiVale=(Fin)



[Forma.ListaCarpetas]
(Inicio)=Créditos
Créditos=Nomina
Nomina=(Fin)

[Forma.ListaAcciones]
(Inicio)=Guardar
Guardar=Cancelar
Cancelar=(Fin)
