%%% @author Péter Gömöri <gomoripeti@gmail.com>
%%% @copyright 2016, Péter Gömöri
%%% @doc
%%%     Example usage of the Thrift IDL lexer/parser
%%% @end
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.

-module(thrift_idl).

-export([parse_file/1,
         parse_string/1
        ]).

-include("../include/thrift_idl.hrl").

-record(model, {namespaces = [],
                includes = [],
                constants = [],
                typedefs = [],
                enums = [],
                structs = [],
                unions = [],
                exceptions = [],
                services = []}).

parse_file(File) ->
    {ok, Bin} = file:read_file(File),
    Str = binary_to_list(Bin),
    parse_string(Str).

parse_string(Str) ->
    {ok, Tokens, _EndLine} = thrift_lexer:string(Str),
    {ok, Tree} = thrift_parser:parse(Tokens),
    create_model(Tree).

create_model(Tree) ->
    Dict =
        lists:foldl(
          fun(Def, Acc) ->
                  dict:append(element(1, Def), Def, Acc)
          end, dict:new(), Tree),
    dict:fold(
      fun(namespace, L, M) ->
              M#model{namespaces = L};
         (include, L, M) ->
              M#model{includes = L};
         (const, L, M) ->
              M#model{constants = L};
         (typedef, L, M) ->
              M#model{typedefs = L};
         (enum, L, M) ->
              M#model{enums = L};
         (struct, L, M) ->
              M#model{structs = L};
         (union, L, M) ->
              M#model{unions = L};
         (exception, L, M) ->
              M#model{exceptions = L};
         (service, L, M) ->
              M#model{services = L};
         (_, _, M) ->
              M
      end, #model{}, Dict).

