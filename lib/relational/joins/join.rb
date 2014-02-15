require_relative '../partial'

module Relational
  module Joins
    class Join < Partial
      def initialize(table, condition, kind)
        @table, @condition, @kind = table, condition, kind
      end

      lazy :partial do
        query = "#@kind JOIN #{@table.partial.query} " +
          "ON #{@condition.partial.query}"

        PartialStatement.new(query, @table.partial.attributes + @condition.partial.attributes)
      end
    end
  end
end
