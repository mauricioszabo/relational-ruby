module Relational
  module Joins
    class JoinHelper
      def initialize(query, query_table, tables, kind)
        @query, @query_table, @kind = query, query_table, kind
        @tables = tables
      end

      def on
        table, *rest = @tables
        table = get_table(table)
        comparission = yield(@query_table, table)
        join = create_join(table, comparission)
        joins = @query.join + join
        new_query = @query.join(joins)
        if(rest.empty?)
          new_query
        else
          JoinHelper.new(new_query, table, rest, @kind)
        end
      end

      def get_table(table)
        if table.is_a?(Symbol)
          Relational::Tables::Table.new(table.to_s)
        else
          table
        end
      end
      private :get_table

      def create_join(table, comparission)
        case @kind
          when :inner then InnerJoin.new(table, comparission)
          when :left then LeftJoin.new(table, comparission)
          when :right then RightJoin.new(table, comparission)
        end
      end
      private :create_join
    end
  end
end
