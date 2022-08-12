module Common: sig
  module Settings: sig
    include module type of Hx_common.Settings
  end
end

module Text: sig
  module Parser: sig
    module Incremental: sig
      include module type of Hx_text.Incparser
    end
    module Monolithic: sig
      include module type of Hx_text.Parser
    end
  end
  module Lexer: sig
    include module type of Hx_text.Lexer
  end
end
