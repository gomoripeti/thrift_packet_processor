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

%% line field always holds the line number of the name token
%% except for include where name is optional,
%% there it is the line number of the path token

-record(namespace, {name, scope, line}).

-record(include, {name, path, line}).

-record(const, {name, type, value, line}).

-record(enum, {name, fields, line}).

-record(typedef, {name, type, line}).

-record(struct, {name, fields, line}).

-record(field, {id, requiredness, type, name, default, line}).

-record(exception, {name, fields, line}).

-record(service, {name, extends, functions, line}).

-record(function, {is_oneway, return_type, name, fields, throws, line}).

-record(union, {name, fields, line}).
