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

Nonterminals Document Headers Header
 Include Namespace NamespaceScope
 Definitions Definition
 Const ConstValue ConstList ConstListItems
 ConstMap ConstMapItems ConstMapItem
 Typedef
 Enum EnumList EnumItem
 ContainerType DefinitionType BaseType
 ListSeparator ListType MapType SetType RefType
 Field FieldId FieldList FieldReq FieldType
 Struct
 Function FunctionList FunctionType Oneway Throws
 Exception Service Union.

Terminals '(' ')' ',' ':' ';' '<' '=' '>' '[' ']' '{' '}' '*' binary bool byte
 const double dubconstant enum exception extends i8 i16 i32 i64 identifier
 include intconstant list literal map namespace oneway optional required service
 set slist string struct throws typedef union void.

Rootsymbol Document.


%    [1]  Document        ::=  Header* Definition*
Document        -> Headers Definitions : '$1' ++ '$2'.

Headers         -> Header Headers : ['$1' | '$2'].
Headers         -> '$empty' : [].

Definitions     -> Definition Definitions : ['$1' | '$2'].
Definitions     -> '$empty' : [].

%[2]  Header          ::=  Include | CppInclude | Namespace
%[3]  Include         ::=  'include' Literal
%[5]  Namespace       ::=  ( 'namespace' ( NamespaceScope Identifier ) |
%                                        ( 'smalltalk.category' STIdentifier ) |
%                                        ( 'smalltalk.prefix' Identifier ) ) |
%                          ( 'php_namespace' Literal ) |
%                          ( 'xsd_namespace' Literal )
%[6]  NamespaceScope  ::=  '*' | 'cpp' | 'java' | 'py' | 'perl' | 'rb' | 'cocoa' | 'csharp'

Header          -> Include : '$1'.
Header          -> Namespace : '$1'.

Include         -> include identifier literal
                       : {include, '$2', '$3', line_of('$3')}.
Include         -> include literal
                       : {include, undefined, '$2', line_of('$2')}.

Namespace       -> namespace NamespaceScope identifier
                       : {namespace, value_of('$3'), '$2', line_of('$3')}.

NamespaceScope  -> '*' : '*'.
NamespaceScope  -> identifier : value_of('$1').

%[7]  Definition      ::=  Const | Typedef | Enum | Senum | Struct | Union | Exception | Service
Definition      -> Const : '$1'.
Definition      -> Typedef : '$1'.
Definition      -> Enum : '$1'.
%Definition      -> Senum : '$1'.
Definition      -> Struct : '$1'.
Definition      -> Union : '$1'.
Definition      -> Exception : '$1'.
Definition      -> Service : '$1'.

%[8]  Const           ::=  'const' FieldType Identifier '=' ConstValue ListSeparator?
%[32] ConstValue      ::=  IntConstant | DoubleConstant | Literal | Identifier | ConstList | ConstMap
%[33] IntConstant     ::=  ('+' | '-')? Digit+
%[34] DoubleConstant  ::=  ('+' | '-')? Digit* ('.' Digit+)? ( ('E' | 'e') IntConstant )?
%[35] ConstList       ::=  '[' (ConstValue ListSeparator?)* ']'
%[36] ConstMap        ::=  '{' (ConstValue ':' ConstValue ListSeparator?)* '}'

%% {const, Type, Name, Value}
Const           -> const FieldType identifier '=' ConstValue ListSeparator
                       : {const, value_of('$3'), '$2', '$5', line_of('$3')}.
Const           -> const FieldType identifier '=' ConstValue
                       : {const, value_of('$3'), '$2', '$5', line_of('$3')}.

ConstValue      -> intconstant : value_of('$1').
ConstValue      -> dubconstant : value_of('$1').
ConstValue      -> literal : value_of('$1').
ConstValue      -> identifier : value_of('$1').
ConstValue      -> ConstList : '$1'.
ConstValue      -> ConstMap : '$1'.

ConstList       -> '[' ConstListItems ']' : '$2'.

ConstListItems  -> ConstValue ConstListItems : ['$1' | '$2'].
ConstListItems  -> ConstValue ListSeparator ConstListItems : ['$1' | '$3'].
ConstListItems  -> '$empty' : [].

ConstMap        -> '{' ConstMapItems '}' : {map, '$2'}.

ConstMapItems   -> ConstMapItem ConstMapItems : ['$1' | '$2'].
ConstMapItems   -> ConstMapItem ListSeparator ConstMapItems: ['$1' | '$3'].
ConstMapItems   -> '$empty' : [].

ConstMapItem    -> ConstValue ':' ConstValue : {'$1', '$3'}.

%[9]  Typedef         ::=  'typedef' DefinitionType Identifier

Typedef         -> typedef FieldType identifier
                       : {typedef, value_of('$3'), '$2', line_of('$3')}.

%[10] Enum            ::=  'enum' Identifier '{' (Identifier ('=' IntConstant)? ListSeparator?)* '}'

Enum            -> enum identifier '{' EnumList '}'
                       : {enum, value_of('$2'), '$4', line_of('$2')}.

