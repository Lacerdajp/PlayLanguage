tudo: 	
		clear
		lex LanguageLexa.l
		yacc -d -v LanguageSintatica.y
		g++ -o teste y.tab.c -ll

		./teste < Testes.pl
