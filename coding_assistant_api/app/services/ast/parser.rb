require "parser/current"

module Ast
  class Parser
    def parse(code)
      buffer = ::Parser::Source::Buffer.new("(code)")
      buffer.source = code
      parser = ::Parser::CurrentRuby.new
      parser.parse(buffer)
    end
  end
end