using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Xml;
using System.Data.SqlClient;
using System.Data;
using Administracion.Servicio;

namespace WebService2.ConsultaExistencias
{
    /// <summary>
    /// Descripción breve de ConsultaExistencias
    /// </summary>
    [WebService(Namespace = "http://erp02.intelisiscloud.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // Para permitir que se llame a este servicio web desde un script, usando ASP.NET AJAX, quite la marca de comentario de la línea siguiente. 
    // [System.Web.Script.Services.ScriptService]
    public class ConsultaExistencias : System.Web.Services.WebService
    {

        [WebMethod]
        public XmlDocument ConsultarExistencias(string Empresa, string ClaveFabricante, string Fabricante, bool Recurrente)
        {
            XmlDocument xmldoc = new XmlDocument();
            string ruta = Server.MapPath("~/WFG.ini").ToString();

            try
            {
                Servicio.Global con = new Servicio.Global();

                SqlConnection cn = new SqlConnection(con.conectionstring(ruta));
                SqlCommand cmd = new SqlCommand();

                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Connection = cn;

                cmd.CommandText = "spWebServiceExistencias";
                cmd.Parameters.Add("@Empresa", SqlDbType.VarChar).Value = Empresa;
                cmd.Parameters.Add("@ClaveFabricante", SqlDbType.VarChar).Value = ClaveFabricante;
                cmd.Parameters.Add("@Fabricante", SqlDbType.VarChar).Value = Fabricante;
                cmd.Parameters.Add("@Recurrente", SqlDbType.Bit).Value = Recurrente;

                cn.Open();

                XmlReader p = cmd.ExecuteXmlReader();
                XmlDocument CExistencias = new XmlDocument();

                CExistencias.Load(p);

                cn.Close();
                return CExistencias;
            }catch (XmlException ex)
            {
                xmldoc.LoadXml("<Intelisis Sistema= 'Intelisis' Contenido= 'Estado de cuenta' Referencia= 'WebService' SubReferencia= 'Cliente' Version= '1.0' >vacio</Intelisis >");
                return xmldoc;
            }
        }
    }
}
