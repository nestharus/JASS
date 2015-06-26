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
		public enum FileType : uint
		{
			FILE_TYPE_UNKNOWN = 0x0000,
			FILE_TYPE_DISK = 0x0001,
			FILE_TYPE_CHAR = 0x0002,
			FILE_TYPE_PIPE = 0x0003,
			FILE_TYPE_REMOTE = 0x8000,
		}

		public enum STDHandle : uint
		{
			STD_INPUT_HANDLE = unchecked((uint)-10),
			STD_OUTPUT_HANDLE = unchecked((uint)-11),
			STD_ERROR_HANDLE = unchecked((uint)-12),
		}
		
		[DllImport("Kernel32.dll")]
		static public extern FileType GetFileType(IntPtr hFile);

		[DllImport("kernel32", SetLastError = true)]
		public static extern bool AttachConsole(int dwProcessId);

		[DllImport("user32.dll")]
		private static extern IntPtr GetForegroundWindow();

		[DllImport("user32.dll", SetLastError = true)]
		private static extern uint GetWindowThreadProcessId(IntPtr hWnd, out int lpdwProcessId);

		static public bool IsOutputRedirected()
		{
			IntPtr hOutput = GetStdHandle(unchecked((int)STDHandle.STD_OUTPUT_HANDLE));
			FileType fileType = (FileType)GetFileType(hOutput);
			if (fileType == FileType.FILE_TYPE_CHAR)
				return false;
			return true;
		}

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

		private static void init()
		{
			IntPtr stdHandle = GetStdHandle(STD_OUTPUT_HANDLE);
			SafeFileHandle safeFileHandle = new SafeFileHandle(stdHandle, true);
			FileStream fileStream = new FileStream(safeFileHandle, FileAccess.Write);
			Encoding encoding = System.Text.Encoding.GetEncoding(MY_CODE_PAGE);
			StreamWriter standardOutput = new StreamWriter(fileStream, encoding);
			standardOutput.AutoFlush = true;
			Console.SetOut(standardOutput);
		} // init

		public static void attach(int processId)
		{
			AttachConsole(processId);
			init();
        }

		public static void create()
		{
			AllocConsole();
			init();
		}
	}
}