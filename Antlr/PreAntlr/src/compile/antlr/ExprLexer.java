// Generated from Expr.g4 by ANTLR 4.2
package compile.antlr;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.misc.*;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class ExprLexer extends Lexer {
	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		T__10=1, T__9=2, T__8=3, T__7=4, T__6=5, T__5=6, T__4=7, T__3=8, T__2=9, 
		T__1=10, T__0=11, VAR=12, STR=13, WS=14;
	public static String[] modeNames = {
		"DEFAULT_MODE"
	};

	public static final String[] tokenNames = {
		"<INVALID>",
		"'||'", "'>'", "')'", "'('", "'=='", "'<'", "'!='", "'>='", "'<='", "'!'", 
		"'&&'", "VAR", "STR", "WS"
	};
	public static final String[] ruleNames = {
		"T__10", "T__9", "T__8", "T__7", "T__6", "T__5", "T__4", "T__3", "T__2", 
		"T__1", "T__0", "VAR", "STR", "WS"
	};


		AntlrLexer.Environment environment = null;
		
		public ExprLexer(CharStream input, AntlrLexer.Environment environment)
		{
			super(input);
			_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
			
			this.environment = environment;
		}


	public ExprLexer(CharStream input) {
		super(input);
		_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@Override
	public String getGrammarFileName() { return "Expr.g4"; }

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
		case 11: VAR_action((RuleContext)_localctx, actionIndex); break;

		case 12: STR_action((RuleContext)_localctx, actionIndex); break;
		}
	}
	private void STR_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 1: 
					_text = _input.getText(Interval.of(_tokenStartCharIndex + 1, _input.index() - 2));
					
					_text = _text.replace("\\n", "\n");
					_text = _text.replace("\\r", "\r");
					_text = _text.replace("\\t", "\t");
					_text = _text.replace("\\b", "\b");
					_text = _text.replace("\\f", "\f");
					_text = _text.replaceAll("\\\\(.)", "$1");
				 break;
		}
	}
	private void VAR_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 0: 
					if (environment != null)
					{
						_text = environment.get(_input.getText(Interval.of(_tokenStartCharIndex, _input.index() - 1)));
					}
					_type = STR;
				 break;
		}
	}

	public static final String _serializedATN =
		"\3\u0430\ud6d1\u8206\uad2d\u4417\uaef1\u8d80\uaadd\2\20R\b\1\4\2\t\2\4"+
		"\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b\t\b\4\t\t\t\4\n\t\n\4\13\t"+
		"\13\4\f\t\f\4\r\t\r\4\16\t\16\4\17\t\17\3\2\3\2\3\2\3\3\3\3\3\4\3\4\3"+
		"\5\3\5\3\6\3\6\3\6\3\7\3\7\3\b\3\b\3\b\3\t\3\t\3\t\3\n\3\n\3\n\3\13\3"+
		"\13\3\f\3\f\3\f\3\r\6\r=\n\r\r\r\16\r>\3\r\3\r\3\16\3\16\3\16\3\16\7\16"+
		"G\n\16\f\16\16\16J\13\16\3\16\3\16\3\16\3\17\3\17\3\17\3\17\2\2\20\3\3"+
		"\5\4\7\5\t\6\13\7\r\b\17\t\21\n\23\13\25\f\27\r\31\16\33\17\35\20\3\2"+
		"\5\5\2\62;C\\c|\4\2$$^^\5\2\13\f\17\17\"\"T\2\3\3\2\2\2\2\5\3\2\2\2\2"+
		"\7\3\2\2\2\2\t\3\2\2\2\2\13\3\2\2\2\2\r\3\2\2\2\2\17\3\2\2\2\2\21\3\2"+
		"\2\2\2\23\3\2\2\2\2\25\3\2\2\2\2\27\3\2\2\2\2\31\3\2\2\2\2\33\3\2\2\2"+
		"\2\35\3\2\2\2\3\37\3\2\2\2\5\"\3\2\2\2\7$\3\2\2\2\t&\3\2\2\2\13(\3\2\2"+
		"\2\r+\3\2\2\2\17-\3\2\2\2\21\60\3\2\2\2\23\63\3\2\2\2\25\66\3\2\2\2\27"+
		"8\3\2\2\2\31<\3\2\2\2\33B\3\2\2\2\35N\3\2\2\2\37 \7~\2\2 !\7~\2\2!\4\3"+
		"\2\2\2\"#\7@\2\2#\6\3\2\2\2$%\7+\2\2%\b\3\2\2\2&\'\7*\2\2\'\n\3\2\2\2"+
		"()\7?\2\2)*\7?\2\2*\f\3\2\2\2+,\7>\2\2,\16\3\2\2\2-.\7#\2\2./\7?\2\2/"+
		"\20\3\2\2\2\60\61\7@\2\2\61\62\7?\2\2\62\22\3\2\2\2\63\64\7>\2\2\64\65"+
		"\7?\2\2\65\24\3\2\2\2\66\67\7#\2\2\67\26\3\2\2\289\7(\2\29:\7(\2\2:\30"+
		"\3\2\2\2;=\t\2\2\2<;\3\2\2\2=>\3\2\2\2><\3\2\2\2>?\3\2\2\2?@\3\2\2\2@"+
		"A\b\r\2\2A\32\3\2\2\2BH\7$\2\2CG\n\3\2\2DE\7^\2\2EG\13\2\2\2FC\3\2\2\2"+
		"FD\3\2\2\2GJ\3\2\2\2HF\3\2\2\2HI\3\2\2\2IK\3\2\2\2JH\3\2\2\2KL\7$\2\2"+
		"LM\b\16\3\2M\34\3\2\2\2NO\t\4\2\2OP\3\2\2\2PQ\b\17\4\2Q\36\3\2\2\2\6\2"+
		">FH\5\3\r\2\3\16\3\b\2\2";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}