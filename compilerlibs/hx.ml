(* HX compiler libraries *)
module Common = struct
  module Settings = Hx_common.Settings
end

module Text = struct
  module Lexer = Hx_text.Lexer
  module Parser = struct
    module Incremental = Hx_text.Incparser
    module Monolithic = Hx_text.Parser
  end
end
