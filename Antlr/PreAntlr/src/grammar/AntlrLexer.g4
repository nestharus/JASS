lexer grammar AntlrLexer;

@header
{
	import org.antlr.v4.runtime.ANTLRFileStream;
	
	import java.util.HashMap;
	import java.util.Stack;
	import java.util.LinkedList;
	import java.util.Map;
}

tokens
{
	SCRIPT
}

@members
{
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
}

/*
 * if type is less than 0, skip
 * type only matters if not continue
 * 
 * 		- params
 * 			String ... searchStrings
 * 			String closingString
 * 
 * 			int useType
 * 			int goToMode
 * 
 * 			boolean continue
 * 
 * 		- conditions
 * 			private boolean la(stringsThatMustBeFound)
 * 				returns true if any of these are found
 * 
 * 			private boolean nla(stringsThatMustNotBeFound)
 * 				returns true if none of the strings are found
 * 
 * 		- consumes next token if continue
 * 			boolean cont(useType, continue?)
 * 			boolean cont(goToMode, stringsThatMustBeFound)
 * 			boolean ncont(goToMode, stringsThatMustNotBeFound)
 *
 * 		- goes to mode and consumes next token if continue
 * 			boolean push(closingString, goToMode, useType, continue?)
 * 			boolean push(closingString, goToMode, useType, stringsThatMustBeFound)
 * 			boolean npush(String closingString, goToMode, useType, stringsThatMustNotBeFound)
 *
 * 		- pops from mode and consumes next token if continue
 * 			boolean pop(useType, continue?)
 * 			boolean pop(useType, stringsThatMustBeFound)
 * 			boolean npop(useType, stringsThatMustNotBeFound)
 * 
 * 		boolean environment.open(filename)
 * 		environment.define(symbol, value)
 * 		environment.undefine(symbol)
 * 		string environment.get(symbol)
 * 		environment.pushArg(arg)
 * 		String environment.popArg()
 * 		environment.clearArgs()
 * 		String getCurrentText()
 * 		String getCurrentText(start, end)
 */

WS								:	[ \t\r\n]+
								-> skip
								;
COMMENTS						:	(	'/*' .*? '*/'
									| 	'//' ~[\r\n]*
									)+
								-> skip
								;
								
ARGUMENTS						:	'['
								{
									_mode = Normal;
									push("]", Arguments, -1, false);
								}
								;
ANY								:	.
								{
									_mode = Normal;
									_input.seek(_input.index() - 1);
									skip();
								}
								;

