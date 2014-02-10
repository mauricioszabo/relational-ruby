require_relative "modifiable"
module Relational
  module Attributes
    def self.wrap(attribute)
      if(attribute.is_a?(AttributeLike))
        attribute
      else
        Literal.new(attribute)
      end
    end

    class Literal < Modifiable
      def initialize(literal)
        @literal = literal
      end

      lazy :partial do
        Relational::PartialStatement.new("?", [@literal])
      end
    end
  end
end
