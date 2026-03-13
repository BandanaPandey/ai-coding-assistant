module Rag
  class SemanticChunker
    def initialize(code)
      @code = code
      @ast = Ast::Parser.new.parse(code)
    end

    def chunks
      results = []
      walk(@ast, results)
      results
    end

    private

    def walk(node, results)
      return unless node.is_a?(Parser::AST::Node)

      if node.type == :class || node.type == :module || node.type == :def
        location = node.location.expression
        results << {
          content: location.source,
          start_line: location.line
        }
      end

      node.children.each do |child|
        walk(child, results)
      end
    end
  end
end