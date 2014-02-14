require_relative '../partial'

module Relational
  module Comparissions
    class In < Partial
      def initialize(attribute, items)
        @attribute, @items = attribute, items
      end

      lazy :partial do
        partial = @attribute.partial
        PartialStatement.new("#{partial.query} IN (?)", partial.attributes + [@items])
      end
    end
  end
end
