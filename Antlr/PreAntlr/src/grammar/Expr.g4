grammar Expr;

@lexer::members
{
	AntlrLexer.Environment environment = null;
	
	public ExprLexer(CharStream input, AntlrLexer.Environment environment)
	{
		super(input);
		_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
		
		this.environment = environment;
	}
}

start returns [boolean v]
		:	STR		{$v = StrEval.getBoolean($STR.text);}
		|	o=expr	{$v = StrEval.getBoolean($o.v);}
		;

expr returns [String v]
		:	left=expr '==' right=expr		{$v = StrEval.eq($left.v, $right.v);}
		|	left=expr '!=' right=expr		{$v = StrEval.neq($left.v, $right.v);}
		|	left=expr '<=' right=expr		{$v = StrEval.lteq($left.v, $right.v);}
		|	left=expr '>=' right=expr		{$v = StrEval.gteq($left.v, $right.v);}
		|	left=expr '<' right=expr		{$v = StrEval.lt($left.v, $right.v);}
		|	left=expr '>' right=expr		{$v = StrEval.gt($left.v, $right.v);}
		|	'!' o=expr						{$v = StrEval.n($o.v);}
		|	left=expr '&&' right=expr		{$v = StrEval.and($left.v, $right.v);}
		|	left=expr '||' right=expr		{$v = StrEval.or($left.v, $right.v);}
		|	'(' o=expr ')'					{$v = $o.v;}
		|	STR								{$v = $STR.text;}
		;
		
VAR		:	[a-zA-Z0-9]+
		{
			if (environment != null)
			{
				_text = environment.get(_input.getText(Interval.of(_tokenStartCharIndex, _input.index() - 1)));
			}
			_type = STR;
		}
		;
STR		: 	'"' (~[\\"] | '\\' .)* '"'
		{
			_text = _input.getText(Interval.of(_tokenStartCharIndex + 1, _input.index() - 2));
			
			_text = _text.replace("\\n", "\n");
			_text = _text.replace("\\r", "\r");
			_text = _text.replace("\\t", "\t");
			_text = _text.replace("\\b", "\b");
			_text = _text.replace("\\f", "\f");
			_text = _text.replaceAll("\\\\(.)", "$1");
		}
		;
WS		: [ \r\n\t] -> skip;
