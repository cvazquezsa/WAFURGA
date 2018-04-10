using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;
namespace WebService2.Jornada
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
        public SqlCommand conexion(string comando, string ruta)
        {
            SqlConnection cn = new SqlConnection(conectionstring(ruta));
            SqlCommand cmd = new SqlCommand(comando, cn);
            SqlDataAdapter ad = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            cn.Open();
            return cmd;
        }

        //////////////////////////////////// C O N E X I O N E S  O R D E N  D E  C O M P R A   
        public string ConectionstringCompra(string ruta, string Etiqueta)
        {
            string servidor = ar.leerCompra(ruta, "Servidor", Etiqueta);
            string bd = ar.leerCompra(ruta, "BaseDatos", Etiqueta);
            string usuarios = ar.leerCompra(ruta, "Usuario", Etiqueta);
            string passwords = ar.DesEncriptar(ar.leerCompra(ruta, "contrasena", Etiqueta));
            string connectionString;
            connectionString = "Server = " + servidor + "; Database = " + bd + "; User Id = " + usuarios + ";Password = " + passwords + ";";
            return connectionString;
        }

        public SqlConnection CnCompra(string ruta, string Etiqueta)//Etiqueta para la busqueda en .ini
        {
            SqlConnection cn = new SqlConnection(ConectionstringCompra(ruta, Etiqueta));
            return cn;
        }
        //public SqlCommand ConexionCompra(string comando, string ruta)
        //{
        //    SqlConnection cn = new SqlConnection(ConectionstringCompra(ruta,null));
        //    SqlCommand cmd = new SqlCommand(comando, cn);
        //    SqlDataAdapter ad = new SqlDataAdapter(cmd);
        //    DataTable dt = new DataTable();
        //    cn.Open();
        //    return cmd;
        //}

        //////////////////////////////////////////////////////////////////////////////////////////



        //////////////////////////////////// C O N E X I O N E S  O R D E N  D E  C O M P R A   
        public string ConectionstringJornadas(string ruta, string Etiqueta)
        {
            string servidor = ar.leerCompra(ruta, "Servidor", Etiqueta);
            string bd = ar.leerCompra(ruta, "BaseDatos", Etiqueta);
            string usuarios = ar.leerCompra(ruta, "Usuario", Etiqueta);
            string passwords = ar.DesEncriptar(ar.leerCompra(ruta, "contrasena", Etiqueta));
            string connectionString;
            connectionString = "Server = " + servidor + "; Database = " + bd + "; User Id = " + usuarios + ";Password = " + passwords + ";";
            return connectionString;
        }

        public SqlConnection CnJornadas(string ruta, string Etiqueta)//Etiqueta para la busqueda en .ini
        {
            SqlConnection cn = new SqlConnection(ConectionstringJornadas(ruta, Etiqueta));
            return cn;
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