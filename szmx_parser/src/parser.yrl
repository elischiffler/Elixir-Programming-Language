% Documentation of yecc syntax 
% https://www.erlang.org/doc/apps/parsetools/yecc.html

% Nonterminals are the syntatic structure combining the tokens
Nonterminals expr args.

% Terminals are the tokens that will be produced
Terminals '{' '}' NumC IdC StrC.

% The entire input is an expression
Rootsymbol expr.

% Rules for how nonterminals are formed by terminals
Rules.
expr -> NumC : {number, $1}.
expr -> IdC : {identifier, $1}.
expr -> StrC : {string, $1}.