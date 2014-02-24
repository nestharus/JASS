package compile.antlr;

import groovy.io.GroovyPrintWriter;
import groovy.lang.Binding;
import groovy.lang.GroovyShell;

import java.io.CharArrayWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Stack;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.Token;

import compile.antlr.AntlrLexer;

public class TranslateGrammar
{
	private static class Read
	{
		private final File        file;
		private InputStreamReader inputStreamReader = null;
		private ANTLRInputStream  input             = null;

		public boolean isOpen()
		{
			return inputStreamReader != null;
		}

		public ANTLRInputStream getInput()
		{
			return input;
		}

		private void close()
		{
			if (inputStreamReader != null)
			{
				try
				{
					inputStreamReader.close();
				}
				catch (Exception e)
				{

				}
				finally
				{
					inputStreamReader = null;
				}
			}

			input = null;
		}

		private void initializeInputStreamReader()
		{
			try
			{
				if (file != null && file.exists() && file.canRead() && file.isFile())
				{
					inputStreamReader = new FileReader(file);
				}
			}
			catch (Exception e)
			{
				System.err.println("Could Not Read File [" + file.getName() + "]");
				close();
			}
		}

		private void initializeANTLRInputStream()
		{
			if (inputStreamReader == null)
			{
				return;
			}

			try
			{
				input = new ANTLRInputStream(inputStreamReader);
			}
			catch (Exception e)
			{
				System.err.println("Could Not Read File [" + file.getName() + "]");
				close();
			}
		}

		public Read(final File file)
		{
			this.file = file;

			initializeInputStreamReader();
			initializeANTLRInputStream();
		}
	}

	private static File loadDirectory(final String directoryStr)
	{
		File directory = new File(directoryStr);

		if (!directory.mkdirs())
		{
			System.err.println("Could Not Create Directory [" + directory.getAbsolutePath() + "]");

			return null;
		}

		return directory;
	}

	private static File loadFile(final String filename)
	{
		File file = new File(filename);

		if (loadDirectory(file.getPath()) != null)
		{
			try
			{
				file.createNewFile();
			}
			catch (Exception e)
			{
				System.err.println("Could Not Create File [" + file.getName() + "]");

				file = null;
			}
		}
		else
		{
			file = null;
		}

		return file;
	}

	private static OutputStreamWriter loadOutputStreamWriter(final File file)
	{
		if (file == null)
		{
			return null;
		}

		OutputStreamWriter outputStreamWriter = null;

		try
		{
			outputStreamWriter = new FileWriter(file);
		}
		catch (Exception e)
		{
			System.err.println("Could Not Write To File [" + file.getName() + "]");
		}

		return outputStreamWriter;
	}

	private static List<Token> loadTokens(final File file, final Lexer lexer)
	{
		Read reader = new Read(filename);
		if (!reader.isOpen())
		{
			return null;
		}

		lexer.setInputStream(reader.getInput());
		CommonTokenStream tokenStream = new CommonTokenStream(lexer);
		tokenStream.fill();
		reader.close();

		return tokenStream.getTokens();
	}

	private static int getArgumentCount(final List<Token> tokens)
	{
		if (tokens.isEmpty())
		{
			return 0;
		}

		int count = 0;

		for (Token token : tokens)
		{
			if (token.getType() == AntlrLexer.ARGUMENT)
			{
				++count;
			}
			else
			{
				break;
			}
		}

		return count;
	}

	private static String[] loadArguments(final List<Token> tokens)
	{
		int count = getArgumentCount(tokens);

		if (count == 0)
		{
			return null;
		}

		String[] arguments = new String[count];

		ListIterator<Token> iterator = tokens.listIterator();
		for (int i = 0; i < count; ++i)
		{
			arguments[i] = iterator.next().getText();
			iterator.remove();
		}

		return arguments;
	}

	private static class Environment
	{
		private static class Interpreter
		{
			public final Binding      binding = new Binding();
			private final GroovyShell shell   = new GroovyShell(binding);

			private boolean           valid;

			public boolean isValid()
			{
				return valid;
			}

