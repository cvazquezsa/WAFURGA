/****** Object:  View [dbo].[vMovImpDin_Origen]    Script Date: 10/06/2015 12:22:19 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vMovImpDin_Origen]'))
DROP VIEW [dbo].[vMovImpDin_Origen]
GO

CREATE VIEW [dbo].[vMovImpDin_Origen]
AS 
SELECT     MI.Modulo, MI.ModuloID, MI.ID, MI.Impuesto1, MI.Impuesto2, MI.Impuesto3, MI.Impuesto5, MI.Importe1, MI.Importe2, MI.Importe3, MI.Importe5, MI.SubTotal, 
                      MI.LoteFijo, MI.Retencion1, MI.Retencion2, MI.Retencion3, MI.Excento1, MI.Excento2, MI.Excento3, MI.TipoImpuesto1, MI.TipoImpuesto2, MI.TipoImpuesto3, 
                      MI.TipoImpuesto5, MI.TipoRetencion1, MI.TipoRetencion2, MI.TipoRetencion3, MI.OrigenModulo, MI.OrigenModuloID, MI.OrigenConcepto, MI.OrigenDeducible, 
                      MI.OrigenFecha, MI.SubFolio, MI.ContUso, MI.ContUso2, MI.ContUso3, MI.ClavePresupuestal, MI.ClavePresupuestalImpuesto1, MI.DescuentoGlobal, MI.ImporteBruto, 
                      /*
                      D.ID AS Din_ID, D.Mov AS Din_Mov, D.MovID AS Din_MovID, D.Concepto AS Din_Concepto, D.Moneda AS Din_Moneda, D.TipoCambio AS Din_TipoCambio, 
                      D.TipoCambioDestino AS Din_TipoCambioDestino, D.ContactoTipo AS Din_ContactoTipo, D.Contacto AS Din_Contacto, ISNULL(D.Importe * D.IVAFiscal, 0) AS 'Din_IVA', 
                      */
                      D.Empresa AS Din_Empresa, D.ID AS Din_ID, D.Mov AS Din_Mov, D.MovID AS Din_MovID, D.Concepto AS Din_Concepto, D.Moneda AS Din_Moneda, D.TipoCambio AS Din_TipoCambio, 
                      D.TipoCambioDestino AS Din_TipoCambioDestino, D.ContactoTipo AS Din_ContactoTipo, D.Contacto AS Din_Contacto, ISNULL(D.Importe * D.IVAFiscal, 0) AS 'Din_IVA', 
                      D.FechaEmision AS Din_FechaEmision, D.Conciliado AS Din_Conciliado, D.Estatus AS Din_Estatus,
                      
                      
                      DC.Coms_ID, DC.Coms_Mov, DC.Coms_MovID, DC.Coms_Moneda, DC.Coms_Referencia, DC.Coms_FacturaCompra, DC.Coms_FechaFactura, DC.Coms_ImpTotal, 
                      DC.Coms_IEPS_20, DC.Coms_IEPS_25, DC.Coms_IEPS_26_5, DC.Coms_IEPS_30, DC.Coms_IEPS_50, DC.Coms_IEPS_53, DC.Coms_IVA_11, DC.Coms_IVA_16, 
                      DC.Coms_Base_10_11, DC.Coms_BASE_15_16, DC.Coms_BASE_Cero, DC.Coms_ZonaImp, DC.Coms_TipoCambio, DC.Coms_Proveedor, DC.Coms_Prov_Nombre, 
                      DC.Coms_Prov_Tipo, DC.Coms_Prov_Cuenta, DC.Coms_Prov_CuentaRetencion, DC.Coms_Prov_Cuenta2, DC.Coms_Prov_Cuenta3, DC.Coms_Prov_Cuenta4, 
                      DC.Coms_Prov_RFC, DC.Coms_Prov_ZonaImp, DC.NC_ImporteD, DC.NC_ImporteIVA, DC.NC_Redondeo, DCGD.GD_ID, DCGD.GD_Concepto, DCGD.GD_Acreedor, 
                      DCGD.GD_AcreedorNombre, DCGD.GD_AcreedorRFC, DCGD.GD_AcreedorTipo, DCGD.GD_Importe, DCGD.GD_Moneda, DCGD.GD_TipoCambio, DCGD.GD_Prorrateo, 
                      DCGD.GD_FechaEmision, DCGD.GD_Condicion, DCGD.GD_Referencia, DCGD.GD_Retencion, DCGD.GD_Retencion2, DCGD.GD_Retencion3, DCGD.GD_Impuestos, 
                      DG.Gas_ID, DG.Gas_Mov, DG.Gas_MovID, DG.Gas_Moneda, DG.Gas_Importe, DG.Gas_Impuestos, DG.Gas_Retencion, DG.Gas_RetencionISR, DG.Gas_RetencionIVA,
                       DG.Gas_Retencion3, DG.Gas_Concepto, DG.Gas_TipoImpuesto1, DG.Gas_IVA_11, DG.Gas_IVA_16, DG.Gas_TipoCambio, DG.Gas_Acreedor, DG.Gas_Acre_Nombre, 
                      DG.Gas_Acre_Tipo, DG.Gas_Acre_Cuenta, DG.Gas_Acre_CuentaRetencion, DG.Gas_Acre_Cuenta2, DG.Gas_Acre_Cuenta3, DG.Gas_Acre_Cuenta4, DG.Gas_Acre_RFC, 
                      DG.Gas_Acre_ZonaImp, DG.Gas_OrigenTipo, DG.Gas_NC_ImporteD, DG.Gas_NC_Redondeo, DG.Gas_TipoOperacion, DG.Gas_Fletes, 
                      /*
                      DV.Vtas_ID, DV.Vtas_Mov, 
                      DV.Vtas_MovID, DV.Vtas_Moneda, DV.Vtas_TipoCambio, DV.Vtas_Referencia, DV.Vtas_Retencion, DV.Vtas_TipoImpuesto1, DV.Vtas_Impuesto1, DV.Vtas_Importe1, 
                      DV.Vtas_TipoImpuesto2, DV.Vtas_Impuesto2, DV.Vtas_Importe2, DV.Vtas_TipoImpuesto3, DV.Vtas_Impuesto3, DV.Vtas_Importe3, DV.Vtas_TipoImpuesto5, 
                      DV.Vtas_Impuesto5, DV.Vtas_Importe5, 
                      */
                      DV.Vtas_ID, DV.Vtas_Mov, DV.Vtas_MovID, DV.Vtas_Moneda, DV.Vtas_TipoCambio, DV.Vtas_Referencia, DV.Vtas_Cliente,
                      DV.Vtas_ClienteNombre, DV.Vtas_ClienteRFC, DV.Vtas_ClienteTipo, 
                      DV.Vtas_Retencion, DV.Vtas_TipoImpuesto1, DV.Vtas_Impuesto1, DV.Vtas_Importe1, 
                      DV.Vtas_TipoImpuesto2, DV.Vtas_Impuesto2, DV.Vtas_Importe2, DV.Vtas_TipoImpuesto3, DV.Vtas_Impuesto3, DV.Vtas_Importe3, DV.Vtas_TipoImpuesto5, 
                      DV.Vtas_Impuesto5, DV.Vtas_Importe5, DV.Vtas_AgenteNombre, DV.Vtas_CostoFactura, DV.Vtas_ImporteTotal,
                      
                      DCXC.Cxc_ID, DCXC.Cxc_Mov, DCXC.Cxc_MovID, DCXC.Cxc_Cliente, DCXC.Cxc_Moneda, DCXC.Cxc_TipoCambio, DCXC.Cxc_ClienteMoneda, 
                      DCXC.Cxc_ClienteTipoCambio, DCXC.Cxc_Concepto, DCXC.Cxc_Referencia, DCXC.Cxc_Retencion, DCXC.Cxc_TipoImpuesto1, DCXC.Cxc_Impuesto1, 
                      DCXC.Cxc_Importe1, DCXC.Cxc_TipoImpuesto2, DCXC.Cxc_Impuesto2, DCXC.Cxc_Importe2, DCXC.Cxc_TipoImpuesto3, DCXC.Cxc_Impuesto3, DCXC.Cxc_Importe3, 
                      DCXC.Cxc_TipoImpuesto5, DCXC.Cxc_Impuesto5, DCXC.Cxc_Importe5, 
                      DCXC.Cxc_ClienteNombre, DCXC.Cxc_ClienteRFC, DCXC.Cxc_ClienteTipo,
                      
                      DCXP.Cxp_ID, DCXP.Cxp_Mov, DCXP.Cxp_MovID, DCXP.Cxp_Moneda, DCXP.Cxp_Proveedor, DCXP.Cxp_ProveedorRFC, DCXP.Cxp_ProveedorTipo, DCXP.Cxp_ProveedorNombre,
                      DCXP.Cxp_TipoCambio, DCXP.Cxp_Referencia, DCXP.Cxp_Retencion, DCXP.Cxp_Origen, DCXP.Cxp_OrigenID, DCXP.Cxp_ProveedorMoneda, 
                      DCXP.Cxp_ProveedorTipoCambio, DCXP.Cxp_TipoImpuesto1, DCXP.Cxp_Impuesto1, DCXP.Cxp_Importe1, DCXP.Cxp_TipoImpuesto2, DCXP.Cxp_Impuesto2, 
                      DCXP.Cxp_Importe2, DCXP.Cxp_TipoImpuesto3, DCXP.Cxp_Impuesto3, DCXP.Cxp_Importe3, DCXP.Cxp_TipoImpuesto5, DCXP.Cxp_Impuesto5, 
                      DCXP.Cxp_Importe5, DCXP.CXP_Concepto,
                      
                      DV.Vtas_BASE_0, DV.Vtas_BASE_C, DV.Vtas_BASE_C15, DV.Vtas_BASE_F, DV.Vtas_Condicion, DV.Vtas_IVA_C, DV.Vtas_IVA_F
