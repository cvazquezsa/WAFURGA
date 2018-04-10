using Administracion.Servicio;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Xml;

namespace WebService2.Servicio
{
    /// <summary>
    /// Descripción breve de WebService1
    /// </summary>
    [WebService(Namespace = "http://erp02.intelisiscloud.com")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // Para permitir que se llame a este servicio web desde un script, usando ASP.NET AJAX, quite la marca de comentario de la línea siguiente. 
    // [System.Web.Script.Services.ScriptService]
    public class WebService1 : System.Web.Services.WebService
    {

        SqlConnection cn = new SqlConnection("Data Source = .; Initial Catalog = datos; Integrated Security = true;");
        SqlCommand cmd = new SqlCommand();
        Global con = new Global();
        clsLeerIni ar = new clsLeerIni();

        string c;
        [WebMethod]
        public string pr()
        {
            string x;

            string ruta = Server.MapPath("~/WFG.ini").ToString();
            SqlConnection cn = new SqlConnection(con.conectionstring(ruta));
            SqlCommand cmd = new SqlCommand("SELECT * FROM WebUsuario", cn);
            cn.Open();
            x = cmd.ExecuteScalar().ToString();


            return x;
        }


        [WebMethod]
        public XmlDocument EstadoCuenta(string cliente, string empresa, string tarjeta)
        {
            XmlDocument doc = new XmlDocument();
            string ruta = Server.MapPath("~/WFG.ini").ToString();

            try
            {

                SqlConnection cn = new SqlConnection(con.conectionstring(ruta));
                SqlCommand cmd = new SqlCommand();
                SqlCommand cmd2 = new SqlCommand();

                cmd.CommandType = CommandType.StoredProcedure;
                cmd2.CommandType = CommandType.StoredProcedure;
                cmd.Connection = cn;
                cmd2.Connection = cn;

                cmd.CommandText = "spWebServiceEstadoCuenta";
                cmd.Parameters.Add("@Cliente", SqlDbType.VarChar).Value = cliente;
                //cmd.Parameters.Add("@Personal", SqlDbType.VarChar).Value = men;
                cmd.Parameters.Add("@Empresa", SqlDbType.VarChar).Value = empresa;
                cmd.Parameters.Add("@Op", SqlDbType.VarChar).Value = "Encabezado";
                cmd.Parameters.Add("@tarjeta", SqlDbType.VarChar).Value = tarjeta;

                cmd2.CommandText = "spWebServiceEstadoCuenta";
                cmd2.Parameters.Add("@Cliente", SqlDbType.VarChar).Value = cliente;
                //cmd.Parameters.Add("@Personal", SqlDbType.VarChar).Value = men;
                cmd2.Parameters.Add("@Empresa", SqlDbType.VarChar).Value = empresa;
                cmd2.Parameters.Add("@Op", SqlDbType.VarChar).Value = "Detalle";
                cmd2.Parameters.Add("@tarjeta", SqlDbType.VarChar).Value = tarjeta;

                cn.Open();

                // SqlDataReader reader = cmd.ExecuteReader();
                //while (reader.Read())
                //{

                //    reader["emailnombre"].ToString();
                //}
                
                c = cmd.ExecuteScalar().ToString();

                XmlReader p = cmd2.ExecuteXmlReader();
                XmlDocument xl= new XmlDocument();
                xl.Load(p);

                


                doc.LoadXml("<Intelisis Sistema= 'Intelisis' Contenido= 'Estado de cuenta' Referencia= 'WebService' SubReferencia= 'Cliente' Version= '1.0' >"
                + c.Remove(c.Length - 2) + ">"
                + xl.OuterXml
                + "</Cliente>"
                + "</Intelisis >");


                //XmlElement root = doc.DocumentElement;

                // Add a new attribute.
                //root.SetAttribute("genre", "urn:samples", "novel");

                //string comando = "SELECT * FROM webusuario";
                //string c = Convert.ToString(con.conexion(comando).ExecuteScalar());
                //DataSet ds = new DataSet();
                //XmlDataSource leer = new XmlDataSource();
                //leer.DataFile = "ArchivoCompra2.xml";
                //leer.XPath = "Intelisis/Solicitud/Compra/CompraD";

                //GridView grid = new GridView();
                //grid.DataSource = leer;
                //grid.DataBind();
                //string x="a";
                cn.Close();
                return doc;
            }
            catch (XmlException ex)
            {

                
                doc.LoadXml("<Intelisis Sistema= 'Intelisis' Contenido= 'Estado de cuenta' Referencia= 'WebService' SubReferencia= 'Cliente' Version= '1.0' >vacio</Intelisis >");
                return doc;
            }
        }

        [WebMethod]
        public XmlDocument CreditoCte(string cliente, string Empresa, Double importe, string tarjeta)
        {

                string ruta = Server.MapPath("~/WFG.ini").ToString();

            


                SqlCommand cmd = new SqlCommand();
                SqlDataAdapter ad = new SqlDataAdapter(cmd);
                SqlConnection cn = con.cn(ruta);

                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@Cliente", SqlDbType.VarChar).Value = cliente;
                cmd.Parameters.Add("@importe", SqlDbType.Money).Value = importe;
                cmd.Parameters.Add("@Empresa", SqlDbType.VarChar).Value = Empresa;
                cmd.Parameters.Add("@Tarjeta", SqlDbType.VarChar).Value = tarjeta;
                //cmd.Parameters["@ID"].Value = customerID;
                cmd.CommandText = "spWebServiceCredito";
                cmd.Connection = cn;
                cn.Open();

            XmlReader p = cmd.ExecuteXmlReader();
            XmlDocument CVentas = new XmlDocument();

            CVentas.Load(p);
            cn.Close();

           
                //asignando valores de consulta a las variables u,c
                //            credito = Convert.ToString(con.conexion(comando).ExecuteScalar());
            
            return CVentas;
        }

        [WebMethod]
        public XmlDocument HistorialCredito (string Empresa,string Cliente, string LC)
        {
            XmlDocument XMLDoc = new XmlDocument();
            string ruta = Server.MapPath("~/WFG.ini").ToString();

            try
            {
                Servicio.Global con = new Servicio.Global();

                SqlConnection cn = new SqlConnection(con.conectionstring(ruta));
                SqlCommand cmd = new SqlCommand();

                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Connection = cn;

                cmd.CommandText = "spWFGWebServiceHistorialCredito";
                cmd.Parameters.Add("@Empresa", SqlDbType.VarChar).Value = Empresa;
                cmd.Parameters.Add("@Cliente", SqlDbType.VarChar).Value = Cliente;
                cmd.Parameters.Add("@LC", SqlDbType.VarChar).Value = LC;

                cn.Open();

                XmlReader p = cmd.ExecuteXmlReader();
                XmlDocument CHistCredito = new XmlDocument();

                CHistCredito.Load(p);
                cn.Close();
                return CHistCredito;
            }
            catch(XmlException ex)
            {
                XMLDoc.LoadXml("<Intelisis Sistema= 'Intelisis' Contenido= 'Estado de cuenta' Referencia= 'WebService' SubReferencia= 'Cliente' Version= '1.0' >vacio</Intelisis >");
                return XMLDoc;
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