			private boolean isValid(final String[] arguments, final List<Object> argumentValues)
			{
				if (arguments == null && argumentValues == null)
				{
					valid = true;
				}
				else if (arguments != null && argumentValues != null)
				{
					valid = arguments.length == argumentValues.size();
				}
				else
				{
					valid = false;
				}

				return valid;
			}

			@SuppressWarnings("unchecked")
			private void inheritBinding(final Binding binding)
			{
				if (binding == null)
				{
					return;
				}

				for (Object field : binding.getVariables().entrySet())
				{
					this.binding.setVariable(((Map.Entry<String, Object>) field).getKey(), ((Map.Entry<String, Object>) field).getValue());
				}
			}

			private void loadArguments(final String[] arguments, final List<Object> argumentValues)
			{
				if (arguments == null || argumentValues == null)
				{
					return;
				}

				int argp = 0;
				for (Object value : argumentValues)
				{
					this.binding.setVariable(arguments[argp], value);
				}
			}

			public void evaluate(final String script)
			{
				shell.evaluate(script);
			}

			public Interpreter(final Binding binding, final String[] arguments, final List<Object> argumentValues)
			{
				if (isValid(arguments, argumentValues))
				{
					inheritBinding(binding);
					loadArguments(arguments, argumentValues);
				}
			}

			public Interpreter(final String[] arguments, final List<Object> argumentValues)
			{
				if (isValid(arguments, argumentValues))
				{
					loadArguments(arguments, argumentValues);
				}
			}
		}
		
		private static Stack<Interpreter> environment = new Stack<Interpreter>();
		private static Interpreter        shell       = null;

		public static boolean push(final String[] arguments, final List<Object> argumentValues)
		{
			Interpreter interpreter;

			if (shell == null)
			{
				interpreter = new Interpreter(arguments, argumentValues);
			}
			else
			{
				interpreter = new Interpreter(environment.peek().binding, arguments, argumentValues);
			}

			if (interpreter.isValid())
			{
				environment.push(interpreter);
				shell = interpreter;

				return true;
			}

			return false;
		}

		public static boolean pop()
		{
			if (environment.isEmpty())
			{
				shell = null;

				return false;
			}

			shell = environment.pop();

			return true;
		}

		public static void evaluate(final String script)
		{
			shell.evaluate(script);
		}
	}
	
	// compilation start (where to write to)
	private static boolean compile(final File file, final Lexer lexer)
	{
		Read reader = new Read(file);

		if (reader.isOpen())
		{
			List<Token> tokens = loadTokens(file, lexer);
			
			/*
			 * evaluate the tokens here
			 */
			
			return true;
		}

		return false;
	}

	private static void prepareEnvironment(PrintWriter printWriter)
	{
		push(null, null);

		shell.binding.setVariable("out", new GroovyPrintWriter(printWriter));
		shell.evaluate("print = {arg -> out.print(arg)}");
		shell.evaluate("println = {arg -> out.println(arg)}");
		
		/*
		 * do an include function for groovy
		 */
		shell.evaluate("include = {}");
	}

	public static void main(String[] args)
	{
		if (args.length <= 1)
		{
			System.err.println("[output directory] [filename]+");
		}

		File outputDirectory = loadDirectory(args[0]);

		if (outputDirectory != null)
		{
			final int MAX_FILE_SIZE = 400*1024;
			
			CharArrayWriter charWriter = new CharArrayWriter(MAX_FILE_SIZE);
			PrintWriter printWriter = new PrintWriter(charWriter, true);

			OutputStreamWriter outputStreamWriter;
			File file;
			String path;

			Lexer lexer = new AntlrLexer(new CharStream());

			prepareEnvironment(printWriter);

			for (int i = 1; i < args.length; ++i)
			{
				file = new File(args[i]);

				if (compile(file, lexer))
				{
					path = outputDirectory.getAbsolutePath() + File.pathSeparator + file.getName();

					outputStreamWriter = loadOutputStreamWriter(loadFile(path));
					if (outputStreamWriter != null)
					{
						try
						{
							charWriter.writeTo(outputStreamWriter);
							outputStreamWriter.close();
						}
						catch (Exception e)
						{

						}

					}
				}

				charWriter.reset();
			}
		}
	}
}
