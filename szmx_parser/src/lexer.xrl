% Documentation for leex expressions 
% https://www.erlang.org/doc/apps/parsetools/leex.html


% --- Definitions of the basic types for the AST ---
Definitions.
Digit = [0-9]
Letter = [a-zA-Z]
NumC = (\+|-)?{Digit}+\.?{Digit}*
IdC = {Letter}({Letter}|{Digit})*
StrC = \"({Letter}|{Digit}|\s)\"

% --- How should lexer recognize tokens ---
Rules.
{NumC} : {token, {number, TokenLine, list_to_float(TokenChars)}}.
{IdC}  : {token, {identifier, TokenLine, TokenChars}}.
{StrC} : {token, {string, TokenLine, TokenChars}}.


Erlang code.