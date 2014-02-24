// Generated from AntlrLexer.g4 by ANTLR 4.2
package compile.antlr;

	import org.antlr.v4.runtime.ANTLRFileStream;
	
	import java.util.HashMap;
	import java.util.Stack;
	import java.util.LinkedList;
	import java.util.Map;

import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.misc.*;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class AntlrLexer extends Lexer {
	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		SCRIPT=1, WS=2, COMMENTS=3, ARGUMENTS=4, ANY=5, CHAR_SEQUENCE=6, PARAM_START=7, 
		PRE_START=8, Arguments_WS=9, Arguments_RBRACK=10, Arguments_ARGUMENT=11, 
		Param_ANY=12, Param_PARAM_START=13, Param_END=14, Param_PRE_START=15, 
		Import_WS=16, Import_FILE=17, Imporg_ARG_READ=18, Import_END=19, ImportArg_WS=20, 
		ImportArg_ARG=21, ImportArg_ARG_READ=22, ImportArg_END=23, Arg_WS=24, 
		Arg_END=25, Arg_VAL=26, Eval_EXPR=27, Package_WS=28, Package_FILE=29, 
		Package_FILE_READ=30, Package_END=31, PackageArg_WS=32, PackageArg_ARG=33, 
		PackageArg_ARG_READ=34, PackageArg_END=35, Pre_IMPORT_START=36, Pre_PACKAGE_START=37, 
		Pre_ARG_START=38, Pre_EVAL_CHAIN_START=39, Pre_EVAL_START=40, Pre_EVAL_CHAIN_END=41;
	public static final int Normal = 1;
	public static final int Arguments = 2;
	public static final int Param = 3;
	public static final int Import = 4;
	public static final int ImportArg = 5;
	public static final int Arg = 6;
	public static final int Eval = 7;
	public static final int Package = 8;
	public static final int PackageArg = 9;
	public static final int Pre = 10;
	public static String[] modeNames = {
		"DEFAULT_MODE", "Normal", "Arguments", "Param", "Import", "ImportArg", 
		"Arg", "Eval", "Package", "PackageArg", "Pre"
	};

	public static final String[] tokenNames = {
		"<INVALID>",
		"SCRIPT", "WS", "COMMENTS", "ARGUMENTS", "ANY", "CHAR_SEQUENCE", "PARAM_START", 
		"PRE_START", "Arguments_WS", "Arguments_RBRACK", "Arguments_ARGUMENT", 
		"Param_ANY", "Param_PARAM_START", "Param_END", "Param_PRE_START", "Import_WS", 
		"Import_FILE", "Imporg_ARG_READ", "Import_END", "ImportArg_WS", "ImportArg_ARG", 
		"ImportArg_ARG_READ", "ImportArg_END", "Arg_WS", "Arg_END", "Arg_VAL", 
		"Eval_EXPR", "Package_WS", "Package_FILE", "Package_FILE_READ", "Package_END", 
		"PackageArg_WS", "PackageArg_ARG", "PackageArg_ARG_READ", "PackageArg_END", 
		"'#`>'", "Pre_PACKAGE_START", "Pre_ARG_START", "'#`?{'", "Pre_EVAL_START", 
		"Pre_EVAL_CHAIN_END"
	};
	public static final String[] ruleNames = {
		"WS", "COMMENTS", "ARGUMENTS", "ANY", "CHAR_SEQUENCE", "PARAM_START", 
		"PRE_START", "Arguments_WS", "Arguments_RBRACK", "Arguments_ARGUMENT", 
		"Param_ANY", "Param_PARAM_START", "Param_END", "Param_PRE_START", "Import_WS", 
		"Import_FILE", "Imporg_ARG_READ", "Import_END", "ImportArg_WS", "ImportArg_ARG", 
		"ImportArg_ARG_READ", "ImportArg_END", "Arg_WS", "Arg_END", "Arg_VAL", 
		"Eval_EXPR", "Package_WS", "Package_FILE", "Package_FILE_READ", "Package_END", 
		"PackageArg_WS", "PackageArg_ARG", "PackageArg_ARG_READ", "PackageArg_END", 
		"Pre_IMPORT_START", "Pre_PACKAGE_START", "Pre_ARG_START", "Pre_EVAL_CHAIN_START", 
		"Pre_EVAL_START", "Pre_EVAL_CHAIN_END"
	};


		private boolean evaluate(String expr)
		{
			ExprLexer lexer = new ExprLexer(new ANTLRInputStream(expr), environment);
			CommonTokenStream tokenStream = new CommonTokenStream(lexer);
			tokenStream.fill();
			return new ExprParser(tokenStream).start().v;
		}
		
		private class SymbolTable
		{
			private Stack<HashMap<String, String>> symbols = new Stack<HashMap<String, String>>();
			private HashMap<String,String> symbolTable = new HashMap<String, String>();
			
			public void push()
			{
				symbols.push(symbolTable);
				symbolTable = new HashMap<String, String>();
			}
			
			public void pushInherit()
				{
					HashMap<String,String> symbolTable = new HashMap<String, String>();
					
					inherit(symbolTable, this.symbolTable);
					
					symbols.push(this.symbolTable);
					this.symbolTable = symbolTable;
				}
				
				public void pop()
				{
					symbolTable = symbols.pop();
				}
				
				public void define(String symbol, String value)
				{
					symbolTable.put(symbol, value);
				}
				
				public void undefine(String symbol)
				{
					symbolTable.remove(symbol);
				}
				
				public String get(String symbol)
				{
					return symbolTable.get(symbol);
				}
				
				public void inherit(HashMap<String,String> child, HashMap<String,String> parent)
				{
					for (Map.Entry<String, String> entry : parent.entrySet()) {
						child.put(entry.getKey(), entry.getValue());
					}
				}
		}
		public class Environment
		{
			private class InputState
			{
				public final int line;
				public final int charPosition;
				public final CharStream input;
				public final Pair<TokenSource, CharStream> tokenFactory;
				
				public InputState()
				{
					line = _interp.getLine();
					charPosition = _interp.getCharPositionInLine();
					input = _input;
					tokenFactory = _tokenFactorySourcePair;
				}
				
				public void load()
				{
					_input = input;
					_tokenFactorySourcePair = tokenFactory;
					_interp.setLine(line);
					_interp.setCharPositionInLine(charPosition);
				}
			}
			
			private SymbolTable symbolTable = new SymbolTable();
			private SymbolTable packageTable = new SymbolTable();
			private Stack<InputState> inputStates = new Stack<InputState>();
			private LinkedList<String> args = new LinkedList<String>();
			
			public boolean openPackage(String whichPackage)
			{
				ANTLRInputStream input = null;
				
				try
				{
					input = new ANTLRInputStream(packageTable.get(whichPackage));
				}
				catch (Exception e)
				{
					e.printStackTrace();
				}
				
				if (input == null)
				{
					return false;
				}
				
				/*
				 * replace input
				 */
				inputStates.push(new InputState());
				
				_input = input;
				_interp.setLine(0);
				_interp.setCharPositionInLine(0);
				
				/*
				 * replace symbols
				 */
				symbolTable.pushInherit();
				packageTable.pushInherit();
				
				/*
				 * go to top mode
				 */
				pushMode(0);
				
				return true;
			}
			
			public boolean open(String filename)
			{
				ANTLRFileStream input = null;
				
				try
				{
					input = new ANTLRFileStream(filename);
				}
				catch (Exception e)
				{
					e.printStackTrace();
				}
				
				if (input == null)
				{
					return false;
				}
				
				/*
				 * replace input
				 */
				inputStates.push(new InputState());
				
				_input = input;
				_tokenFactorySourcePair = new Pair<TokenSource, CharStream>(AntlrLexer.this, input);
				_interp.setLine(0);
				_interp.setCharPositionInLine(0);
				
				/*
				 * replace symbols
				 */
				symbolTable.push();
				packageTable.push();
				
				/*
				 * go to top mode
				 */
				 
				pushMode(0);
				
				return true;
			}
			
			public boolean close()
			{
				if (inputStates.isEmpty())
				{
					return false;
				}
				
				/*
				 * load previous input
				 */
				inputStates.pop().load();
				
				/*
				 * load previous symbols
				 */
				symbolTable.pop();
				packageTable.pop();
				
				/*
				 * go to previous mode
				 */
				popMode();
				
				_hitEOF = false;
							
				return true;
			}
			
			public void define(String symbol, String value)
			{
				if (value != null)
				{
					symbolTable.define(symbol, value);
				}
			}
			
			public void undefine(String symbol)
			{
				symbolTable.undefine(symbol);
			}
			
			public String get(String symbol)
			{
				return symbolTable.get(symbol);
			}
			
			public void pushArg(String arg)
			{
				args.addLast(arg);
			}
			
			public String popArg()
			{
				if (args.isEmpty())
				{
					return null;
				}
				
				return args.pop();
			}
			
			public void clearArgs()
			{
				args.clear();
			}
			
			public boolean isEmpty()
			{
				return inputStates.isEmpty();
			}
		}
		
		/*
		 * this manages
		 * 
		 * 		input
		 * 		symbol table
		 */
		private Environment environment = new Environment();
		
		/*
		 * override to close current input when at EOF as there may be multiple
		 * inputs
		 */
		@Override
		public Token nextToken()
		{
			Token token = super.nextToken();
			while (token.getType() == -1 && environment.close())
			{
				token = super.nextToken();
			}
			return token;
		}
		
		private class BlockState
		{
			public final String close;
			
			public BlockState(String close)
			{
				this.close = close;
			}
		}
		
		private java.util.Stack<BlockState> block = new java.util.Stack<BlockState>();
		
		private boolean valid = true;
		public boolean isValid() { return valid; }
		
		private void error(final String message)
	    {
	    	valid = false;
	    	
			getErrorListenerDispatch().syntaxError(
	    		                                       AntlrLexer.this,
	    		                                       null,
	    		                                       _tokenStartLine,
	    		                                       _tokenStartCharPositionInLine,
	    		                                       message + ": " + getCurrentText(),
	    		                                       null
			                                       );
		}
		
		private String getCurrentText(int start, int end)
		{
			return _input.getText(Interval.of(_tokenStartCharIndex + start, _input.index() + end));
		}
		
		private String getCurrentText()
		{
			return _input.getText(Interval.of(_tokenStartCharIndex, _input.index()));
		}
		
		private void checkForClose()
		{
			if (block.isEmpty())
			{
				return;
			}
			
			if (_input.LA(2) == EOF && environment.isEmpty())
			{
				error("Missing closing '" + block.peek().close + "'");
				pop(-1, false);
			}
		}
		
		//or
		private boolean la(String ... ts)
		{
			if (ts != null)
			{
				int i = 0;
				int len = 0;
				
				byte ahead;
				
				for (String s : ts)
				{
					i = 0;
					len = s.length();
					
					while (i < len)
					{
						ahead = (byte)_input.LA(1 + i);
						
						if (ahead == -1 || ahead != s.charAt(i))
						{
							len = 0;
						}
						else
						{
							++i;
						}
					}
					
					if (len > 0)
					{
						return true;
					}
				}
				
				if (len == 0)
				{
					return false;
				}
			}
			
			return true;
		}
		
		//and
		private boolean nla(String ... ts)
		{
			if (ts != null)
			{
				int i = 0;
				int len = 0;
				
				byte ahead;
				
				for (String s : ts)
				{
					i = 0;
					len = s.length();
					
					while (i < len)
					{
						ahead = (byte)_input.LA(1 + i);
						
						if (ahead != -1 && ahead != s.charAt(i))
						{
							len = 0;
						}
						else
						{
							++i;
						}
					}
					
					if (len > 0)
					{
						return false;
					}
				}
			}
			
			return true;
		}
		
		private boolean cont(int t, boolean o)
		{
			if (o)
			{
				more();
			}
			else if (t < 0)
			{
				skip();
			}
			else
			{
				_type = t;
			}
			
			checkForClose();
			
			return o;
		}
		
		private boolean push(String c, int m, int t, boolean o)
		{
			block.push(new BlockState(c));
			
			pushMode(m);
			
			cont(t, o);
			
			return o;
		}
		
		private boolean pop(int t, boolean o)
		{
			block.pop();
			
			popMode();
			
			cont(t, o);
			
			return o;
		}
		
		private boolean cont(int t, String ... ts)
		{
			return cont(t, la(ts));
		}
		
		private boolean ncont(int t, String ... ts)
		{
			return cont(t, nla(ts));
		}
		
		private boolean push(String c, int m, int t, String ... ts)
		{
			return push(c, m, t, la(ts));
		}
		
		private boolean npush(String c, int m, int t, String ... ts)
		{
			return push(c, m, t, nla(ts));
		}
		
		private boolean pop(int t, String ... ts)
		{
			return pop(t, la(ts));
		}
		
		private boolean npop(int t, String ... ts)
		{
			return pop(t, nla(ts));
		}
		
		public boolean enabled = true;
		public boolean disabled = false;
		public Stack<Boolean> enabledStack = new Stack<Boolean>();
		public Stack<Boolean> disabledStack = new Stack<Boolean>();


	public AntlrLexer(CharStream input) {
		super(input);
		_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@Override
	public String getGrammarFileName() { return "AntlrLexer.g4"; }

	@Override
	public String[] getTokenNames() { return tokenNames; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public String[] getModeNames() { return modeNames; }

	@Override
	public ATN getATN() { return _ATN; }

	@Override
	public void action(RuleContext _localctx, int ruleIndex, int actionIndex) {
		switch (ruleIndex) {
		case 2: ARGUMENTS_action((RuleContext)_localctx, actionIndex); break;

		case 3: ANY_action((RuleContext)_localctx, actionIndex); break;

		case 4: CHAR_SEQUENCE_action((RuleContext)_localctx, actionIndex); break;

		case 5: PARAM_START_action((RuleContext)_localctx, actionIndex); break;

		case 6: PRE_START_action((RuleContext)_localctx, actionIndex); break;

		case 7: Arguments_WS_action((RuleContext)_localctx, actionIndex); break;

		case 8: Arguments_RBRACK_action((RuleContext)_localctx, actionIndex); break;

		case 9: Arguments_ARGUMENT_action((RuleContext)_localctx, actionIndex); break;

		case 10: Param_ANY_action((RuleContext)_localctx, actionIndex); break;

		case 11: Param_PARAM_START_action((RuleContext)_localctx, actionIndex); break;

		case 12: Param_END_action((RuleContext)_localctx, actionIndex); break;

		case 13: Param_PRE_START_action((RuleContext)_localctx, actionIndex); break;

		case 14: Import_WS_action((RuleContext)_localctx, actionIndex); break;

		case 15: Import_FILE_action((RuleContext)_localctx, actionIndex); break;

		case 16: Imporg_ARG_READ_action((RuleContext)_localctx, actionIndex); break;

		case 17: Import_END_action((RuleContext)_localctx, actionIndex); break;

		case 18: ImportArg_WS_action((RuleContext)_localctx, actionIndex); break;

		case 19: ImportArg_ARG_action((RuleContext)_localctx, actionIndex); break;

		case 20: ImportArg_ARG_READ_action((RuleContext)_localctx, actionIndex); break;

		case 21: ImportArg_END_action((RuleContext)_localctx, actionIndex); break;

		case 22: Arg_WS_action((RuleContext)_localctx, actionIndex); break;

		case 23: Arg_END_action((RuleContext)_localctx, actionIndex); break;

		case 24: Arg_VAL_action((RuleContext)_localctx, actionIndex); break;

		case 25: Eval_EXPR_action((RuleContext)_localctx, actionIndex); break;

		case 26: Package_WS_action((RuleContext)_localctx, actionIndex); break;

		case 27: Package_FILE_action((RuleContext)_localctx, actionIndex); break;

		case 28: Package_FILE_READ_action((RuleContext)_localctx, actionIndex); break;

		case 29: Package_END_action((RuleContext)_localctx, actionIndex); break;

		case 30: PackageArg_WS_action((RuleContext)_localctx, actionIndex); break;

		case 31: PackageArg_ARG_action((RuleContext)_localctx, actionIndex); break;

		case 32: PackageArg_ARG_READ_action((RuleContext)_localctx, actionIndex); break;

		case 33: PackageArg_END_action((RuleContext)_localctx, actionIndex); break;

		case 34: Pre_IMPORT_START_action((RuleContext)_localctx, actionIndex); break;

		case 35: Pre_PACKAGE_START_action((RuleContext)_localctx, actionIndex); break;

		case 36: Pre_ARG_START_action((RuleContext)_localctx, actionIndex); break;

		case 37: Pre_EVAL_CHAIN_START_action((RuleContext)_localctx, actionIndex); break;

		case 38: Pre_EVAL_START_action((RuleContext)_localctx, actionIndex); break;

		case 39: Pre_EVAL_CHAIN_END_action((RuleContext)_localctx, actionIndex); break;
		}
	}
	private void Arguments_RBRACK_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 6: 
											if (enabled)
											{
												environment.clearArgs();
											}
											
											pop(-1, false);
										 break;
		}
	}
	private void Import_END_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 15: 
											pop(-1, false);
											
											if (enabled)
											{
												environment.open(environment.popArg());
											}
										 break;
		}
	}
	private void Import_WS_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 12: skip(); break;
		}
	}
	private void ARGUMENTS_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 0: 
											_mode = Normal;
											push("]", Arguments, -1, false);
										 break;
		}
	}
	private void Pre_EVAL_CHAIN_END_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 37: 
												popMode();
												pop(-1, false);
												
												enabled = enabledStack.pop();
												disabled = disabledStack.pop();
											 break;
		}
	}
	private void Arg_VAL_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 22: 
										if (enabled)
										{
											_text = environment.get(getCurrentText(0, -1));
											_type = SCRIPT;
										}
										else
										{
											skip();
										}
									 break;
		}
	}
	private void Package_FILE_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 25: 
											if (enabled)
											{
												_text = getCurrentText(1, -2);
											
												_text = _text.replace("\\n", "\n");
												_text = _text.replace("\\r", "\r");
												_text = _text.replace("\\t", "\t");
												_text = _text.replace("\\b", "\b");
												_text = _text.replace("\\f", "\f");
												_text = _text.replace("\\\"", "\"");
												_text = _text.replaceAll("\\(.)", "$1");
												
												environment.pushArg(_text);
											}
											
											skip();
											
											_mode = PackageArg;
										 break;
		}
	}
	private void PRE_START_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 4: 
											pushMode(Pre);
											_input.seek(_input.index() - 2);
											skip();
										 break;
		}
	}
	private void Pre_EVAL_CHAIN_START_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 35: 
												popMode();
												
												enabledStack.push(enabled);
												disabledStack.push(disabled);
												
												if (!enabled)
												{
													enabled = false;
													disabled = true;
												}
												else
												{
													enabled = false;
													disabled = false;
												}
												
												push("#`?}", _mode, -1, false);
												push("`", Eval, -1, false);
											 break;
		}
	}
	private void PackageArg_END_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 31: 
											pop(-1, false);
											
											if (enabled)
											{
												environment.openPackage(environment.popArg());
											}
										 break;
		}
	}
	private void Param_PARAM_START_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 9: 
											npush("]", Param, SCRIPT, "#`");
										 break;
		}
	}
	private void CHAR_SEQUENCE_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 2: 
											ncont(SCRIPT, "#`");
												
											if (!enabled)
											{
												skip();
											}
										 break;
		}
	}
	private void ImportArg_WS_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 16: skip(); break;
		}
	}
	private void Package_FILE_READ_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 26: 
											if (enabled)
											{
												environment.pushArg(environment.get(getCurrentText()));
											}
											
											skip();
										 break;
		}
	}
	private void Arg_WS_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 20: cont(-1, false); break;
		}
	}
	private void Import_FILE_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 13: 
											if (enabled)
											{
												_text = getCurrentText(1, -2);
												_text = _text.replace("\\n", "\n");
												_text = _text.replace("\\r", "\r");
												_text = _text.replace("\\t", "\t");
												_text = _text.replace("\\b", "\b");
												_text = _text.replace("\\f", "\f");
												_text = _text.replaceAll("\\\\(.)", "$1");
												
												environment.pushArg(_text);
											}
											
											skip();
											
											_mode = ImportArg;
										 break;
		}
	}
	private void Pre_PACKAGE_START_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 33: 
												popMode();
												push("#`}", Package, -1, false);
											 break;
		}
	}
	private void Param_PRE_START_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 11: 
											pushMode(Pre);
											_input.seek(_input.index() - 2);
											skip();
										 break;
		}
	}
	private void Pre_EVAL_START_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 36: 
												popMode();
												push("`", Eval, -1, false);
											 break;
		}
	}
	private void Pre_ARG_START_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 34: 
												popMode();
												push("`", Arg, -1, false);
											 break;
		}
	}
	private void Imporg_ARG_READ_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 14: 
											if (enabled)
											{
												environment.pushArg(environment.get(getCurrentText(0, -1)));
											}
											
											skip();
											
											_mode = ImportArg;
										 break;
		}
	}
	private void ANY_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 1: 
											_mode = Normal;
											_input.seek(_input.index() - 1);
											skip();
										 break;
		}
	}
	private void ImportArg_ARG_READ_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 18: 
											if (enabled)
											{
												environment.pushArg(environment.get(getCurrentText(0, -1)));
											}
											
											skip();
										 break;
		}
	}
	private void ImportArg_END_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 19: 
											pop(-1, false);
											
											if (enabled)
											{
												environment.open(environment.popArg());
											}
										 break;
		}
	}
	private void ImportArg_ARG_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 17: 
											if (enabled)
											{
												_text = getCurrentText(1, -2);
											
												_text = _text.replace("\\n", "\n");
												_text = _text.replace("\\r", "\r");
												_text = _text.replace("\\t", "\t");
												_text = _text.replace("\\b", "\b");
												_text = _text.replace("\\f", "\f");
												_text = _text.replaceAll("\\\\(.)", "$1");
												
												environment.pushArg(_text);
											}
											
											skip();
										 break;
		}
	}
	private void Pre_IMPORT_START_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 32: 
												popMode();
												push("`", Import, -1, false);
											 break;
		}
	}
	private void Arg_END_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 21: 
										pop(-1, false);
									 break;
		}
	}
	private void PARAM_START_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 3: 
											push("]", Param, SCRIPT, true);
										 break;
		}
	}
	private void Param_END_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 10: 
											npop(SCRIPT, "#`");
											
											if (!enabled)
											{
												skip();
											}
										 break;
		}
	}
	private void Eval_EXPR_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 23: 
										pop(-1, false);
										
										if (!disabled && evaluate(getCurrentText(0, -2)))
										{
											enabled = true;
											disabled = true;
										}
										else
										{
											enabled = false;
										}
									 break;
		}
	}
	private void Package_WS_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 24: skip(); break;
		}
	}
	private void PackageArg_ARG_READ_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 30: 
											if (enabled)
											{
												environment.pushArg(environment.get(getCurrentText()));
											}
											
											skip();
										 break;
		}
	}
	private void PackageArg_WS_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 28: skip(); break;
		}
	}
	private void Param_ANY_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 8: 
											ncont(SCRIPT, "#`");
											
											if (!enabled)
											{
												skip();
											}
										 break;
		}
	}
	private void Arguments_WS_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 5: 
											skip();
										 break;
		}
	}
	private void Package_END_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 27: 
											pop(-1, false);
											
											if (enabled)
											{
												environment.openPackage(environment.popArg());
											}
										 break;
		}
	}
	private void PackageArg_ARG_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 29: 
											if (enabled)
											{
												_text = getCurrentText(1, -2);
											
												_text = _text.replace("\\n", "\n");
												_text = _text.replace("\\r", "\r");
												_text = _text.replace("\\t", "\t");
												_text = _text.replace("\\b", "\b");
												_text = _text.replace("\\f", "\f");
												_text = _text.replace("\\\"", "\"");
												_text = _text.replaceAll("\\(.)", "$1");
												
												environment.pushArg(_text);
											}
											
											skip();
										 break;
		}
	}
	private void Arguments_ARGUMENT_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 7: 
											if (enabled)
											{
												environment.define(getCurrentText(0, -1), environment.popArg());
											}
											
											skip();
										 break;
		}
	}
	@Override
	public boolean sempred(RuleContext _localctx, int ruleIndex, int predIndex) {
		switch (ruleIndex) {
		case 35: return Pre_PACKAGE_START_sempred((RuleContext)_localctx, predIndex);

		case 38: return Pre_EVAL_START_sempred((RuleContext)_localctx, predIndex);

		case 39: return Pre_EVAL_CHAIN_END_sempred((RuleContext)_localctx, predIndex);
		}
		return true;
	}
	private boolean Pre_EVAL_CHAIN_END_sempred(RuleContext _localctx, int predIndex) {
		switch (predIndex) {
		case 2: return !block.isEmpty() && block.peek().close == "#`?}";
		}
		return true;
	}
	private boolean Pre_PACKAGE_START_sempred(RuleContext _localctx, int predIndex) {
		switch (predIndex) {
		case 0: return false;
		}
		return true;
	}
	private boolean Pre_EVAL_START_sempred(RuleContext _localctx, int predIndex) {
		switch (predIndex) {
		case 1: return !block.isEmpty() && block.peek().close == "#`?}";
		}
		return true;
	}

	public static final String _serializedATN =
		"\3\u0430\ud6d1\u8206\uad2d\u4417\uaef1\u8d80\uaadd\2+\u01aa\b\1\b\1\b"+
		"\1\b\1\b\1\b\1\b\1\b\1\b\1\b\1\b\1\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6"+
		"\t\6\4\7\t\7\4\b\t\b\4\t\t\t\4\n\t\n\4\13\t\13\4\f\t\f\4\r\t\r\4\16\t"+
		"\16\4\17\t\17\4\20\t\20\4\21\t\21\4\22\t\22\4\23\t\23\4\24\t\24\4\25\t"+
		"\25\4\26\t\26\4\27\t\27\4\30\t\30\4\31\t\31\4\32\t\32\4\33\t\33\4\34\t"+
		"\34\4\35\t\35\4\36\t\36\4\37\t\37\4 \t \4!\t!\4\"\t\"\4#\t#\4$\t$\4%\t"+
		"%\4&\t&\4\'\t\'\4(\t(\4)\t)\3\2\6\2_\n\2\r\2\16\2`\3\2\3\2\3\3\3\3\3\3"+
		"\3\3\7\3i\n\3\f\3\16\3l\13\3\3\3\3\3\3\3\3\3\3\3\3\3\7\3t\n\3\f\3\16\3"+
		"w\13\3\6\3y\n\3\r\3\16\3z\3\3\3\3\3\4\3\4\3\4\3\5\3\5\3\5\3\6\3\6\3\6"+
		"\3\6\3\6\3\6\3\6\7\6\u008c\n\6\f\6\16\6\u008f\13\6\3\6\3\6\3\6\3\6\3\6"+
		"\7\6\u0096\n\6\f\6\16\6\u0099\13\6\3\6\3\6\3\6\3\6\3\6\7\6\u00a0\n\6\f"+
		"\6\16\6\u00a3\13\6\3\6\3\6\3\6\3\6\3\6\7\6\u00aa\n\6\f\6\16\6\u00ad\13"+
		"\6\3\6\3\6\5\6\u00b1\n\6\3\6\3\6\3\7\3\7\3\7\3\b\3\b\3\b\3\b\3\b\3\t\3"+
		"\t\6\t\u00bf\n\t\r\t\16\t\u00c0\3\t\3\t\3\n\3\n\3\n\3\13\6\13\u00c9\n"+
		"\13\r\13\16\13\u00ca\3\13\3\13\3\f\3\f\3\f\3\f\5\f\u00d3\n\f\3\f\3\f\3"+
		"\f\5\f\u00d8\n\f\6\f\u00da\n\f\r\f\16\f\u00db\3\f\3\f\3\r\3\r\3\r\3\16"+
		"\3\16\3\16\3\17\3\17\3\17\3\17\3\17\3\20\3\20\6\20\u00ed\n\20\r\20\16"+
		"\20\u00ee\3\20\3\20\3\21\3\21\3\21\3\21\7\21\u00f7\n\21\f\21\16\21\u00fa"+
		"\13\21\3\21\3\21\3\21\3\22\6\22\u0100\n\22\r\22\16\22\u0101\3\22\3\22"+
		"\3\23\3\23\3\23\3\24\3\24\6\24\u010b\n\24\r\24\16\24\u010c\3\24\3\24\3"+
		"\25\3\25\3\25\3\25\7\25\u0115\n\25\f\25\16\25\u0118\13\25\3\25\3\25\3"+
		"\25\3\26\6\26\u011e\n\26\r\26\16\26\u011f\3\26\3\26\3\27\3\27\3\27\3\30"+
		"\3\30\6\30\u0129\n\30\r\30\16\30\u012a\3\30\3\30\3\31\3\31\3\31\3\32\6"+
		"\32\u0133\n\32\r\32\16\32\u0134\3\32\3\32\3\33\6\33\u013a\n\33\r\33\16"+
		"\33\u013b\3\33\3\33\3\33\3\34\3\34\6\34\u0143\n\34\r\34\16\34\u0144\3"+
		"\34\3\34\3\35\3\35\3\35\3\35\7\35\u014d\n\35\f\35\16\35\u0150\13\35\3"+
		"\35\3\35\3\35\3\36\6\36\u0156\n\36\r\36\16\36\u0157\3\36\3\36\3\37\3\37"+
		"\3\37\3\37\3\37\3\37\3 \3 \6 \u0164\n \r \16 \u0165\3 \3 \3!\3!\3!\3!"+
		"\7!\u016e\n!\f!\16!\u0171\13!\3!\3!\3!\3\"\6\"\u0177\n\"\r\"\16\"\u0178"+
		"\3\"\3\"\3#\3#\3#\3#\3#\3#\3$\3$\3$\3$\3$\3$\3%\3%\3%\3%\3%\3%\3%\3&\3"+
		"&\3&\3&\3&\3\'\3\'\3\'\3\'\3\'\3\'\3\'\3(\3(\3(\3(\3(\3(\3(\3)\3)\3)\3"+
		")\3)\3)\3)\3)\4j\u013b\2*\r\4\17\5\21\6\23\7\25\b\27\t\31\n\33\13\35\f"+
		"\37\r!\16#\17%\20\'\21)\22+\23-\24/\25\61\26\63\27\65\30\67\319\32;\33"+
		"=\34?\35A\36C\37E G!I\"K#M$O%Q&S\'U(W)Y*[+\r\2\3\4\5\6\7\b\t\n\13\f\16"+
		"\5\2\13\f\17\17\"\"\4\2\f\f\17\17\b\2$%)),,\61\61]_bb\4\2^^bb\4\2$$^^"+
		"\3\2]_\4\2))^^\5\2%%,,\61\61\6\2\62;C\\aac|\5\2%%]_bb\3\2^_\3\2bb\u01d3"+
		"\2\r\3\2\2\2\2\17\3\2\2\2\2\21\3\2\2\2\2\23\3\2\2\2\3\25\3\2\2\2\3\27"+
		"\3\2\2\2\3\31\3\2\2\2\4\33\3\2\2\2\4\35\3\2\2\2\4\37\3\2\2\2\5!\3\2\2"+
		"\2\5#\3\2\2\2\5%\3\2\2\2\5\'\3\2\2\2\6)\3\2\2\2\6+\3\2\2\2\6-\3\2\2\2"+
		"\6/\3\2\2\2\7\61\3\2\2\2\7\63\3\2\2\2\7\65\3\2\2\2\7\67\3\2\2\2\b9\3\2"+
		"\2\2\b;\3\2\2\2\b=\3\2\2\2\t?\3\2\2\2\nA\3\2\2\2\nC\3\2\2\2\nE\3\2\2\2"+
		"\nG\3\2\2\2\13I\3\2\2\2\13K\3\2\2\2\13M\3\2\2\2\13O\3\2\2\2\fQ\3\2\2\2"+
		"\fS\3\2\2\2\fU\3\2\2\2\fW\3\2\2\2\fY\3\2\2\2\f[\3\2\2\2\r^\3\2\2\2\17"+
		"x\3\2\2\2\21~\3\2\2\2\23\u0081\3\2\2\2\25\u00b0\3\2\2\2\27\u00b4\3\2\2"+
		"\2\31\u00b7\3\2\2\2\33\u00be\3\2\2\2\35\u00c4\3\2\2\2\37\u00c8\3\2\2\2"+
		"!\u00d9\3\2\2\2#\u00df\3\2\2\2%\u00e2\3\2\2\2\'\u00e5\3\2\2\2)\u00ec\3"+
		"\2\2\2+\u00f2\3\2\2\2-\u00ff\3\2\2\2/\u0105\3\2\2\2\61\u010a\3\2\2\2\63"+
		"\u0110\3\2\2\2\65\u011d\3\2\2\2\67\u0123\3\2\2\29\u0128\3\2\2\2;\u012e"+
		"\3\2\2\2=\u0132\3\2\2\2?\u0139\3\2\2\2A\u0142\3\2\2\2C\u0148\3\2\2\2E"+
		"\u0155\3\2\2\2G\u015b\3\2\2\2I\u0163\3\2\2\2K\u0169\3\2\2\2M\u0176\3\2"+
		"\2\2O\u017c\3\2\2\2Q\u0182\3\2\2\2S\u0188\3\2\2\2U\u018f\3\2\2\2W\u0194"+
		"\3\2\2\2Y\u019b\3\2\2\2[\u01a2\3\2\2\2]_\t\2\2\2^]\3\2\2\2_`\3\2\2\2`"+
		"^\3\2\2\2`a\3\2\2\2ab\3\2\2\2bc\b\2\2\2c\16\3\2\2\2de\7\61\2\2ef\7,\2"+
		"\2fj\3\2\2\2gi\13\2\2\2hg\3\2\2\2il\3\2\2\2jk\3\2\2\2jh\3\2\2\2km\3\2"+
		"\2\2lj\3\2\2\2mn\7,\2\2ny\7\61\2\2op\7\61\2\2pq\7\61\2\2qu\3\2\2\2rt\n"+
		"\3\2\2sr\3\2\2\2tw\3\2\2\2us\3\2\2\2uv\3\2\2\2vy\3\2\2\2wu\3\2\2\2xd\3"+
		"\2\2\2xo\3\2\2\2yz\3\2\2\2zx\3\2\2\2z{\3\2\2\2{|\3\2\2\2|}\b\3\2\2}\20"+
		"\3\2\2\2~\177\7]\2\2\177\u0080\b\4\3\2\u0080\22\3\2\2\2\u0081\u0082\13"+
		"\2\2\2\u0082\u0083\b\5\4\2\u0083\24\3\2\2\2\u0084\u00b1\n\4\2\2\u0085"+
		"\u00b1\5\r\2\2\u0086\u00b1\5\17\3\2\u0087\u008d\7b\2\2\u0088\u008c\n\5"+
		"\2\2\u0089\u008a\7^\2\2\u008a\u008c\13\2\2\2\u008b\u0088\3\2\2\2\u008b"+
		"\u0089\3\2\2\2\u008c\u008f\3\2\2\2\u008d\u008b\3\2\2\2\u008d\u008e\3\2"+
		"\2\2\u008e\u0090\3\2\2\2\u008f\u008d\3\2\2\2\u0090\u00b1\7b\2\2\u0091"+
		"\u0097\7$\2\2\u0092\u0096\n\6\2\2\u0093\u0094\7^\2\2\u0094\u0096\13\2"+
		"\2\2\u0095\u0092\3\2\2\2\u0095\u0093\3\2\2\2\u0096\u0099\3\2\2\2\u0097"+
		"\u0095\3\2\2\2\u0097\u0098\3\2\2\2\u0098\u009a\3\2\2\2\u0099\u0097\3\2"+
		"\2\2\u009a\u00b1\7$\2\2\u009b\u00a1\7]\2\2\u009c\u00a0\n\7\2\2\u009d\u009e"+
		"\7^\2\2\u009e\u00a0\13\2\2\2\u009f\u009c\3\2\2\2\u009f\u009d\3\2\2\2\u00a0"+
		"\u00a3\3\2\2\2\u00a1\u009f\3\2\2\2\u00a1\u00a2\3\2\2\2\u00a2\u00a4\3\2"+
		"\2\2\u00a3\u00a1\3\2\2\2\u00a4\u00b1\7_\2\2\u00a5\u00ab\7)\2\2\u00a6\u00aa"+
		"\n\b\2\2\u00a7\u00a8\7^\2\2\u00a8\u00aa\13\2\2\2\u00a9\u00a6\3\2\2\2\u00a9"+
		"\u00a7\3\2\2\2\u00aa\u00ad\3\2\2\2\u00ab\u00a9\3\2\2\2\u00ab\u00ac\3\2"+
		"\2\2\u00ac\u00ae\3\2\2\2\u00ad\u00ab\3\2\2\2\u00ae\u00b1\7)\2\2\u00af"+
		"\u00b1\t\t\2\2\u00b0\u0084\3\2\2\2\u00b0\u0085\3\2\2\2\u00b0\u0086\3\2"+
		"\2\2\u00b0\u0087\3\2\2\2\u00b0\u0091\3\2\2\2\u00b0\u009b\3\2\2\2\u00b0"+
		"\u00a5\3\2\2\2\u00b0\u00af\3\2\2\2\u00b1\u00b2\3\2\2\2\u00b2\u00b3\b\6"+
		"\5\2\u00b3\26\3\2\2\2\u00b4\u00b5\7]\2\2\u00b5\u00b6\b\7\6\2\u00b6\30"+
		"\3\2\2\2\u00b7\u00b8\7%\2\2\u00b8\u00b9\7b\2\2\u00b9\u00ba\3\2\2\2\u00ba"+
		"\u00bb\b\b\7\2\u00bb\32\3\2\2\2\u00bc\u00bf\5\r\2\2\u00bd\u00bf\5\17\3"+
		"\2\u00be\u00bc\3\2\2\2\u00be\u00bd\3\2\2\2\u00bf\u00c0\3\2\2\2\u00c0\u00be"+
		"\3\2\2\2\u00c0\u00c1\3\2\2\2\u00c1\u00c2\3\2\2\2\u00c2\u00c3\b\t\b\2\u00c3"+
		"\34\3\2\2\2\u00c4\u00c5\7_\2\2\u00c5\u00c6\b\n\t\2\u00c6\36\3\2\2\2\u00c7"+
		"\u00c9\t\n\2\2\u00c8\u00c7\3\2\2\2\u00c9\u00ca\3\2\2\2\u00ca\u00c8\3\2"+
		"\2\2\u00ca\u00cb\3\2\2\2\u00cb\u00cc\3\2\2\2\u00cc\u00cd\b\13\n\2\u00cd"+
		" \3\2\2\2\u00ce\u00da\n\13\2\2\u00cf\u00d2\7^\2\2\u00d0\u00d3\n\f\2\2"+
		"\u00d1\u00d3\7\2\2\3\u00d2\u00d0\3\2\2\2\u00d2\u00d1\3\2\2\2\u00d3\u00da"+
		"\3\2\2\2\u00d4\u00d7\7%\2\2\u00d5\u00d8\n\r\2\2\u00d6\u00d8\7\2\2\3\u00d7"+
		"\u00d5\3\2\2\2\u00d7\u00d6\3\2\2\2\u00d8\u00da\3\2\2\2\u00d9\u00ce\3\2"+
		"\2\2\u00d9\u00cf\3\2\2\2\u00d9\u00d4\3\2\2\2\u00da\u00db\3\2\2\2\u00db"+
		"\u00d9\3\2\2\2\u00db\u00dc\3\2\2\2\u00dc\u00dd\3\2\2\2\u00dd\u00de\b\f"+
		"\13\2\u00de\"\3\2\2\2\u00df\u00e0\7]\2\2\u00e0\u00e1\b\r\f\2\u00e1$\3"+
		"\2\2\2\u00e2\u00e3\7_\2\2\u00e3\u00e4\b\16\r\2\u00e4&\3\2\2\2\u00e5\u00e6"+
		"\7%\2\2\u00e6\u00e7\7b\2\2\u00e7\u00e8\3\2\2\2\u00e8\u00e9\b\17\16\2\u00e9"+
		"(\3\2\2\2\u00ea\u00ed\5\r\2\2\u00eb\u00ed\5\17\3\2\u00ec\u00ea\3\2\2\2"+
		"\u00ec\u00eb\3\2\2\2\u00ed\u00ee\3\2\2\2\u00ee\u00ec\3\2\2\2\u00ee\u00ef"+
		"\3\2\2\2\u00ef\u00f0\3\2\2\2\u00f0\u00f1\b\20\17\2\u00f1*\3\2\2\2\u00f2"+
		"\u00f8\7$\2\2\u00f3\u00f7\n\6\2\2\u00f4\u00f5\7^\2\2\u00f5\u00f7\13\2"+
		"\2\2\u00f6\u00f3\3\2\2\2\u00f6\u00f4\3\2\2\2\u00f7\u00fa\3\2\2\2\u00f8"+
		"\u00f6\3\2\2\2\u00f8\u00f9\3\2\2\2\u00f9\u00fb\3\2\2\2\u00fa\u00f8\3\2"+
		"\2\2\u00fb\u00fc\7$\2\2\u00fc\u00fd\b\21\20\2\u00fd,\3\2\2\2\u00fe\u0100"+
		"\t\n\2\2\u00ff\u00fe\3\2\2\2\u0100\u0101\3\2\2\2\u0101\u00ff\3\2\2\2\u0101"+
		"\u0102\3\2\2\2\u0102\u0103\3\2\2\2\u0103\u0104\b\22\21\2\u0104.\3\2\2"+
		"\2\u0105\u0106\7b\2\2\u0106\u0107\b\23\22\2\u0107\60\3\2\2\2\u0108\u010b"+
		"\5\r\2\2\u0109\u010b\5\17\3\2\u010a\u0108\3\2\2\2\u010a\u0109\3\2\2\2"+
		"\u010b\u010c\3\2\2\2\u010c\u010a\3\2\2\2\u010c\u010d\3\2\2\2\u010d\u010e"+
		"\3\2\2\2\u010e\u010f\b\24\23\2\u010f\62\3\2\2\2\u0110\u0116\7$\2\2\u0111"+
		"\u0115\n\6\2\2\u0112\u0113\7^\2\2\u0113\u0115\13\2\2\2\u0114\u0111\3\2"+
		"\2\2\u0114\u0112\3\2\2\2\u0115\u0118\3\2\2\2\u0116\u0114\3\2\2\2\u0116"+
		"\u0117\3\2\2\2\u0117\u0119\3\2\2\2\u0118\u0116\3\2\2\2\u0119\u011a\7$"+
		"\2\2\u011a\u011b\b\25\24\2\u011b\64\3\2\2\2\u011c\u011e\t\n\2\2\u011d"+
		"\u011c\3\2\2\2\u011e\u011f\3\2\2\2\u011f\u011d\3\2\2\2\u011f\u0120\3\2"+
		"\2\2\u0120\u0121\3\2\2\2\u0121\u0122\b\26\25\2\u0122\66\3\2\2\2\u0123"+
		"\u0124\7b\2\2\u0124\u0125\b\27\26\2\u01258\3\2\2\2\u0126\u0129\5\r\2\2"+
		"\u0127\u0129\5\17\3\2\u0128\u0126\3\2\2\2\u0128\u0127\3\2\2\2\u0129\u012a"+
		"\3\2\2\2\u012a\u0128\3\2\2\2\u012a\u012b\3\2\2\2\u012b\u012c\3\2\2\2\u012c"+
		"\u012d\b\30\27\2\u012d:\3\2\2\2\u012e\u012f\7b\2\2\u012f\u0130\b\31\30"+
		"\2\u0130<\3\2\2\2\u0131\u0133\t\n\2\2\u0132\u0131\3\2\2\2\u0133\u0134"+
		"\3\2\2\2\u0134\u0132\3\2\2\2\u0134\u0135\3\2\2\2\u0135\u0136\3\2\2\2\u0136"+
		"\u0137\b\32\31\2\u0137>\3\2\2\2\u0138\u013a\13\2\2\2\u0139\u0138\3\2\2"+
		"\2\u013a\u013b\3\2\2\2\u013b\u013c\3\2\2\2\u013b\u0139\3\2\2\2\u013c\u013d"+
		"\3\2\2\2\u013d\u013e\7b\2\2\u013e\u013f\b\33\32\2\u013f@\3\2\2\2\u0140"+
		"\u0143\5\r\2\2\u0141\u0143\5\17\3\2\u0142\u0140\3\2\2\2\u0142\u0141\3"+
		"\2\2\2\u0143\u0144\3\2\2\2\u0144\u0142\3\2\2\2\u0144\u0145\3\2\2\2\u0145"+
		"\u0146\3\2\2\2\u0146\u0147\b\34\33\2\u0147B\3\2\2\2\u0148\u014e\7$\2\2"+
		"\u0149\u014d\n\6\2\2\u014a\u014b\7^\2\2\u014b\u014d\13\2\2\2\u014c\u0149"+
		"\3\2\2\2\u014c\u014a\3\2\2\2\u014d\u0150\3\2\2\2\u014e\u014c\3\2\2\2\u014e"+
		"\u014f\3\2\2\2\u014f\u0151\3\2\2\2\u0150\u014e\3\2\2\2\u0151\u0152\7$"+
		"\2\2\u0152\u0153\b\35\34\2\u0153D\3\2\2\2\u0154\u0156\t\n\2\2\u0155\u0154"+
		"\3\2\2\2\u0156\u0157\3\2\2\2\u0157\u0155\3\2\2\2\u0157\u0158\3\2\2\2\u0158"+
		"\u0159\3\2\2\2\u0159\u015a\b\36\35\2\u015aF\3\2\2\2\u015b\u015c\7%\2\2"+
		"\u015c\u015d\7b\2\2\u015d\u015e\7\177\2\2\u015e\u015f\3\2\2\2\u015f\u0160"+
		"\b\37\36\2\u0160H\3\2\2\2\u0161\u0164\5\r\2\2\u0162\u0164\5\17\3\2\u0163"+
		"\u0161\3\2\2\2\u0163\u0162\3\2\2\2\u0164\u0165\3\2\2\2\u0165\u0163\3\2"+
		"\2\2\u0165\u0166\3\2\2\2\u0166\u0167\3\2\2\2\u0167\u0168\b \37\2\u0168"+
		"J\3\2\2\2\u0169\u016f\7$\2\2\u016a\u016e\n\6\2\2\u016b\u016c\7^\2\2\u016c"+
		"\u016e\13\2\2\2\u016d\u016a\3\2\2\2\u016d\u016b\3\2\2\2\u016e\u0171\3"+
		"\2\2\2\u016f\u016d\3\2\2\2\u016f\u0170\3\2\2\2\u0170\u0172\3\2\2\2\u0171"+
		"\u016f\3\2\2\2\u0172\u0173\7$\2\2\u0173\u0174\b! \2\u0174L\3\2\2\2\u0175"+
		"\u0177\t\n\2\2\u0176\u0175\3\2\2\2\u0177\u0178\3\2\2\2\u0178\u0176\3\2"+
		"\2\2\u0178\u0179\3\2\2\2\u0179\u017a\3\2\2\2\u017a\u017b\b\"!\2\u017b"+
		"N\3\2\2\2\u017c\u017d\7%\2\2\u017d\u017e\7b\2\2\u017e\u017f\7\177\2\2"+
		"\u017f\u0180\3\2\2\2\u0180\u0181\b#\"\2\u0181P\3\2\2\2\u0182\u0183\7%"+
		"\2\2\u0183\u0184\7b\2\2\u0184\u0185\7@\2\2\u0185\u0186\3\2\2\2\u0186\u0187"+
		"\b$#\2\u0187R\3\2\2\2\u0188\u0189\6%\2\2\u0189\u018a\7%\2\2\u018a\u018b"+
		"\7b\2\2\u018b\u018c\7}\2\2\u018c\u018d\3\2\2\2\u018d\u018e\b%$\2\u018e"+
		"T\3\2\2\2\u018f\u0190\7%\2\2\u0190\u0191\7b\2\2\u0191\u0192\3\2\2\2\u0192"+
		"\u0193\b&%\2\u0193V\3\2\2\2\u0194\u0195\7%\2\2\u0195\u0196\7b\2\2\u0196"+
		"\u0197\7A\2\2\u0197\u0198\7}\2\2\u0198\u0199\3\2\2\2\u0199\u019a\b\'&"+
		"\2\u019aX\3\2\2\2\u019b\u019c\7%\2\2\u019c\u019d\7b\2\2\u019d\u019e\7"+
		"A\2\2\u019e\u019f\3\2\2\2\u019f\u01a0\6(\3\2\u01a0\u01a1\b(\'\2\u01a1"+
		"Z\3\2\2\2\u01a2\u01a3\7%\2\2\u01a3\u01a4\7b\2\2\u01a4\u01a5\7A\2\2\u01a5"+
		"\u01a6\7\177\2\2\u01a6\u01a7\3\2\2\2\u01a7\u01a8\6)\4\2\u01a8\u01a9\b"+
		")(\2\u01a9\\\3\2\2\2:\2\3\4\5\6\7\b\t\n\13\f`juxz\u008b\u008d\u0095\u0097"+
		"\u009f\u00a1\u00a9\u00ab\u00b0\u00be\u00c0\u00ca\u00d2\u00d7\u00d9\u00db"+
		"\u00ec\u00ee\u00f6\u00f8\u0101\u010a\u010c\u0114\u0116\u011f\u0128\u012a"+
		"\u0134\u013b\u0142\u0144\u014c\u014e\u0157\u0163\u0165\u016d\u016f\u0178"+
		")\b\2\2\3\4\2\3\5\3\3\6\4\3\7\5\3\b\6\3\t\7\3\n\b\3\13\t\3\f\n\3\r\13"+
		"\3\16\f\3\17\r\3\20\16\3\21\17\3\22\20\3\23\21\3\24\22\3\25\23\3\26\24"+
		"\3\27\25\3\30\26\3\31\27\3\32\30\3\33\31\3\34\32\3\35\33\3\36\34\3\37"+
		"\35\3 \36\3!\37\3\" \3#!\3$\"\3%#\3&$\3\'%\3(&\3)\'";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}