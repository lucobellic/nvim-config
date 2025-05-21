"import" @keyword.control.import
(import (NAME) @namespace)

["struct" "enum" "variant"] @keyword.storage.type
["node" "interface"] @keyword.storage.type

["metrics" "params"] @keyword

["public_ref"] @keyword

["port" "rpc_port"] @keyword.storage.type
[
  (node_port_in)
  (node_port_out)
  (std_port_decl)
  (rpc_port_decl)
] @keyword.storage.modifier

["{" "}"] @punctuation.bracket
[";" "," ] @punctuation.delimiter
[";" "," ":" ] @punctuation.delimiter
(ref (_) @type)
(dotted_name_template (_) @type)
(dotted_name (NAME) @namespace "." @punctuation.delimiter)

[(EQUAL) (RANGE_OP)] @operator
(validator (_
  (["min" "max" "range" "rangeMaxExclusive" "maxExclusive" "minExclusive"] @keyword.operator)))
(validators ["[" "]"] @punctuation.bracket)

(NUM) @constant.numeric

[(COMMENT) (docstring)] @string.documentation

["true"] @boolean

(struct (NAME) @type)
(enum (NAME) @type.enum)
(enum_content (NAME) @lsp.type.enumMember)
(variant (NAME) @type.enum.variant)
(interface (NAME) @type)

(node (NAME) @type)

(type) @type.builtin
(type (_ ["<" ">"] @punctuation.bracket))

(field (NAME) @field)
