; inherits: c

(for_range_loop
  body: (_ (_) @context.end)
) @context

(namespace_definition
  body: (declaration_list) @namespace_body
  (#set! @namespace_body "context.end")
) @context

(class_specifier
  body: (_ (_) @context.end)
) @context

(linkage_specification
  body: (declaration_list (_) @context.end)
) @context

(lambda_expression
  body: (_ (_) @context.end)
) @context
