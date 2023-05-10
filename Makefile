tudo: 	
		clear
		lex LanguageLexa.l
		yacc -d LanguageSintatica.y
		g++ -o teste y.tab.c -ll

		./teste < Testes.pl