mode Normal
;
CHAR_SEQUENCE					: 	(	~[`\'"\[\]\\*/#]
									|	WS
									|	COMMENTS
									| 	'`' (~[\\`] | '\\' .)* '`'				//	`	`
									| 	'"' (~[\\"] | '\\' .)* '"'				//	"	"
									| 	'[' (~[\\\]\[] | '\\' .)* ']'			//	[	]
									| 	'\'' (~[\\\'] | '\\' .)* '\''			//	'	'
									|	'#'
									|	'/'
									|	'*'
									)
								{
									ncont(SCRIPT, "#`");
										
									if (!enabled)
									{
										skip();
									}
								}
								;
PARAM_START						:	'['
								{
									push("]", Param, SCRIPT, true);
								}
								;
PRE_START						:	'#`'
								{
									pushMode(Pre);
									_input.seek(_input.index() - 2);
									skip();
								}
								;
mode Arguments
;
	Arguments_WS				: 	(WS | COMMENTS)+
								{
									skip();
								}
								;
	Arguments_RBRACK			: 	']'
								{
									if (enabled)
									{
										environment.clearArgs();
									}
									
									pop(-1, false);
								}
								;
	Arguments_ARGUMENT			: 	[_a-zA-Z0-9]+
								{
									if (enabled)
									{
										environment.define(getCurrentText(0, -1), environment.popArg());
									}
									
									skip();
								}
								;
mode Param
;
	Param_ANY					: 	(	~[\][#`]
									| 	'\\' (~[\]] | EOF)
									|	'#' (~[`] | EOF)
									)+
								{
									ncont(SCRIPT, "#`");
									
									if (!enabled)
									{
										skip();
									}
								}
								;
	Param_PARAM_START			:	'['
								{
									npush("]", Param, SCRIPT, "#`");
								}
								;
	Param_END					: 	']'
								{
									npop(SCRIPT, "#`");
									
									if (!enabled)
									{
										skip();
									}
								}
								;
	Param_PRE_START				:	'#`'
								{
									pushMode(Pre);
									_input.seek(_input.index() - 2);
									skip();
								}
								;
mode Import
;
	Import_WS					: 	(WS | COMMENTS)+ 			{skip();};
	Import_FILE					: 	'"' (~[\\"] | '\\' .)* '"'
								{
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
								}
								;
	Imporg_ARG_READ			:	[_a-zA-Z0-9]+
								{
									if (enabled)
									{
										environment.pushArg(environment.get(getCurrentText(0, -1)));
									}
									
									skip();
									
									_mode = ImportArg;
								}
								;
	Import_END					: 	'`'
								{
									pop(-1, false);
									
									if (enabled)
									{
										environment.open(environment.popArg());
									}
								}
								;
mode ImportArg
;
	ImportArg_WS				: 	(WS | COMMENTS)+ 			{skip();};
	ImportArg_ARG				: 	'"' (~[\\"] | '\\' .)* '"'
								{
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
								}
								;
	ImportArg_ARG_READ			:	[_a-zA-Z0-9]+
								{
									if (enabled)
									{
										environment.pushArg(environment.get(getCurrentText(0, -1)));
									}
									
									skip();
								}
								;
	ImportArg_END				: 	'`'
								{
									pop(-1, false);
									
									if (enabled)
									{
										environment.open(environment.popArg());
									}
								}
								;
mode Arg
;
	Arg_WS					: 	(WS | COMMENTS)+ {cont(-1, false);};
	Arg_END					: 	'`'
							{
								pop(-1, false);
							}
							;
	Arg_VAL				: 	[_a-zA-Z0-9]+
							{
								if (enabled)
								{
									_text = environment.get(getCurrentText(0, -1));
									_type = SCRIPT;
								}
								else
								{
									skip();
								}
							}
							;
mode Eval
;
	Eval_EXPR				:	.+? '`'
							{
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
							}
							;
//	#`>"filename" "arg1" "arg2" "arg3" arg4`
//
//	#`arg`
//
//	#`?{x == 4`
//	#`? x == 5`
//	#`? x == 6`
//	#`?}
//
//	#`{package[args]
//	#`}
mode Package
;
	Package_WS					: 	(WS | COMMENTS)+ 			{skip();};
	Package_FILE				: 	'"' (~[\\"] | '\\' .)* '"'
								{
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
								}
								;
	Package_FILE_READ			:	[_a-zA-Z0-9]+
								{
									if (enabled)
									{
										environment.pushArg(environment.get(getCurrentText()));
									}
									
									skip();
								}
								;
	Package_END					: 	'#`}'
								{
									pop(-1, false);
									
									if (enabled)
									{
										environment.openPackage(environment.popArg());
									}
								}
								;
mode PackageArg
;
	PackageArg_WS				: 	(WS | COMMENTS)+ 			{skip();};
	PackageArg_ARG				: 	'"' (~[\\"] | '\\' .)* '"'
								{
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
								}
								;
	PackageArg_ARG_READ			:	[_a-zA-Z0-9]+
								{
									if (enabled)
									{
										environment.pushArg(environment.get(getCurrentText()));
									}
									
									skip();
								}
								;
	PackageArg_END				: 	'#`}'
								{
									pop(-1, false);
									
									if (enabled)
									{
										environment.openPackage(environment.popArg());
									}
								}
								;
mode Pre
;
	Pre_IMPORT_START				:	'#`>'
									{
										popMode();
										push("`", Import, -1, false);
									}
									;
	Pre_PACKAGE_START				:	{false}? '#`{'
									{
										popMode();
										push("#`}", Package, -1, false);
									}
									;
	Pre_ARG_START					:	'#`'
									{
										popMode();
										push("`", Arg, -1, false);
									}
									;
	Pre_EVAL_CHAIN_START			:	'#`?{'
									{
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
									}
									;
	Pre_EVAL_START					:	'#`?'	{!block.isEmpty() && block.peek().close == "#`?}"}?
									{
										popMode();
										push("`", Eval, -1, false);
									}
									;
	Pre_EVAL_CHAIN_END				:	'#`?}' 	{!block.isEmpty() && block.peek().close == "#`?}"}?
									{
										popMode();
										pop(-1, false);
										
										enabled = enabledStack.pop();
										disabled = disabledStack.pop();
									}
									;