EnumList        -> EnumItem EnumList : ['$1' | '$2'].
EnumList        -> EnumItem ListSeparator EnumList : ['$1' | '$3'].
EnumList        -> '$empty' : [].

EnumItem        -> identifier '=' intconstant : {value_of('$1'), value_of('$3')}.
EnumItem        -> identifier : {value_of('$1'), undefined}.

% [12] Struct          ::=  'struct' Identifier 'xsd_all'? '{' Field* '}'

Struct          -> struct identifier '{' FieldList '}'
                       : {struct, value_of('$2'), '$4', line_of('$2')}.

FieldList       -> Field FieldList : ['$1' | '$2'].
FieldList       -> Field ListSeparator FieldList : ['$1' | '$3'].
FieldList       -> '$empty' : [].

ListSeparator   -> ','.
ListSeparator   -> ';'.

%[16] Field           ::=  FieldID? FieldReq? FieldType Identifier ('= ConstValue)? XsdFieldOptions ListSeparator?

Field           -> FieldId FieldReq FieldType identifier
                       : {field, value_of('$1'), '$2', '$3',
                          value_of('$4'), undefined, line_of('$4')}.
Field           -> FieldId FieldReq FieldType identifier '=' ConstValue
                       : {field, value_of('$1'), '$2', '$3',
                          value_of('$4'), '$6', line_of('$4')}.

FieldId         -> intconstant ':' : '$1'.
FieldId         -> '$empty' : undefined.

FieldReq        -> required : value_of('$1').
FieldReq        -> optional : value_of('$1').
FieldReq        -> '$empty' : undefined.

%[24] FieldType       ::=  Identifier | BaseType | ContainerType
%[25] DefinitionType  ::=  BaseType | ContainerType
%[26] BaseType        ::=  'bool' | 'byte' | 'i16' | 'i32' | 'i64' | 'double' | 'string' | 'binary' | 'slist'
%[27] ContainerType   ::=  MapType | SetType | ListType
%[28] MapType         ::=  'map' CppType? '<' FieldType ',' FieldType '>'
%[29] SetType         ::=  'set' CppType? '<' FieldType '>'
%[30] ListType        ::=  'list' '<' FieldType '>' CppType?

FieldType       -> RefType : '$1'.
FieldType       -> DefinitionType : '$1'.

RefType         -> identifier : value_of('$1').

DefinitionType  -> BaseType : value_of('$1').
DefinitionType  -> ContainerType : '$1'.

% slist is deprecated
BaseType        -> bool : '$1'.
BaseType        -> byte : '$1'.
BaseType        -> i8 : '$1'.
BaseType        -> i16 : '$1'.
BaseType        -> i32 : '$1'.
BaseType        -> i64 : '$1'.
BaseType        -> double : '$1'.
BaseType        -> string : '$1'.
BaseType        -> binary : '$1'.
BaseType        -> slist : '$1'.

ContainerType   -> MapType : '$1'.
ContainerType   -> SetType : '$1'.
ContainerType   -> ListType : '$1'.

MapType         -> map '<' FieldType ',' FieldType '>' : {map, '$3', '$5'}.
SetType         -> set '<' FieldType '>' : {set, '$3'}.
ListType        -> list '<' FieldType '>' : {list, '$3'}.

%[13] Union           ::=  'union' Identifier 'xsd_all'? '{' Field* '}'
Union           -> union identifier '{' FieldList '}'
                       : {union, value_of('$2'), '$4', line_of('$2')}.

%[14] Exception       ::=  'exception' Identifier '{' Field* '}'
Exception       -> exception identifier '{' FieldList '}'
                       : {exception, value_of('$2'), '$4', line_of('$2')}.

%[15] Service         ::=  'service' Identifier ( 'extends' Identifier )? '{' Function* '}'
%[21] Function        ::=  'oneway'? FunctionType Identifier '(' Field* ')' Throws? ListSeparator?
%[22] FunctionType    ::=  FieldType | 'void'
%[23] Throws          ::=  'throws' '(' Field* ')'

Service         -> service identifier '{' FunctionList '}'
                       : {service, value_of('$2'), undefined, '$4', line_of('$2')}.
Service         -> service identifier extends identifier '{' FunctionList '}'
                       : {service, value_of('$2'), '$3', '$5', line_of('$2')}.

FunctionList    -> Function FunctionList : ['$1' | '$2'].
FunctionList    -> Function ListSeparator FunctionList : ['$1' | '$3'].
FunctionList    -> '$empty' : [].

Function        -> Oneway FunctionType identifier '(' FieldList ')' Throws
                       : {function, '$1', '$2', value_of('$3'), '$5', '$7', line_of('$3')}.

Oneway          -> oneway : true.
Oneway          -> '$empty' : false.

FunctionType    -> FieldType : '$1'.
FunctionType    -> void : void.

Throws          -> throws '(' FieldList ')' : '$3'.
Throws          -> '$empty' : [].

Erlang code.

value_of({Value, _}) ->
    Value;
value_of({_, _, Value}) ->
    Value.

line_of(Token) ->
    element(2, Token).
