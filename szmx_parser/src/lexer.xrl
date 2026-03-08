% Documentation for leex expressions 
% https://www.erlang.org/doc/apps/parsetools/leex.html


% --- Definitions of the basic types for the AST ---
Definitions.
WS = [\s\t\n\r]+
Digit = [0-9]
Num = (\+|-)?{Digit}+(\.{Digit}+)?
Str = \"[^"]*\"
Id = [^{}\[\]\(\)"\s]+
LForm = [\{\(\[]
RForm = [\}\)\]]

% --- How should lexer recognize tokens ---
Rules.
{WS} : skip_token.

{Num} : begin
            case lists:member($., TokenChars) of
                true -> {token, {number, TokenLine, list_to_float(TokenChars)}};
                false -> {token, {number, TokenLine, list_to_integer(TokenChars) * 1.0}}
            end
        end.
{Str} : {token, {string, TokenLine, TokenChars}}.

{LForm} : {token, {lform, TokenLine}}.
{RForm} : {token, {rform, TokenLine}}.

if : {token, {kw_if, TokenLine}}.
let : {token, {kw_let, TokenLine}}.
in : {token, {kw_in, TokenLine}}.
fun : {token, {kw_fun, TokenLine}}.
\= : {token, {'kw_=', TokenLine}}.
\=\> : {token, {'kw_=>', TokenLine}}.

{Id} : {token, {identifier, TokenLine, list_to_binary(TokenChars)}}.

Erlang code.