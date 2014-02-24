require_relative '../partial'

module Relational
  module Comparissions
    class In < Partial
      def initialize(attribute, items, negate=false)
        @attribute, @items, @negate = attribute, Partial.wrap(items), negate

      end

      lazy :partial do
        partial = @attribute.partial
        items_p = @items.partial

        PartialStatement.new("#{partial.query} "+
          "#{"NOT " if @negate}" +
          "IN (#{items_p.query})", partial.attributes + items_p.attributes)
      end
    end
  end
end
