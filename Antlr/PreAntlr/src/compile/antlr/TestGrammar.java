package compile.antlr;

import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.LinkedList;
import java.util.List;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CommonToken;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.DiagnosticErrorListener;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.atn.PredictionMode;

public class TestGrammar
{
	private Class<? extends Lexer>  lexerClass;
	private Class<? extends Parser> parserClass;
	private Lexer                   lexer;
	private Parser                  parser;

	private boolean                 arg_tree        = false;
	private boolean                 arg_tokens      = false;
	private boolean                 arg_gui         = false;
	private String                  arg_ps          = null;
	private String                  arg_encoding    = null;
	private boolean                 arg_trace       = false;
	private boolean                 arg_diagnostics = false;
	private boolean                 arg_sll         = false;
	private String                  arg_channel     = null;
	private String                  arg_lexer;
	private String                  arg_parser;
	private String                  arg_package;
	private List<String>            arg_input       = new LinkedList<String>();

	private CommonTokenStream       tokens;
	private List<Token>             tokenList;

	private String                  parserRule;

	private String[]                tokenNames;
	private String[]                channelNames    = null;

	private int getValueWidth()
	{
		int max = 0;
		int len;
		String str;

		for (Token token : tokenList)
		{
			str = token.getText();
			str = str.replace("\n", "\\n");
			str = str.replace("\t", "\\t");
			str = str.replace("\r", "\\r");
			((CommonToken) token).setText(str);
			len = token.getText().length();

			if (len > max)
			{
				max = len;
			}
		}

		return max;
	}

	private int getTypeWidth()
	{
		int max = 0;
		int type;
		int len;

		for (Token token : tokenList)
		{
			type = token.getType();

			if (type == -1)
			{
				len = 3;
			}
			else
			{
				len = tokenNames[type].length();
			}

			if (len > max)
			{
				max = len;
			}
		}

		return max;
	}

	private int getChannelWidth()
	{
		if (channelNames == null)
		{
			return 4;
		}

		int max = 0;
		int len;

		for (Token token : tokenList)
		{
			len = channelNames[token.getChannel()].length();

			if (len > max)
			{
				max = len;
			}
		}

		return max;
	}

	private static void printex(String msg, int maxlen, int spacing)
	{
		int strlen = msg == null || msg == ""? 0 : msg.length();
		int len = 0;

		char[] str = msg.toCharArray();

		while (len < strlen && len < maxlen)
		{
			if (str[len] == '\t' || str[len] == '\r' || str[len] == '\n')
			{
				str[len] = ' ';
			}
			System.out.print(str[len++]);
		}

		while (len++ < maxlen)
		{
			System.out.print(' ');
		}

		for (int i = spacing; i > 0; --i)
		{
			System.out.print(' ');
		}
	}

	private static void printex(char c, int len)
	{
		while (len-- > 0)
		{
			System.out.print('-');
		}
	}

	private void printTokens(String tabs)
	{
		if (arg_tokens)
		{
			tokenList = tokens.getTokens();

			final int spacing = 8;
			final int typeWidth = getTypeWidth();
			final int valueWidth = getValueWidth() + 2;
			final int channelWidth = getChannelWidth();
			final int width = typeWidth + valueWidth + channelWidth + spacing + spacing;

			int type;

			System.out.print(tabs + "Tokens {\n");

			System.out.print(tabs + "\t");

			printex("Type", typeWidth, spacing);
			printex("Value", valueWidth, spacing);
			printex("Channel", channelWidth, 0);

			System.out.println();

			System.out.print(tabs + "\t");
			printex('-', width);

			System.out.print("\n\n");

			for (Token token : tokenList)
			{
				type = token.getType();

				System.out.print(tabs + "\t");

				printex(type == -1? "EOF" : tokenNames[type], typeWidth, spacing);
				printex("|" + token.getText() + "|", valueWidth, spacing);

				if (channelNames != null)
				{
					printex(channelNames[token.getChannel()], channelWidth, 0);
				}
				else
				{
					printex(Integer.toString(token.getChannel()), channelWidth, 0);
				}

				System.out.print('\n');
			}

			System.out.print(tabs + "}\n");
		}
	}

