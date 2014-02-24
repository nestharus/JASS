//arguments
[
	version		//first argument
	count		//second argument
	123what		//third argument
]


#`?{count > "0"`
	//Test#`version`:		#`123what`
	#`>"grammar\\input3.g4" count`
	#`?{count > "1"`
		//Test#`version`:		#`123what`
		#`>"grammar\\input3.g4" 123what`
	#`?}
#`?count > "1"`
	Test#`version`:		#`123what`
	Test#`version`:		#`123what`
	Test#`version`:		#`123what`
	Test#`version`:		#`123what`
	Test#`version`:		#`123what`
	Test#`version`:		#`123what`
#`?}

#`>"grammar\\input3.g4" 123what`