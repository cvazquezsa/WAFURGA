using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;

using System.Runtime.InteropServices;
using System.IO;
using System.Configuration;




namespace WebService2.Jornada
{

    /// <summary>
    /// Clase encargada de leer archivo .ini
    /// </summary>
    public class Util
    {
        /// <summary>
        /// Metodo que lee una un valor del archivo .ini
        /// </summary>
        /// <param name="section">Nombre de la seccion a la que se buscara un valor</param>
        /// <param name="key">Nombre del valor que se leera</param>
        /// <param name="def">En caso de Error Muestra esta cadena</param>
        /// <param name="retVal">Objeto tipo Cadena de texto que regresa el valor buscado</param>
        /// <param name="size">Entero que representa el tamaño del valor que se regresara</param>
        /// <param name="filePath">Ubicacion del archivo en el que se buscara el valor</param>
        /// <returns></returns>
        [DllImport("kernel32")]
        public static extern int GetPrivateProfileString(string section,string key, string def,StringBuilder retVal,int size, string filePath);

        /// <summary>
        /// Metodo que lee una un valor del archivo .ini
        /// </summary>
        /// <param name="section">Nombre de la seccion a la que se buscara un valor</param>
        /// <param name="key">Nombre del valor que se leera</param>
        /// <param name="val">Valor que se guardara en el archivo .ini</param>
        /// <param name="filePath">Ubicacion del archivo en el que se buscara el valor</param>
        /// <returns></returns>
        [DllImport("kernel32")]
        public static extern long WritePrivateProfileString(string section,string key, string val, string filePath);
    }

    /// <summary>
    /// Clase que tendra los metodos para leer el ini con la informacion de la base de datos
    /// </summary>
    class clsLeerIni
    {
        /// <summary>
        /// \\SYSCONFGJRT.ini
        /// </summary>
        public string Path = "WFG.ini";

        /// <summary>
        /// CONFIGOPTIONS
        /// </summary>
        public const string constSeccion = "E001";

        /// <summary>
        /// Nombre de la cadena de conexion en el archivo app.config
        /// </summary>
        private const string nameStringConnection = "Administracion.Properties.Settings.AdminConnectionString";

        /// <summary>
        /// Metodo que leera solo un valor
        /// </summary>
        /// <param name="seccion">Seccion que se leera</param>
        /// <param name="key">Nombre del la llave que tiene asignado el valor</param>
        /// <param name="nomFile">Nombre del archivo .ini</param>
        /// <returns>Regresa el valor obtenido o el mensaje de ERROR</returns>
        /// 

        public string leerCompra(string archivo, string variable, string Etiqueta)
        {
            string x = "";

            //Leer Valores
            StringBuilder cantidad = new StringBuilder(500, 500);
            string valor = "";
            Path = archivo;

            if (Etiqueta == null && Etiqueta.Trim() == "")
                Etiqueta = "Base";

            if (File.Exists(archivo))
            {
                Util.GetPrivateProfileString(Etiqueta,//Etiqueta buscada
                                             variable,
                                             "",
                                             cantidad,
                                             cantidad.Capacity,
                                             archivo);
                x = cantidad.ToString();
            }
            else
            {
                x = "No se puede encontrar archivo " + archivo;
            }

            //Modificar Valores

            // Util.WritePrivateProfileString("Base", "Servidor", "150", archivo);
            return x;
        }
        public string Encriptar(string _cadenaAencriptar)
        {
            try
            {
                string result = string.Empty;
                byte[] encryted = System.Text.Encoding.Unicode.GetBytes(_cadenaAencriptar);
                result = Convert.ToBase64String(encryted);

                return result.Substring(result.Length - 1, 1) + result.Substring(1, result.Length - 2) + result.Substring(0, 1);
            }
            catch (Exception e)
            {
                return "Formato invalido";
            }
        }

        /// Esta función desencripta la cadena que le envíamos en el parámentro de entrada.
        public string DesEncriptar(string _cadenaAdesencriptar)
        {
            try
            {
                string result = string.Empty;
                byte[] decryted = Convert.FromBase64String(_cadenaAdesencriptar.Substring(_cadenaAdesencriptar.Length - 1, 1) + _cadenaAdesencriptar.Substring(1, _cadenaAdesencriptar.Length - 2) + _cadenaAdesencriptar.Substring(0, 1));
                //result = System.Text.Encoding.Unicode.GetString(decryted, 0, decryted.ToArray().Length);
                result = System.Text.Encoding.Unicode.GetString(decryted);
                return result;
            }
            catch (Exception e)
            {
                return "Formato invalido";
            }
        }
        public string leer(string archivo, string variable)
        {
            string x = "";

            //Leer Valores
            StringBuilder cantidad = new StringBuilder(500, 500);
            string valor = "";
            Path = archivo;

            if (File.Exists(archivo))
            {
                Util.GetPrivateProfileString("E001",
                                             variable,
                                             "",
                                             cantidad,
                                             cantidad.Capacity,
                                             archivo);
                x = cantidad.ToString();
            }
            else
            {
                x = "No se puede encontrar archivo " + archivo;
            }

            //Modificar Valores

            // Util.WritePrivateProfileString("Base", "Servidor", "150", archivo);
            return x;
        }


        public string leers(string archivo, string variable)
        {
            string x = "";

            //Leer Valores
            StringBuilder cantidad = new StringBuilder();
            string valor = "";
            Path = archivo;

            if (File.Exists(archivo))
            {
                Util.GetPrivateProfileString("E001",
                                             variable,
                                             "",
                                             cantidad,
                                             cantidad.MaxCapacity,
                                             archivo);
                x = cantidad.ToString();
            }
            else
            {
                x = "No se puede encontrar archivo " + archivo;
            }

            //Modificar Valores

            // Util.WritePrivateProfileString("Base", "Servidor", "150", archivo);
            return x;
        }


    }
}
