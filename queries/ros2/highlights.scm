; ROS .msg / .srv / .action highlighting for the installed ros2 parser

(comment) @comment @spell

(comment_char) @comment
(comment_string) @comment

(separator) @punctuation.delimiter

(built_in_type) @type.builtin
(custom_interface_type) @type
(array_type) @type
(bounded_string) @type.builtin

(field_name
  (name_string) @variable.member)

(const_name) @constant

(integer_value) @number
(float_value) @number.float
(number) @number
(string_value) @string

"=" @operator
"," @punctuation.delimiter

[
  "["
  "]"
  "[]"
] @punctuation.bracket
