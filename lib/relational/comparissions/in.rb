require_relative '../partial'

module Relational
  module Comparissions
    class In < Partial
      def initialize(attribute, items, negate=false)
        @attribute, @items, @negate = attribute, items, negate
      end

      lazy :partial do
        partial = @attribute.partial
        if @negate
          PartialStatement.new("#{partial.query} NOT IN (?)", partial.attributes + [@items])
        else
          PartialStatement.new("#{partial.query} IN (?)", partial.attributes + [@items])
        end
      end
    end
  end
end
