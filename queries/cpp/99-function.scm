; void test() { }
(function_definition) @context.function
(function_definition
  body: (compound_statement) @context.body)

; const auto display_text = [](std::any canvas, std::string_view text, int x, int y) { };
(lambda_expression) @context.function
(lambda_expression
  body: (compound_statement) @context.body)

; template<typename T>
; concept Callback = requires(T cb) {
;     { cb() } -> std::same_as<void>;
;     { ... } -> ...;
; };
(concept_definition) @context.function
(concept_definition
    (requires_expression
        requirements: (requirement_seq) @context.body))
