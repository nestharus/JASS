//css_import test2;

using System;  
using System.Windows.Forms;  
using System.Text;  
using System.IO;  
using System.Runtime.InteropServices;  
using Microsoft.Win32.SafeHandles;  
 
namespace WindowsApplication  
{  
    public static class Program  
    {  
        public static void Main(string[] args)  
        {  
            CreateConsole.Loader.use(CreateConsole.Loader.create());
			
            Console.WriteLine("Press Any Key To Exit");
			Console.ReadKey();
        }  
    }  
} 