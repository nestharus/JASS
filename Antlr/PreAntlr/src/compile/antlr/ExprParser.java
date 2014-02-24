// Generated from Expr.g4 by ANTLR 4.2
package compile.antlr;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.runtime.tree.*;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class ExprParser extends Parser {
	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		T__10=1, T__9=2, T__8=3, T__7=4, T__6=5, T__5=6, T__4=7, T__3=8, T__2=9, 
		T__1=10, T__0=11, VAR=12, STR=13, WS=14;
	public static final String[] tokenNames = {
		"<INVALID>", "'||'", "'>'", "')'", "'('", "'=='", "'<'", "'!='", "'>='", 
		"'<='", "'!'", "'&&'", "VAR", "STR", "WS"
	};
	public static final int
		RULE_start = 0, RULE_expr = 1;
	public static final String[] ruleNames = {
		"start", "expr"
	};

	@Override
	public String getGrammarFileName() { return "Expr.g4"; }

	@Override
	public String[] getTokenNames() { return tokenNames; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public ATN getATN() { return _ATN; }

	public ExprParser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}
	public static class StartContext extends ParserRuleContext {
		public boolean v;
		public Token STR;
		public ExprContext o;
		public ExprContext expr() {
			return getRuleContext(ExprContext.class,0);
		}
		public TerminalNode STR() { return getToken(ExprParser.STR, 0); }
		public StartContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_start; }
	}

	public final StartContext start() throws RecognitionException {
		StartContext _localctx = new StartContext(_ctx, getState());
		enterRule(_localctx, 0, RULE_start);
		try {
			setState(9);
			switch ( getInterpreter().adaptivePredict(_input,0,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(4); ((StartContext)_localctx).STR = match(STR);
				((StartContext)_localctx).v =  StrEval.getBoolean((((StartContext)_localctx).STR!=null?((StartContext)_localctx).STR.getText():null));
				}
				break;

			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(6); ((StartContext)_localctx).o = expr(0);
				((StartContext)_localctx).v =  StrEval.getBoolean(((StartContext)_localctx).o.v);
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ExprContext extends ParserRuleContext {
		public String v;
		public ExprContext left;
		public ExprContext o;
		public Token STR;
		public ExprContext right;
		public List<ExprContext> expr() {
			return getRuleContexts(ExprContext.class);
		}
		public ExprContext expr(int i) {
			return getRuleContext(ExprContext.class,i);
		}
		public TerminalNode STR() { return getToken(ExprParser.STR, 0); }
		public ExprContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_expr; }
	}

	public final ExprContext expr() throws RecognitionException {
		return expr(0);
	}

	private ExprContext expr(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		ExprContext _localctx = new ExprContext(_ctx, _parentState);
		ExprContext _prevctx = _localctx;
		int _startState = 2;
		enterRecursionRule(_localctx, 2, RULE_expr, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(23);
			switch (_input.LA(1)) {
			case 10:
				{
				setState(12); match(10);
				setState(13); ((ExprContext)_localctx).o = expr(5);
				((ExprContext)_localctx).v =  StrEval.n(((ExprContext)_localctx).o.v);
				}
				break;
			case 4:
				{
				setState(16); match(4);
				setState(17); ((ExprContext)_localctx).o = expr(0);
				setState(18); match(3);
				((ExprContext)_localctx).v =  ((ExprContext)_localctx).o.v;
				}
				break;
			case STR:
				{
				setState(21); ((ExprContext)_localctx).STR = match(STR);
				((ExprContext)_localctx).v =  (((ExprContext)_localctx).STR!=null?((ExprContext)_localctx).STR.getText():null);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			_ctx.stop = _input.LT(-1);
			setState(67);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,3,_ctx);
			while ( _alt!=2 && _alt!=-1 ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					setState(65);
					switch ( getInterpreter().adaptivePredict(_input,2,_ctx) ) {
					case 1:
						{
						_localctx = new ExprContext(_parentctx, _parentState);
						_localctx.left = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_expr);
						setState(25);
						if (!(precpred(_ctx, 11))) throw new FailedPredicateException(this, "precpred(_ctx, 11)");
						setState(26); match(5);
						setState(27); ((ExprContext)_localctx).right = expr(12);
						((ExprContext)_localctx).v =  StrEval.eq(((ExprContext)_localctx).left.v, ((ExprContext)_localctx).right.v);
						}
						break;

					case 2:
						{
						_localctx = new ExprContext(_parentctx, _parentState);
						_localctx.left = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_expr);
						setState(30);
						if (!(precpred(_ctx, 10))) throw new FailedPredicateException(this, "precpred(_ctx, 10)");
						setState(31); match(7);
						setState(32); ((ExprContext)_localctx).right = expr(11);
						((ExprContext)_localctx).v =  StrEval.neq(((ExprContext)_localctx).left.v, ((ExprContext)_localctx).right.v);
						}
						break;

					case 3:
						{
						_localctx = new ExprContext(_parentctx, _parentState);
						_localctx.left = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_expr);
						setState(35);
						if (!(precpred(_ctx, 9))) throw new FailedPredicateException(this, "precpred(_ctx, 9)");
						setState(36); match(9);
						setState(37); ((ExprContext)_localctx).right = expr(10);
						((ExprContext)_localctx).v =  StrEval.lteq(((ExprContext)_localctx).left.v, ((ExprContext)_localctx).right.v);
						}
						break;

					case 4:
						{
						_localctx = new ExprContext(_parentctx, _parentState);
						_localctx.left = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_expr);
						setState(40);
						if (!(precpred(_ctx, 8))) throw new FailedPredicateException(this, "precpred(_ctx, 8)");
						setState(41); match(8);
						setState(42); ((ExprContext)_localctx).right = expr(9);
						((ExprContext)_localctx).v =  StrEval.gteq(((ExprContext)_localctx).left.v, ((ExprContext)_localctx).right.v);
						}
						break;

					case 5:
						{
						_localctx = new ExprContext(_parentctx, _parentState);
						_localctx.left = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_expr);
						setState(45);
						if (!(precpred(_ctx, 7))) throw new FailedPredicateException(this, "precpred(_ctx, 7)");
						setState(46); match(6);
						setState(47); ((ExprContext)_localctx).right = expr(8);
						((ExprContext)_localctx).v =  StrEval.lt(((ExprContext)_localctx).left.v, ((ExprContext)_localctx).right.v);
						}
						break;

					case 6:
						{
						_localctx = new ExprContext(_parentctx, _parentState);
						_localctx.left = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_expr);
						setState(50);
						if (!(precpred(_ctx, 6))) throw new FailedPredicateException(this, "precpred(_ctx, 6)");
						setState(51); match(2);
						setState(52); ((ExprContext)_localctx).right = expr(7);
						((ExprContext)_localctx).v =  StrEval.gt(((ExprContext)_localctx).left.v, ((ExprContext)_localctx).right.v);
						}
						break;

					case 7:
						{
						_localctx = new ExprContext(_parentctx, _parentState);
						_localctx.left = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_expr);
						setState(55);
						if (!(precpred(_ctx, 4))) throw new FailedPredicateException(this, "precpred(_ctx, 4)");
						setState(56); match(11);
						setState(57); ((ExprContext)_localctx).right = expr(5);
						((ExprContext)_localctx).v =  StrEval.and(((ExprContext)_localctx).left.v, ((ExprContext)_localctx).right.v);
						}
						break;

					case 8:
						{
						_localctx = new ExprContext(_parentctx, _parentState);
						_localctx.left = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_expr);
						setState(60);
						if (!(precpred(_ctx, 3))) throw new FailedPredicateException(this, "precpred(_ctx, 3)");
						setState(61); match(1);
						setState(62); ((ExprContext)_localctx).right = expr(4);
						((ExprContext)_localctx).v =  StrEval.or(((ExprContext)_localctx).left.v, ((ExprContext)_localctx).right.v);
						}
						break;
					}
					} 
				}
				setState(69);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,3,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public boolean sempred(RuleContext _localctx, int ruleIndex, int predIndex) {
		switch (ruleIndex) {
		case 1: return expr_sempred((ExprContext)_localctx, predIndex);
		}
		return true;
	}
	private boolean expr_sempred(ExprContext _localctx, int predIndex) {
		switch (predIndex) {
		case 0: return precpred(_ctx, 11);

		case 1: return precpred(_ctx, 10);

		case 2: return precpred(_ctx, 9);

		case 3: return precpred(_ctx, 8);

		case 4: return precpred(_ctx, 7);

		case 5: return precpred(_ctx, 6);

		case 6: return precpred(_ctx, 4);

		case 7: return precpred(_ctx, 3);
		}
		return true;
	}

	public static final String _serializedATN =
		"\3\u0430\ud6d1\u8206\uad2d\u4417\uaef1\u8d80\uaadd\3\20I\4\2\t\2\4\3\t"+
		"\3\3\2\3\2\3\2\3\2\3\2\5\2\f\n\2\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3"+
		"\3\3\3\3\3\5\3\32\n\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3"+
		"\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3"+
		"\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\7\3D\n\3\f\3\16\3G\13\3\3\3"+
		"\2\3\4\4\2\4\2\2Q\2\13\3\2\2\2\4\31\3\2\2\2\6\7\7\17\2\2\7\f\b\2\1\2\b"+
		"\t\5\4\3\2\t\n\b\2\1\2\n\f\3\2\2\2\13\6\3\2\2\2\13\b\3\2\2\2\f\3\3\2\2"+
		"\2\r\16\b\3\1\2\16\17\7\f\2\2\17\20\5\4\3\7\20\21\b\3\1\2\21\32\3\2\2"+
		"\2\22\23\7\6\2\2\23\24\5\4\3\2\24\25\7\5\2\2\25\26\b\3\1\2\26\32\3\2\2"+
		"\2\27\30\7\17\2\2\30\32\b\3\1\2\31\r\3\2\2\2\31\22\3\2\2\2\31\27\3\2\2"+
		"\2\32E\3\2\2\2\33\34\f\r\2\2\34\35\7\7\2\2\35\36\5\4\3\16\36\37\b\3\1"+
		"\2\37D\3\2\2\2 !\f\f\2\2!\"\7\t\2\2\"#\5\4\3\r#$\b\3\1\2$D\3\2\2\2%&\f"+
		"\13\2\2&\'\7\13\2\2\'(\5\4\3\f()\b\3\1\2)D\3\2\2\2*+\f\n\2\2+,\7\n\2\2"+
		",-\5\4\3\13-.\b\3\1\2.D\3\2\2\2/\60\f\t\2\2\60\61\7\b\2\2\61\62\5\4\3"+
		"\n\62\63\b\3\1\2\63D\3\2\2\2\64\65\f\b\2\2\65\66\7\4\2\2\66\67\5\4\3\t"+
		"\678\b\3\1\28D\3\2\2\29:\f\6\2\2:;\7\r\2\2;<\5\4\3\7<=\b\3\1\2=D\3\2\2"+
		"\2>?\f\5\2\2?@\7\3\2\2@A\5\4\3\6AB\b\3\1\2BD\3\2\2\2C\33\3\2\2\2C \3\2"+
		"\2\2C%\3\2\2\2C*\3\2\2\2C/\3\2\2\2C\64\3\2\2\2C9\3\2\2\2C>\3\2\2\2DG\3"+
		"\2\2\2EC\3\2\2\2EF\3\2\2\2F\5\3\2\2\2GE\3\2\2\2\6\13\31CE";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}