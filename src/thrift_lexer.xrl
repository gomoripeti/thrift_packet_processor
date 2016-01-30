%% Copyright 2016 Péter Gömöri
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

Definitions.

%% from thrift.ll
INTCONSTANT   = [+-]?[0-9]+
HEXCONSTANT   = 0x[0-9A-Fa-f]+
DUBCONSTANT   = [+-]?[0-9]+\.[0-9]*([eE][+-]?[0-9]+)?
WHITESPACE    = [\s\t\r\n]
SYMBOL        = [:;\,\*\{\}\(\)\=<>\[\]]

%% from thriftpy/lexer.py
SILLYCOMM     = /\*\**\*/
MULTICOMM     = /\*[^*]/*([^*/]|[^*]/|\*[^/])*\**\*/
DOCTEXT       = /\*\*([^*/]|[^*]/|\*[^/])*\**\*/
UNIXCOMMENT   = \#[^\n]*
COMMENT       = //[^\n]*

BOOLCONSTANT  = true|false
LITERAL       = (\"([^\\\n]|(\\.))*?\")|\'([^\\\n]|(\\.))*?\'

IDENTIFIER    = [a-zA-Z_](\.[a-zA-Z_0-9]|[a-zA-Z_0-9])*

KEYWORD       = namespace|include|void|bool|byte|i8|i16|i32|i64|double|string|binary|map|list|set|oneway|typedef|struct|union|exception|extends|throws|service|enum|const|required|optional

Rules.

{SYMBOL}       : {token, {list_to_atom(TokenChars), TokenLine}}.
{WHITESPACE}   : skip_token.
{SILLYCOMM}    : skip_token.
{MULTICOMM}    : skip_token.
{DOCTEXT}      : skip_token. %% skiped by thriftpy but not by apache
%{DOCTEXT}      : {token, {doctext, TokenLine, TokenChars}}.
{COMMENT}      : skip_token.
{UNIXCOMMENT}  : skip_token.

{BOOLCONSTANT} : {token, {boolconstant, TokenLine, TokenChars =:= "true"}}.
{HEXCONSTANT}  : {token, {hexconstant, TokenLine,
                          list_to_integer(lists:nthtail(2,TokenChars), 16)}}.
{INTCONSTANT}  : {token, {intconstant, TokenLine,
                          list_to_integer(TokenChars)}}.
{DUBCONSTANT}  : {token, {dubconstant, TokenLine,
                          list_to_float(TokenChars)}}.
{LITERAL}      : {token, {literal, TokenLine, string:strip(TokenChars, both, $\")}}.

{KEYWORD}      : {token, {list_to_atom(TokenChars), TokenLine}}.
{IDENTIFIER}   : {token, {identifier, TokenLine, TokenChars}}.

Erlang code.
