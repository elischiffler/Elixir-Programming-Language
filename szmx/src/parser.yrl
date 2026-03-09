% Documentation of yecc syntax 
% https://www.erlang.org/doc/apps/parsetools/yecc.html

% Nonterminals are the syntatic structure combining the tokens
Nonterminals expr args ids binding bindings.

% Terminals are the tokens that will be produced
Terminals lform rform number identifier string kw_if kw_let kw_in kw_fun 'kw_=' 'kw_=>'.

% The entire input is an expression
Rootsymbol expr.

%% Parses nums
expr -> number :
    begin
        {_Tag,_Line,N} = '$1',
        #{'__struct__' => 'Elixir.SzmxInterpreter.NumC', n => N}
    end.

% Parses strings
expr -> string :
    begin
        {_Tag,_Line,S} = '$1',
        #{'__struct__' => 'Elixir.SzmxInterpreter.StrC', s => S}
    end.

% Parses ids
expr -> identifier :
    begin
        {_Tag,_Line,Id} = '$1',
        #{'__struct__' => 'Elixir.SzmxInterpreter.IdC', s => Id}
    end.

%% Parses if statements
expr -> lform kw_if expr expr expr rform :
    begin
        #{'__struct__' => 'Elixir.SzmxInterpreter.IfC',
            test => '$3', then => '$4', 'else' => '$5'}
    end.

%% Parses function declarations
expr -> lform kw_fun lform ids rform 'kw_=>' expr rform :
    begin
        #{'__struct__' => 'Elixir.SzmxInterpreter.LamC',
            params => '$4', body => '$7'}
    end.

%% Parses application
expr -> lform expr args rform :
    begin
        #{'__struct__' => 'Elixir.SzmxInterpreter.AppC',
            'fun' => '$2', args => '$3'}
    end.

%% Parses arguments
args -> expr args : ['$1' | '$2'].
args -> '$empty' : [].

%% Parses ids as a list of parameters
ids -> identifier ids :
    begin
        {_Tag,_Line,Id} = '$1',
        [Id | '$2']
    end.
ids -> '$empty' : [].

%% Bindings form for let expressions
binding -> lform ids 'kw_=' expr rform : {hd('$2'), '$4'}.
bindings -> binding : ['$1'].
bindings -> binding bindings : ['$1' | '$2'].

expr -> lform kw_let lform bindings rform kw_in expr rform :
    begin
        Params = [Id || {Id, _Val} <- '$4'],
        #{'__struct__' => 'Elixir.SzmxInterpreter.LamC',
          params => Params,
          body => '$7'}
    end.
