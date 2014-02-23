module Relational
  module Query
    class JoinsHelper
      def initialize(query, associations, kind = :inner)
        @query, @associations = query, associations
        @kind = kind
      end

      def execute(list_of_joins, query = @query)
        case list_of_joins
          when Array then multi_join(list_of_joins, query)
          else single_join(list_of_joins, query)
        end
      end

      def multi_join(list_of_joins, query)
        list_of_joins.inject(@query) do |query, join|
          execute(join, query)
        end
      end
      private :multi_join

      def single_join(join, query)
        association = @associations[join]
        join = if(@kind == :inner)
          Relational::Joins::InnerJoin.new(association.join_table, association.condition)
        else
          Relational::Joins::LeftJoin.new(association.join_table, association.condition)
        end
        query.join(query.join + join)
      end
      private :single_join
    end
  end
end

