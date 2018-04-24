
[Forma]
Clave=ProcesarTransferencias
Icono=0
Modulos=(Todos)
Nombre=ProcesarTransferencias

ListaCarpetas=ProcesarTransferencias
CarpetaPrincipal=ProcesarTransferencias
PosicionInicialIzquierda=240
PosicionInicialAlturaCliente=379
PosicionInicialAncho=886
VentanaTipoMarco=Normal
VentanaPosicionInicial=Centrado
VentanaEscCerrar=S
VentanaEstadoInicial=Normal
PosicionInicialArriba=155
BarraHerramientas=S
AccionesTamanoBoton=15x5
AccionesDerecha=S
ListaAcciones=(Lista)
[ProcesarTransferencias]
Estilo=Hoja
Clave=ProcesarTransferencias
PermiteEditar=S
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=ProcesarTransferencias
Fuente={Tahoma, 8, Negro, []}
HojaTitulos=S
HojaMostrarColumnas=S
HojaMostrarRenglones=S
HojaColoresPorEstatus=S
HojaVistaOmision=Automática
CampoColorLetras=Negro
CampoColorFondo=Plata
ListaEnCaptura=(Lista)

CarpetaVisible=S

BusquedaRapidaControles=S
FiltroModificarEstatus=S
FiltroCambiarPeriodo=S
FiltroBuscarEn=S
FiltroFechasCambiar=S
FiltroFechasNormal=S
FiltroFechasNombre=&Fecha
BusquedaRapida=S
BusquedaInicializar=S
BusquedaRespetarControles=S
BusquedaAncho=20
BusquedaEnLinea=S
FiltroFechas=S
FiltroFechasCampo=ProcesarTransferencias.Fecha
FiltroSucursales=S
Filtros=S
FiltroPredefinido=S
FiltroNullNombre=(sin clasificar)
FiltroEnOrden=S
FiltroTodoNombre=(Todo)
FiltroAncho=20
FiltroRespetar=S
FiltroTipo=General
OtroOrden=S
ListaOrden=(Lista)
FiltroGeneral=ProcesarTransferencias.Estatus = <T>PENDIENTE<T>
[ProcesarTransferencias.ProcesarTransferencias.Sucursal]
Carpeta=ProcesarTransferencias
Clave=ProcesarTransferencias.Sucursal
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Plata

[ProcesarTransferencias.ProcesarTransferencias.FormaPago]
Carpeta=ProcesarTransferencias
Clave=ProcesarTransferencias.FormaPago
Editar=N
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=50
ColorFondo=Plata

[ProcesarTransferencias.ProcesarTransferencias.ImporteAcumulado]
Carpeta=ProcesarTransferencias
Clave=ProcesarTransferencias.ImporteAcumulado
Editar=N
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Plata

[ProcesarTransferencias.ProcesarTransferencias.ImporteTransferencia]
Carpeta=ProcesarTransferencias
Clave=ProcesarTransferencias.ImporteTransferencia
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S

ColorFondo=Blanco
[ProcesarTransferencias.ProcesarTransferencias.Fecha]
Carpeta=ProcesarTransferencias
Clave=ProcesarTransferencias.Fecha
Editar=N
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Plata

[ProcesarTransferencias.ProcesarTransferencias.FechaTrasnferencia]
Carpeta=ProcesarTransferencias
Clave=ProcesarTransferencias.FechaTrasnferencia
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Blanco

[ProcesarTransferencias.ProcesarTransferencias.Concepto]
Carpeta=ProcesarTransferencias
Clave=ProcesarTransferencias.Concepto
Editar=N
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Plata

[ProcesarTransferencias.ProcesarTransferencias.Estatus]
Carpeta=ProcesarTransferencias
Clave=ProcesarTransferencias.Estatus
Editar=N
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=20
ColorFondo=Plata

[ProcesarTransferencias.ProcesarTransferencias.Concluir]
Carpeta=ProcesarTransferencias
Clave=ProcesarTransferencias.Concluir
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Blanco


[ProcesarTransferencias.Columnas]
Sucursal=49
FormaPago=121
ImporteAcumulado=100
ImporteTransferencia=115
Fecha=94
FechaTrasnferencia=105
Concepto=83
Estatus=75
Concluir=46
























TipoCambio=51
[Acciones.Guardar]
Nombre=Guardar
Boton=23
NombreEnBoton=S
NombreDesplegar=Guardar y Cerrar
EnBarraHerramientas=S
TipoAccion=Ventana
ClaveAccion=Aceptar
Activo=S
Visible=S

[Acciones.Procesar]
Nombre=Procesar
Boton=92
NombreEnBoton=S
NombreDesplegar=Procesar
EnBarraHerramientas=S
Activo=S
Visible=S



EspacioPrevio=S





GuardarAntes=S
TipoAccion=Expresion
RefrescarDespues=S
Multiple=S
ListaAccionesMultiples=(Lista)
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