FROM         dbo.MovImpuesto AS MI 
		INNER JOIN dbo.Dinero AS D ON MI.Modulo = 'DIN' AND MI.ModuloID = D.ID 
		INNER JOIN dbo.MovTipo AS MT ON D.Mov = MT.Mov AND MT.Clave IN ('DIN.DE', 'DIN.D', 'DIN.CH', 'DIN.CHE') 
        LEFT OUTER JOIN dbo.vDineroCompra AS DC ON MI.OrigenModulo = 'COMS' AND MI.OrigenModuloID = DC.Coms_ID AND LEFT(ISNULL(MI.OrigenConcepto,''), 4) NOT IN ('(GD)', '[GD]') 
        LEFT OUTER JOIN dbo.vCompraGastosDiversos AS DCGD ON MI.OrigenModulo = 'COMS' AND MI.OrigenModuloID = DCGD.GD_ID AND LEFT(MI.OrigenConcepto, 4) IN ('(GD)', '[GD]') AND MI.OrigenConcepto = DCGD.GD_Concepto
        LEFT OUTER JOIN dbo.vDineroGasto AS DG ON MI.OrigenModulo = 'GAS' AND MI.OrigenModuloID = DG.Gas_ID
        LEFT OUTER JOIN dbo.vDineroVenta AS DV ON MI.OrigenModulo = 'VTAS' AND MI.OrigenModuloID = DV.Vtas_ID
        LEFT OUTER JOIN dbo.vDineroCXC AS DCXC ON MI.OrigenModulo = 'CXC' AND MI.OrigenModuloID = DCXC.Cxc_ID
        LEFT OUTER JOIN dbo.vDineroCXP AS DCXP ON MI.OrigenModulo = 'CXP' AND MI.OrigenModuloID = DCXP.Cxp_ID
WHERE     (MI.Modulo = 'DIN') AND (D.Estatus IN ('CONCLUIDO','CANCELADO'))

GO