	private boolean evaluateArgs_assert(String[] args, final int i, final String expected)
	{
		if (args[i].equals(expected))
		{
			return true;
		}

		System.err.println("Expecting [" + expected + "], got [" + args[i] + "]");

		return false;
	}

	private void evaluateArgs_error(final String arg, final String expected)
	{
		System.err.println("Expecting " + expected + ", got [" + arg + "]");
	}

	private int evaluateArgs_grammar(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-grammar"))
		{
			++i;
			if (i < args.length)
			{
				if (args[i].charAt(0) != '-')
				{
					arg_lexer = args[i];
					arg_parser = args[i];
				}
				else
				{
					--i;
					evaluateArgs_error(args[i], "[grammarName]");
				}
			}
			else
			{
				evaluateArgs_error("nothing", "[grammarName]");
			}
		}

		return i;
	}

	private int evaluateArgs_lexer(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-lexer"))
		{
			++i;
			if (i < args.length)
			{
				if (args[i].charAt(0) != '-')
				{
					arg_lexer = args[i];
				}
				else
				{
					--i;
					evaluateArgs_error(args[i], "[lexerName]");
				}
			}
			else
			{
				evaluateArgs_error("nothing", "[lexerName]");
			}
		}

		return i;
	}

	private int evaluateArgs_parser(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-parser"))
		{
			++i;
			if (i < args.length)
			{
				if (args[i].charAt(0) != '-')
				{
					arg_parser = args[i];
				}
				else
				{
					--i;
					evaluateArgs_error(args[i], "[parserName]");
				}
			}
			else
			{
				evaluateArgs_error("nothing", "[parserName]");
			}
		}

		return i;
	}

	private int evaluateArgs_package(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-package"))
		{
			++i;
			if (i < args.length)
			{
				if (args[i].charAt(0) != '-')
				{
					arg_package = args[i];
				}
				else
				{
					--i;
					evaluateArgs_error(args[i], "[packageName]");
				}
			}
			else
			{
				evaluateArgs_error("nothing", "[packageName]");
			}
		}

		return i;
	}

	private int evaluateArgs_encoding(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-encoding"))
		{
			++i;
			if (i < args.length)
			{
				if (args[i].charAt(0) != '-')
				{
					arg_encoding = args[i];
				}
				else
				{
					--i;
					evaluateArgs_error(args[i], "[encodingName]");
				}
			}
			else
			{
				evaluateArgs_error("nothing", "[encodingName]");
			}
		}

		return i;
	}

	private int evaluateArgs_ps(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-ps"))
		{
			++i;
			if (i < args.length)
			{
				if (args[i].charAt(0) != '-')
				{
					arg_ps = args[i];
				}
				else
				{
					--i;
					evaluateArgs_error(args[i], "[psName]");
				}
			}
			else
			{
				evaluateArgs_error("nothing", "[psName]");
			}
		}

		return i;
	}

	private int evaluateArgs_channel(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-channel"))
		{
			++i;
			if (i < args.length)
			{
				if (args[i].charAt(0) != '-')
				{
					arg_channel = args[i];
				}
				else
				{
					--i;
					evaluateArgs_error(args[i], "[channelName]");
				}
			}
			else
			{
				evaluateArgs_error("nothing", "[channelName]");
			}
		}

		return i;
	}

	private int evaluateArgs_tokens(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-tokens"))
			arg_tokens = true;

		return i;
	}

	private int evaluateArgs_tree(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-tree"))
			arg_tree = true;

		return i;
	}

	private int evaluateArgs_gui(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-gui"))
			arg_gui = true;

		return i;
	}

