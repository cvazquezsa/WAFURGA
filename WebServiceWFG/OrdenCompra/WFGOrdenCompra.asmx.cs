using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Data.SqlClient;
using System.Data;
using System.Xml;
using WebService2;
using System.Globalization;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using Administracion;

namespace WebService2
{
    /// <summary>
    /// Descripción breve de Service1
    /// </summary>
    [WebService(Namespace = "http://erp02.intelisiscloud.com")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // Para permitir que se llame a este servicio Web desde un script, usando ASP.NET AJAX, quite la marca de comentario de la línea siguiente. 
    // [System.Web.Script.Services.ScriptService]
    public class Service1 : System.Web.Services.WebService
    {
        
        SqlConnection cn = new SqlConnection("Data Source = .; Initial Catalog = datos; Integrated Security = true;");
        SqlCommand cmd = new SqlCommand();
        Global con = new Global();
        clsLeerIni ar = new clsLeerIni();
        string c;

        [WebMethod]
        public string OrdenCompraRollback(string archivo)
        {
            XmlDocument doc = new XmlDocument();
            string ruta = Server.MapPath("~/WFG.ini").ToString();

            doc.LoadXml(archivo);
            string comando = "BEGIN TRANSACTION DECLARE  @Resultado	varchar(max),@Archivo varchar(max),";
            comando = comando + "@Usuario varchar(10),@Contrasena  varchar(32),@Ok int,@ID int,@OkRef varchar(255) ";
            comando = comando + "SELECT @Usuario = 'SR', @Contrasena = '9e351e3b5e6c249b698063e4417a81d9',";
            comando = comando + "@Archivo = '" + archivo;
            comando = comando + "' EXEC spIntelisisService @Usuario,@Contrasena,@Archivo, @Resultado OUTPUT, @Ok OUTPUT, @OkRef OUTPUT, 1, 0, @ID OUTPUT SELECT @Resultado ROLLBACK";

            SqlConnection cn = con.cn(ruta);
            SqlCommand cmd = new SqlCommand(comando, cn);

            cmd.Connection = cn;
            cn.Open();

            c = cmd.ExecuteScalar().ToString();

            cn.Close();
            return c;

        }


        [WebMethod]
        public string OrdenCompra(string archivo)
        {
            try
            {
                XmlDocument doc = new XmlDocument();
                string ruta = Server.MapPath("~/WFG.ini").ToString();
                string Empresa = null;

                doc.LoadXml(archivo);

                ////////////////////////// Leer por etiqueta y atrributo
                XmlNodeList elemList = doc.GetElementsByTagName("Compra");
                for (int i = 0; i < elemList.Count; i++)
                {
                    Empresa = elemList[i].Attributes["Empresa"].Value;

                }


                //////////////////////////////


                string comando = "BEGIN TRANSACTION DECLARE  @Resultado	varchar(max),@Archivo varchar(max),";
                comando = comando + "@Usuario varchar(10),@Contrasena  varchar(32),@Ok int,@ID int,@OkRef varchar(255) ";
                comando = comando + "SELECT @Usuario = 'SR', @Contrasena = '9e351e3b5e6c249b698063e4417a81d9',";
                comando = comando + "@Archivo = '" + archivo;
                comando = comando + "' EXEC spIntelisisService @Usuario,@Contrasena,@Archivo, @Resultado OUTPUT, @Ok OUTPUT, @OkRef OUTPUT, 1, 0, @ID OUTPUT SELECT @Resultado COMMIT";

                SqlConnection cn = con.CnCompra(ruta, Empresa);
                SqlCommand cmd = new SqlCommand(comando, cn);

                cmd.Connection = cn;
                cn.Open();

                c = cmd.ExecuteScalar().ToString();

                cn.Close();
                return c;
             }
           catch(SqlException ex)
            {
                return ex.Message;
            }
           catch (Exception ex)
            {

                return ex.Message;
            }
        }
        

        //[WebMethod]
        //public int insertados()
        //{
        //    int retorna = 0;

        //    try
        //    {
        //        XmlDocument xmldoc = new XmlDocument();
        //        xmldoc.Load("C:/Users/ssantana/Desktop/WebService2/WebService2/cargadedatos.xml");
        //        XmlNodeList factura = xmldoc.GetElementsByTagName("factura");
        //        XmlNodeList lista = ((XmlElement)factura[0]).GetElementsByTagName("detalle");
        //        foreach (XmlElement nodo in lista)
        //        {
        //            XmlNodeList exito = nodo.GetElementsByTagName("Exito");
        //            try
        //            {
        //                for (int i = 0; i < exito.Count; i++)
        //                {
        //                    string valor = exito[i].InnerText;
        //                    if (valor == "insertado")
        //                    {
        //                        retorna = retorna + 1;
        //                    }
        //                }
        //            }
        //            catch (Exception ex)
        //            {
        //                throw ex;
        //            }
        //        }
        //        return retorna;
        //    }
        //    catch (Exception exa)
        //    {
        //        throw exa;
        //    }
        //}

        //[WebMethod]
        //public int erroneos()
        //{
        //    int retorna = 0;

        //    try
        //    {
        //        XmlDocument xmldoc = new XmlDocument();
        //        xmldoc.Load("E:/Normas y estandares de calidad/UnidadIV/Tienda_Arreglada/ProyectoCompleto_Bookieshop/bookie2013/cargadedatos.xml");
        //        XmlNodeList factura = xmldoc.GetElementsByTagName("factura");
        //        XmlNodeList lista = ((XmlElement)factura[0]).GetElementsByTagName("detalle");
        //        foreach (XmlElement nodo in lista)
        //        {
        //            XmlNodeList exito = nodo.GetElementsByTagName("Exito");
        //            try
        //            {
        //                for (int i = 0; i < exito.Count; i++)
        //                {
        //                    string valor = exito[i].InnerText;
        //                    if (valor == "error")
        //                    {
        //                        retorna = retorna + 1;
        //                    }
        //                }
        //            }
        //            catch (Exception ex)
        //            {
        //                throw ex;
        //            }
        //        }
        //        return retorna;

        //    }
        //    catch (Exception exa)
        //    {
        //        throw exa;
        //    }
        //}


        //[WebMethod]
        //public void Proce_insertar(string texto, int insertados)
        //{
        //    cn.Open();
        //    cmd.Connection = cn;
        //    cmd.CommandText = "proced_insertar";
        //    cmd.CommandType = CommandType.StoredProcedure;
        //    cmd.Parameters.Add("@estado", SqlDbType.VarChar).Value = texto;
        //    cmd.Parameters.Add("@cantidad", SqlDbType.Int).Value = insertados;
        //    cmd.ExecuteNonQuery();
        //}

        //[WebMethod]
        //public void Proce_erroneos(string textos2,int erroneos)
        //{
        //    //cn.Open();
        //    //cmd.Connection = cn;
        //    //cmd.CommandText = "proced_erroneos";
        //    //cmd.CommandType = CommandType.StoredProcedure;
        //    //cmd.Parameters.Add("@estado", SqlDbType.VarChar).Value = textos2;
        //    //cmd.Parameters.Add("@cantidad", SqlDbType.Int).Value = erroneos;
        //    //cmd.ExecuteNonQuery();
           
        //}

    }
}