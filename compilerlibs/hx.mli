module Text : sig
  module Parser : sig
    include module type of Hx_text.Parser
  end
  module Lexer : sig
    include module type of Hx_text.Lexer
  end
end