	private int evaluateArgs_trace(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-"))
			arg_trace = true;

		return i;
	}

	private int evaluateArgs_diagnostics(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-diagnostics"))
			arg_diagnostics = true;

		return i;
	}

	private int evaluateArgs_SLL(final String args[], int i)
	{
		if (evaluateArgs_assert(args, i, "-SLL"))
			arg_sll = true;

		return i;
	}

	private int evaluateArgs_input(final String args[], int i)
	{
		if (args[i].charAt(0) != '-')
		{
			arg_input.add(args[i]);
		}

		return i;
	}

	private int evaluateArgs_g(final String args[], final int i, final int d)
	{
		switch (args[i].charAt(d))
		{
			case 'r':
				return evaluateArgs_grammar(args, i);
			case 'u':
				return evaluateArgs_gui(args, i);
			default:
				evaluateArgs_error(args[i], "[-grammar] [-gui]");
		}

		return i;
	}

	private int evaluateArgs_pa(final String args[], final int i, final int d)
	{
		switch (args[i].charAt(d))
		{
			case 'r':
				return evaluateArgs_parser(args, i);
			case 'c':
				return evaluateArgs_package(args, i);
			default:
				evaluateArgs_error(args[i], "[-parser] [-package]]");
		}

		return i;
	}

	private int evaluateArgs_p(final String args[], final int i, final int d)
	{
		switch (args[i].charAt(d))
		{
			case 'a':
				return evaluateArgs_pa(args, i, d + 1);
			case 's':
				return evaluateArgs_ps(args, i);
			default:
				evaluateArgs_error(args[i], "[-parser] [-ps] [-package]");
		}

		return i;
	}

	private int evaluateArgs_tr(final String args[], final int i, final int d)
	{
		switch (args[i].charAt(d))
		{
			case 'e':
				return evaluateArgs_tree(args, i);
			case 'a':
				return evaluateArgs_trace(args, i);
			default:
				evaluateArgs_error(args[i], "[-tree] [-trace]");
		}

		return i;
	}

	private int evaluateArgs_t(final String args[], final int i, final int d)
	{
		switch (args[i].charAt(d))
		{
			case 'o':
				return evaluateArgs_tokens(args, i);
			case 'r':
				return evaluateArgs_tr(args, i, d + 1);
			default:
				evaluateArgs_error(args[i], "[-tokens] [-tree] [-trace]");
		}

		return i;
	}

	private int evaluateArgs_1(final String args[], final int i, final int d)
	{
		switch (args[i].charAt(d))
		{
			case 'g':
				return evaluateArgs_g(args, i, d + 1);
			case 'l':
				return evaluateArgs_lexer(args, i);
			case 'p':
				return evaluateArgs_p(args, i, d + 1);
			case 't':
				return evaluateArgs_t(args, i, d + 1);
			case 'e':
				return evaluateArgs_encoding(args, i);
			case 'd':
				return evaluateArgs_diagnostics(args, i);
			case 's':
				return evaluateArgs_SLL(args, i);
			case 'c':
				return evaluateArgs_channel(args, i);
			default:
				evaluateArgs_error(args[i],
				                   "[-grammar] [-lexer] [-parser] [-package]  [-tokens] [-tree] [-gui] [-trace] [-diagnostics] [-SLL] [-ps] [-encoding]");
		}

		return i;
	}

	private int evaluateArgs_0(final String args[], final int i, final int d)
	{
		if (args[i].length() < 3)
		{
			evaluateArgs_error(args[i],
			                   "[-grammar] [-lexer] [-parser] [-packcage] [-tokens] [-tree] [-gui] [-trace] [-diagnostics] [-SLL] [-ps] [-encoding]");

			return i;
		}

		switch (args[i].charAt(d))
		{
			case '-':
				return evaluateArgs_1(args, i, d + 1);
			default:
				return evaluateArgs_input(args, i);
		}
	}

