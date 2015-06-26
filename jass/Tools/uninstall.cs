using System;  
using System.Windows.Forms;  
using System.Text;  
using System.IO;  
using System.Runtime.InteropServices;  
using Microsoft.Win32.SafeHandles;  
 
namespace CreateConsole
{  
    public static class Loader  
    {  
        [DllImport("kernel32.dll",  
            EntryPoint = "GetStdHandle",  
            SetLastError = true,  
            CharSet = CharSet.Auto,  
            CallingConvention = CallingConvention.StdCall)]  
        private static extern IntPtr GetStdHandle(int nStdHandle);  
        [DllImport("kernel32.dll",  
            EntryPoint = "AllocConsole",  
            SetLastError = true,  
            CharSet = CharSet.Auto,  
            CallingConvention = CallingConvention.StdCall)]  
        private static extern int AllocConsole();  
        private const int STD_OUTPUT_HANDLE = -11;  
        private const int MY_CODE_PAGE = 437;  
		
		public static StreamWriter create()
		{
			AllocConsole();  
            IntPtr stdHandle=GetStdHandle(STD_OUTPUT_HANDLE);  
            SafeFileHandle safeFileHandle = new SafeFileHandle(stdHandle, true);  
            FileStream fileStream = new FileStream(safeFileHandle, FileAccess.Write);  
            Encoding encoding = System.Text.Encoding.GetEncoding(MY_CODE_PAGE);  
            StreamWriter standardOutput = new StreamWriter(fileStream, encoding);
            standardOutput.AutoFlush = true;
			
			return standardOutput;
		}
		
		public static void use(StreamWriter standardOutput)
		{
			Console.SetOut(standardOutput);  
		}
    }  
} 