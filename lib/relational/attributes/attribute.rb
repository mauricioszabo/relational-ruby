module Relational
  module Attributes
    class Attribute
      def initialize(table, attribute_name)
        @table, @attribute_name = table, attribute_name
      end

      def partial
        PartialStatement.new("#{@table.representation}.#{@attribute_name}")
      end
    end
  end
end