	private void evaluateArgs_len0(String args[])
	{
		if (args.length == 0)
		{
			System.err.print("Arguments\n-------------------------------------------------------------------------\n\n");
			System.err.println("\t([-grammar grammarName] | [-lexer lexerName] [-parser parserName])");
			System.err.println("\t[-package packageName]? [-ps psName]? [-encoding encodingName]? [-channel enumName]?");
			System.err.println("\t[-tokens]? [-tree]? [-gui]? [-trace]? [-diagnostics]? [-SLL]?");
			System.err.println("\t[input-filename]*");

			System.err.print("\nDetails\n---------------------------------------------------------------------------\n\n");

			System.err.println("\tA lexer of some sort, be it from -grammar or -lexer, must be passed in\n\n");

			System.err.println("\t[-grammar grammarName]\n" + "\n\t\t" + "Will attempt to load both lexer and parser of name [grammarName]"
			                   + "\n\t\t" + "The loaded grammar will be the last appearing [-grammar] argument" + "\n\n");

			System.err.println("\t[-lexer lexerName]\n" + "\n\t\t" + "Will attempt to load the lexer of name [lexerName]" + "\n\t\t"
			                   + "The loaded lexer will be the last appearing [-lexer] argument" + "\n\n");

			System.err.println("\t[-parser parserName]\n" + "\n\t\t" + "Will attempt to load the parser of name [parserName]" + "\n\t\t"
			                   + "The loaded parser will be the last appearing [-parser] argument" + "\n\n\t\t" + "Requires a lexer"
			                   + "\n\n");

			System.err.println("\t[-channel enumName]\n" + "\n\t\t" + "Will use supplied [enumName] for channel names in token output"
			                   + "\n\t\t" + "Without this, it will use channel ids instead of channel names"
			                   + "\n\n\t\tExample: -channel Channel" + "\n\n\t\t\t" + "public static enum Channel {" + "\n\t\t\t\t"
			                   + "OUT," + "\n\t\t\t\t" + "WHITESPACE," + "\n\t\t\t\t" + "COMMENTS" + "\n\n\t\t\t\t"
			                   + ";	public final int 	value 			= CHANNEL_INDEX++;" + "\n\t\t\t"
			                   + "} 		private static int 	CHANNEL_INDEX 		= 0;" + "\n\n");

			System.err.println("\t[-package packageName]\n" + "\n\t\t" + "Will load grammar from package [packageName]" + "\n\t\t"
			                   + "Packages may be specifically applied to the parser and lexer as well" + "\n\t\t"
			                   + "A package declaration will work with specific lexer and parser package definitions"

			                   + "\n\n\t\t" + "Loads myPackage..otherPackage.subPackage.lexerName"

			                   + "\n\n\t\t\t" + "-package myPackage.otherPackage -lexer subPackage.lexerName" + "\n\n");

			System.err.println("\t[-ps psName]\n" + "\n\t\t" + "generates a visual representation of the parse tree in PostScript and"
			                   + "\n\t\t" + "stores it in [psName] (should be of type .ps)" + "\n\n");

			System.err.println("\t[-encoding encodingName]\n" + "\n\t\t" + "specifies the input file encoding if the current" + "\n\t\t"
			                   + "locale would not read the input properly. For example, need this option" + "\n\t\t"
			                   + "to parse a Japanese-encoded XML file" + "\n\n");

			System.err.println("\t[-trace]\n" + "\n\t\t" + "prints the rule name and current token upon rule entry and exit" + "\n\n");

			System.err.println("\t[-diagnostics]\n" + "\n\t\t" + "turns on diagnostic messages during parsing. This generates messages"
			                   + "\n\t\t" + "only for unusual situations such as ambiguous input phrases." + "\n\n");

			System.err.println("\t[-SLL]\n" + "\n\t\t" + "uses a faster but slightly weaker parsing strategy" + "\n\n");

			System.err.println("\t[input-filename]\n" + "\n\t\t" + "Omitting will read from stdin" + "\n\n");

			System.exit(1);
		}
	}

