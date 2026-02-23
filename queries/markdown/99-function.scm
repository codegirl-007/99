; Headings are primary functions
(atx_heading) @context.function

; Heading with its content as body
(atx_heading
  (section) @context.body)

(setext_heading) @context.function

(setext_heading
  (section) @context.body)

; Fenced code blocks as standalone functions (for individual selection)
(fenced_code_block) @context.function