[Acciones.Sobrante]
Nombre=Sobrante
Boton=61
NombreDesplegar=Sobrante
EnBarraHerramientas=S
Activo=S
Visible=S









TipoAccion=Expresion
GuardarAntes=S
NombreEnBoton=S
Expresion=Asigna(Info.ID,ProcesarTransferencias:ProcesarTransferencias.ID)<BR>EjecutarSQL(<T>EXEC spProcesarTransA :t1, :t2<T>,Info.ID, <T>Sobrante<T>)<BR>ActualizarForma
[ProcesarTransferencias.ProcesarTransferencias.TipoCambio]
Carpeta=ProcesarTransferencias
Clave=ProcesarTransferencias.TipoCambio
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Plata














[Acciones.ConfigFP]
Nombre=ConfigFP
Boton=93
NombreDesplegar=Configurar Forma Pago
EnBarraHerramientas=S
TipoAccion=Formas
ClaveAccion=ProcesarTransferenciasFP
Activo=S
Visible=S



EspacioPrevio=S

































[Acciones.Procesar.SQL]
Nombre=SQL
Boton=0
TipoAccion=Expresion
Activo=S
Visible=S

Expresion=ProcesarSQL(<T>EXEC spProcesarTransferencias :t1, :t2<T>, Empresa,Usuario)
[Acciones.Procesar.Actualizar]
Nombre=Actualizar
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Actualizar Forma
Activo=S
Visible=S





















[Acciones.ConfigSuc]
Nombre=ConfigSuc
Boton=91
NombreDesplegar=Configurar Sucursal
EnBarraHerramientas=S
TipoAccion=Formas
ClaveAccion=ProcesarTransferenciasSucCta
Activo=S
Visible=S







[Acciones.Sobrante.ListaAccionesMultiples]
(Inicio)=Asigna
Asigna=Ejecutar
Ejecutar=Actualizar
Actualizar=(Fin)















[Acciones.Eliminar]
Nombre=Eliminar
Boton=21
NombreDesplegar=Eliminar
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S

Expresion=Asigna(Info.ID,ProcesarTransferencias:ProcesarTransferencias.ID)<BR>EjecutarSQL(<T>EXEC spProcesarTransferenciaEliminar :t1<T>,Info.ID)<BR>ActualizarForma







[ProcesarTransferencias.ListaEnCaptura]
(Inicio)=ProcesarTransferencias.Sucursal
ProcesarTransferencias.Sucursal=ProcesarTransferencias.FormaPago
ProcesarTransferencias.FormaPago=ProcesarTransferencias.TipoCambio
ProcesarTransferencias.TipoCambio=ProcesarTransferencias.ImporteAcumulado
ProcesarTransferencias.ImporteAcumulado=ProcesarTransferencias.ImporteTransferencia
ProcesarTransferencias.ImporteTransferencia=ProcesarTransferencias.Fecha
ProcesarTransferencias.Fecha=ProcesarTransferencias.FechaTrasnferencia
ProcesarTransferencias.FechaTrasnferencia=ProcesarTransferencias.Concepto
ProcesarTransferencias.Concepto=ProcesarTransferencias.Estatus
ProcesarTransferencias.Estatus=ProcesarTransferencias.Concluir
ProcesarTransferencias.Concluir=(Fin)

[ProcesarTransferencias.ListaOrden]
(Inicio)=ProcesarTransferencias.Sucursal	(Acendente)
ProcesarTransferencias.Sucursal	(Acendente)=ProcesarTransferencias.FormaPago	(Acendente)
ProcesarTransferencias.FormaPago	(Acendente)=ProcesarTransferencias.Fecha	(Acendente)
ProcesarTransferencias.Fecha	(Acendente)=ProcesarTransferencias.ID	(Acendente)
ProcesarTransferencias.ID	(Acendente)=(Fin)




























[Acciones.Faltante]
Nombre=Faltante
Boton=61
NombreDesplegar=Faltante
EnBarraHerramientas=S
TipoAccion=Expresion
Activo=S
Visible=S

NombreEnBoton=S
Expresion=Asigna(Info.ID,ProcesarTransferencias:ProcesarTransferencias.ID)<BR>EjecutarSQL(<T>EXEC spProcesarTransA :t1, :t2<T>,Info.ID, <T>Faltante<T>)<BR>ActualizarForma

















[Acciones.Procesar.ListaAccionesMultiples]
(Inicio)=SQL
SQL=Actualizar
Actualizar=(Fin)

[Forma.ListaAcciones]
(Inicio)=Guardar
Guardar=Cerrar
Cerrar=Procesar
Procesar=Sobrante
Sobrante=Faltante
Faltante=Eliminar
Eliminar=ConfigFP
ConfigFP=ConfigSuc
ConfigSuc=(Fin)