	private void evaluateArgs(String args[])
	{
		evaluateArgs_len0(args);

		for (int i = 0; i < args.length; ++i)
		{
			i = evaluateArgs_0(args, i, 0);
		}
	}

	public TestGrammar(String args[])
	{
		evaluateArgs(args);
	}

	private String getLexerName()
	{
		if (arg_lexer == null)
		{
			System.err.println("Missing lexer");

			System.exit(1);
		}

		if (arg_package != null)
		{
			return arg_package + "." + arg_lexer;
		}
		else
		{
			return arg_lexer;
		}
	}

	private String getParserName()
	{
		if (arg_parser == null)
		{
			System.err.println("Missing parser");

			System.exit(1);
		}

		if (arg_package != null)
		{
			return arg_package + "." + arg_parser;
		}
		else
		{
			return arg_parser;
		}
	}

	private void loadLexer()
	{
		String lexerName = getLexerName() + "Lexer";
		ClassLoader classLoader = Thread.currentThread().getContextClassLoader();

		lexerClass = null;
		try
		{
			lexerClass = classLoader.loadClass(lexerName).asSubclass(Lexer.class);
		}
		catch (java.lang.ClassNotFoundException cnfe)
		{
			lexerName = arg_lexer;

			try
			{
				lexerClass = classLoader.loadClass(lexerName).asSubclass(Lexer.class);
			}
			catch (ClassNotFoundException cnfe2)
			{
				System.err.println("Unable to load " + lexerName + " as lexer or parser (file wasn't found)");
				System.exit(1);
			}
		}

		try
		{
			Constructor<? extends Lexer> lexerCtor = lexerClass.getConstructor(CharStream.class);
			lexer = lexerCtor.newInstance((CharStream) null);
		}
		catch (Exception e)
		{
			System.exit(1);
		}

		tokenNames = lexer.getTokenNames();

		if (arg_channel != null)
		{
			Class<?> channel = null;

			try
			{
				channel = Class.forName(lexerClass.getName() + "$" + arg_channel);
			}
			catch (Exception e)
			{
				System.err.println("[" + arg_channel + " is not a declared member enum of @members of " + arg_lexer);
				System.err.println("Using channel id for -tokens instead of channel names");
			}

			if (channel != null)
			{
				if (channel.isEnum())
				{
					if (Modifier.isStatic(channel.getModifiers()))
					{
						Object[] enumConstants = channel.getEnumConstants();

						if (enumConstants.length != 0)
						{
							channelNames = new String[enumConstants.length];

							for (int i = 0; i < enumConstants.length; ++i)
							{
								channelNames[i] = enumConstants[i].toString();
							}
						}
						else
						{
							System.err.println("[" + arg_channel + "] has no declared channels");
							System.err.println("Using channel id for -tokens instead of channel names");
						}
					}
					else
					{
						System.err.println("[" + arg_channel + "] is not a static member of @members of " + arg_lexer);
						System.err.println("Using channel id for -tokens instead of channel names");
					}
				}
				else
				{
					System.err.println("[" + arg_channel + "] is not a member enum of @members of " + arg_lexer);
					System.err.println("Using channel id for -tokens instead of channel names");
				}
			}
		}
	}

	private void loadParser()
	{
		parserClass = null;
		parser = null;

		if (arg_parser != null)
		{
			String parserName = getParserName() + "Parser";
			ClassLoader classLoader = Thread.currentThread().getContextClassLoader();

			try
			{
				parserClass = classLoader.loadClass(parserName).asSubclass(Parser.class);
			}
			catch (Exception e)
			{
				parserName = arg_parser;

				try
				{
					parserClass = classLoader.loadClass(parserName).asSubclass(Parser.class);
				}
				catch (ClassNotFoundException cnfe2)
				{
					System.err.println("Unable to load " + parserName + " as parser (file wasn't found)");
					System.exit(1);
				}
			}

			try
			{
				Constructor<? extends Parser> parserCtor = parserClass.getConstructor(TokenStream.class);
				parser = parserCtor.newInstance((TokenStream) null);
			}
			catch (Exception e)
			{
			}
		}

		if (parser != null)
		{
			parserRule = parser.getRuleNames()[0];
		}
	}

