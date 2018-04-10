using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using Administracion.Servicio;
namespace WebService2.Servicio
{
    
    public class Global : System.Web.HttpApplication
    {
        
        clsLeerIni ar = new clsLeerIni();
        public string conectionstringvalores(string servidor, string bd, string usuarios, string passwords)
        {

            string connectionString;
            connectionString = "Server = " + servidor + "; Database = " + bd + "; User Id = " + usuarios + ";Password = " + passwords + ";";
            return connectionString;
        }
        public string conectionstring(string ruta)
        {
            
            string servidor = ar.leer(ruta, "Servidor");
            string bd = ar.leer(ruta, "BaseDatos");
            string usuarios = ar.leer(ruta, "Usuario");
            string passwords = ar.DesEncriptar(ar.leer(ruta, "contrasena"));
            string connectionString;
            connectionString = "Server = " + servidor + "; Database = " + bd + "; User Id = " + usuarios + ";Password = " + passwords + ";";
            return connectionString;
        }

        public SqlConnection cn(string ruta)
        {
            SqlConnection cn = new SqlConnection(conectionstring(ruta));
            return cn;
        }
        public SqlCommand conexion(string comando,string ruta)
        {
            SqlConnection cn = new SqlConnection(conectionstring(ruta));
            SqlCommand cmd = new SqlCommand(comando, cn);
            SqlDataAdapter ad = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            cn.Open();
            return cmd;
        }

        //////////////////////////////////////////////////////////////////////////////////////////
        
        protected void Application_Start(object sender, EventArgs e)
        {

        }

        protected void Session_Start(object sender, EventArgs e)
        {

        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {

        }

        protected void Application_AuthenticateRequest(object sender, EventArgs e)
        {

        }

        protected void Application_Error(object sender, EventArgs e)
        {

        }

        protected void Session_End(object sender, EventArgs e)
        {

        }

        protected void Application_End(object sender, EventArgs e)
        {

        }
    }
}