using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Xml;


namespace WebService2.Jornada
{
    /// <summary>
    /// Descripción breve de WFGJornada
    /// </summary>
    [WebService(Namespace = "http://erp02.intelisiscloud.com")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // Para permitir que se llame a este servicio web desde un script, usando ASP.NET AJAX, quite la marca de comentario de la línea siguiente. 
    // [System.Web.Script.Services.ScriptService]
    public class WFGJornada : System.Web.Services.WebService
    {
        SqlConnection cn = new SqlConnection("Data Source = .; Initial Catalog = datos; Integrated Security = true;");
        SqlCommand cmd = new SqlCommand();
        Global con = new Global();
        clsLeerIni ar = new clsLeerIni();
        string c;

       
        [WebMethod]
        public string Jornada(string archivo)
        {
            
            XmlDocument doc = new XmlDocument();
            string ruta = Server.MapPath("~/WFG.ini").ToString();
            string Empresa = null;

            doc.LoadXml(archivo);

            ////////////////////////// Leer por etiqueta y atrributo
            XmlNodeList elemList = doc.GetElementsByTagName("JornadaH");
            for (int i = 0; i < elemList.Count; i++)
            {
                Empresa = elemList[i].Attributes["Empresa"].Value;
                if (elemList[i].Attributes["Empresa"].Value != null)
                    break;
            }


            doc.LoadXml(archivo);
            string comando = "BEGIN TRANSACTION DECLARE  @Resultado	varchar(max),@Archivo varchar(max),";
            comando = comando + "@Usuario varchar(10),@Contrasena  varchar(32),@Ok int,@ID int,@OkRef varchar(255) ";
            comando = comando + "SELECT @Usuario = 'SR', @Contrasena = '9e351e3b5e6c249b698063e4417a81d9',";
            comando = comando + "@Archivo = '" + archivo;
            comando = comando + "' EXEC spIntelisisService @Usuario,@Contrasena,@Archivo, @Resultado OUTPUT, @Ok OUTPUT, @OkRef OUTPUT, 1, 0, @ID OUTPUT SELECT @Resultado COMMIT";

            //SqlConnection cn = con.cn(ruta);
            SqlConnection cn = con.CnCompra(ruta, Empresa);
            SqlCommand cmd = new SqlCommand(comando, cn);

            cmd.Connection = cn;
            cn.Open();

            c = cmd.ExecuteScalar().ToString();

            cn.Close();
            return c;

        }

    }
}