	private void process()
	{
		loadLexer();
		loadParser();

		InputStream inputStream;
		Reader reader;

		if (arg_input.size() == 0)
		{
			inputStream = System.in;
			reader = null;

			try
			{
				if (arg_encoding != null)
				{
					reader = new InputStreamReader(inputStream, arg_encoding);
				}
				else
				{
					reader = new InputStreamReader(inputStream);
				}
			}
			catch (Exception e)
			{
			}

			if (reader != null)
			{
				process(inputStream, reader);
			}
		}
		else
		{
			for (String inputFile : arg_input)
			{
				inputStream = null;
				reader = null;

				try
				{
					if (inputFile != null)
					{
						inputStream = new FileInputStream(inputFile);
					}
				}
				catch (Exception e)
				{
					System.err.println("Could Not Load File [" + inputFile + "]");
				}

				if (inputStream != null)
				{
					try
					{
						if (arg_encoding != null)
						{
							reader = new InputStreamReader(inputStream, arg_encoding);
						}
						else
						{
							reader = new InputStreamReader(inputStream);
						}
					}
					catch (Exception e)
					{
					}

					if (reader != null)
					{
						System.out.print(inputFile + " {\n");
						process(inputStream, reader);
						System.out.print("}\n");
					}
				}

			}
		}
	}

	private void process(InputStream inputStream, Reader reader)
	{
		try
		{
			lexer.setInputStream(new ANTLRInputStream(reader));
			tokens = new CommonTokenStream(lexer);
			// tokens = new UnbufferedTokenStream(lexer);

			if (parser != null)
			{
				if (arg_diagnostics)
				{
					parser.addErrorListener(new DiagnosticErrorListener());
					parser.getInterpreter().setPredictionMode(PredictionMode.LL_EXACT_AMBIG_DETECTION);
				}

				if (arg_tree || arg_gui || arg_ps != null)
				{
					parser.setBuildParseTree(true);
				}

				if (arg_sll)
				{
					parser.getInterpreter().setPredictionMode(PredictionMode.SLL);
				}

				parser.setTokenStream(tokens);
				parser.setTrace(arg_trace);

				if (arg_tree || arg_gui || arg_ps != null)
				{
					try
					{
						Method startRule = parserClass.getMethod(parserRule);
						ParserRuleContext tree = (ParserRuleContext) startRule.invoke(parser, (Object[]) null);

						if (arg_tree)
						{
							System.out.println("\tTree {\n\t\t" + tree.toStringTree(parser) + "\n\t}");
						}
						if (arg_gui)
						{
							tree.inspect(parser);
						}
						if (arg_ps != null)
						{
							try
							{
								tree.save(parser, arg_ps);
							}
							catch (Exception e)
							{
								System.out.println("Could not save postscript [" + arg_ps + "]");
							}
						}
					}
					catch (Exception e)
					{
						System.err.println("Parser has invalid start rule [" + parserRule + "]");
					}
				}
			}
			else
			{
				tokens.fill();
			}

			printTokens("\t");
		}
		catch (Exception e)
		{
		}
		finally
		{
			try
			{
				if (reader != null)
				{
					reader.close();
				}
				if (inputStream != null)
				{
					inputStream.close();
				}
			}
			catch (Exception e)
			{
			}
		}
	}

	public static void main(String args[])
	{
		TestGrammar tester = new TestGrammar(args);

		tester.process();
	}
}