module Relational
  module Joins
    class JoinHelper
      def initialize(query, table, kind)
        @query, @kind = query, kind
        @table = if table.is_a?(Symbol)
          Relational::Tables::Table.new(table.to_s)
        else
          table
        end
      end

      def on
        comparission = yield(@query.table, @table)
        join = create_join(comparission)
        joins = @query.join + join
        @query.join(joins)
      end

      def create_join(comparission)
        case @kind
          when :inner then InnerJoin.new(@table, comparission)
          when :left then LeftJoin.new(@table, comparission)
          when :right then RightJoin.new(@table, comparission)
        end
      end
      private :create_join
    end
  end
end
