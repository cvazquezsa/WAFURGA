# Formatos SBX #
## Descripción ##
Esta Carpeta contiene formatos de SBX que han sido modificados en el proyecto WAFURGA
## Indice ##
1. 47.apartadoWafurgav1.6
2. Nota de ventaR9RMFolioCRv19
3. 54.Abono_de_credidoWaf_v2.0.0
4. 15.RecTrasp
## 47.apartadoWafurgav1.6 ##
+ 11/03/2018 - Se elimino la sección "su crédito en tienda es..."
+ Se duplico página la cual solo se muestra cuanel el ultimo abono fue con NC, CR o ME.
+ se elimino Campo Cambio y Campo recibido.

## 1.Nota de ventaR9RMFolioCRv19 ##
+ 11/03/2018 - se agrego sección **Nota de crédito genederada** la cual solo debe poderse visualizar cuando la nota de devolución haya generado una nota de crédito
+ 11/03/2018 - se modificó script a fin de que cuando el ticket sea a cuenta se imprima la página 2.
+ 11/03/2018 - Se modificó Forma de pago para que cuando la forma de pago sea CR, NC se concatene el nombre de la forma de pago con el Folio o IdCard segun corresponda.
+ 11/03/2018 - Se modificó DateSet **SaleDocumentPayment** para que considere transacciones que aumentan puntos a monedero y transacciones que utilizan el saldo del monedero, en el ultimo caso el ticket debe imprimirse 2 veces
+ Cuando la nota provenga de una liquidación de apartado, el ticket se imprimirá una sola vez.

## 54.Abono_de_credidoWaf_v2.0.0 ##

## 15.RecTrasp ##
Se corrigio sintaxis de consultas