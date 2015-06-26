//css_import uninstall

using System;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
using System.Diagnostics;

namespace WindowsApplication
{
	public static class Program
	{
		private static string getProjectName(DirectoryInfo directory)
		{
			bool hasMap = false;
			bool hasMain = false;
			string projectName = null;

			string extension;

			foreach (FileInfo file in directory.GetFiles())
			{
				if (file.Name == "main.j")
				{
					hasMain = true;

					if (hasMap)
					{
						return projectName;
					}
				} // if
				else
				{
					extension = file.Name.Substring(file.Name.Length - 4, 4);

					if (extension == ".w3m" || extension == ".w3x")
					{
						hasMap = true;
						projectName = file.Name;

						if (hasMain)
						{
							return projectName;
						}
					} // if
				}
			} // foreach

			return null;
		}

		private static Tuple<DirectoryInfo, string> getProjectDirectory()
		{
			DirectoryInfo directory = new DirectoryInfo(Directory.GetCurrentDirectory());

			string projectName = null;

			while (directory != null && (projectName = getProjectName(directory)) == null)
			{
				directory = directory.Parent;
			} // while

			return new Tuple<DirectoryInfo, string>(directory, projectName);
		}

		private static bool question(string questionStr)
		{
			char key = '\0';

			Console.Write(questionStr + " <Y/N> ");

			while (key != 'Y' && key != 'N' && key != 'y' && key != 'n')
			{
				key = Console.ReadKey().KeyChar;
				Console.Write("\b \b");
			}

			Console.WriteLine();

			return key == 'Y' || key == 'y';
		}

		public static void Main(string[] args)
		{
			bool redirected = CreateConsole.Loader.IsOutputRedirected();

			if (!redirected)
			{
				CreateConsole.Loader.create();
			} // if

			var project = getProjectDirectory();
			var rootLength = project.Item1.FullName.Length + 1;
			var relativePath = Directory.GetCurrentDirectory().Remove(0, rootLength);

			Console.WriteLine(project.Item1.ToString());
			Console.WriteLine(project.Item2.ToString());
			
			Console.WriteLine(relativePath);

			Console.WriteLine(Convert.ToInt32(Process.GetCurrentProcess().Id.ToString()));

			if (question("Install Optional Libraries?"))
			{
			
			} // if

			var process = new Process();
			process.StartInfo.CreateNoWindow = true;
			process.StartInfo.Arguments = "wtf.cs " + Process.GetCurrentProcess().Id.ToString();
			process.StartInfo.FileName = "csws";
			process.StartInfo.WorkingDirectory = Directory.GetCurrentDirectory();
			process.StartInfo.UseShellExecute = false;
			process.Start();
			process.WaitForExit();

			process.Start();
			process.WaitForExit();
			process.Start();
			process.WaitForExit();

			if (!redirected)
			{
				Console.Write("Press Any Key To Exit");
				Console.ReadKey();
			} // if
		}
	}
}