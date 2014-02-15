require_relative 'lazy'
require_relative 'partial_statement'

module Relational
  class Partial
    extend Lazy

    class Simple < Partial
      def initialize(query, attributes)
        @query, @attributes = query, attributes
      end

      lazy :partial do
        PartialStatement.new(@query, @attributes)
      end
    end

    def self.wrap(attribute)
      if(attribute.is_a?(Partial))
        attribute
      else
        Relational::Attributes::Literal.new(attribute)
      end
    end

    def append_with(query, partial)
      this_partial = self.partial
      other_partial = partial.partial
      Simple.new(
        "#{this_partial.query} #{query}#{other_partial.query}",
        this_partial.attributes + other_partial.attributes
      )
    end

    def partial
      raise NotImplementedError.new("missing implementation")
    end
  end
end
