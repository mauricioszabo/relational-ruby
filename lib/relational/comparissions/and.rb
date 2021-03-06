require_relative '../partial'
require_relative '../attributes/aliasable'

module Relational
  module Comparissions
    class And
      include Partial
      include Attributes::Aliasable

      def initialize(items)
        @items = items
      end

      lazy :partial do
        attributes = []

        queries = @items.map do |item|
          partial = Relational::Partial.wrap(item).partial
          attributes += partial.attributes
          partial.query
        end

        PartialStatement.new("(#{queries.join(" AND ")})", attributes)
      end
    end
  end
end

