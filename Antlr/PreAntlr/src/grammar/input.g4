//arguments
[
	hello		//first argument
	boo			//second argument
	what		//third argument
]

R: 'a';

#`?{"4" == "4"`
	R[[a]];
	#`?{"4" == "4"`
		R[[c]];
	#`?}
	#`?"4" == "4"`
	R[[b]];
#`?}

#`?{"4" == "4"`
	R[[a]];
	#`?{"4" == "4"`
		R[[c]];
	#`?}
	#`?"4" == "4"`
	R[[b]];
#`?}

#`>"grammar\\input2.g4" "v5" "3" "what?"`

#`?{"4" == "4"`
	R[[a]];
#`?}
R: 'b';