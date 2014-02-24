require_relative '../lazy'

module Relational
  module Query
    class Association
      extend Lazy

      attr_reader :params, :table

      def initialize(params)
        @table = params[:table]
        @params = params
      end

      lazy :condition do
        if params[:condition]
          params[:condition]
        else
          table[params[:pk]] == join_table[params[:fk]]
        end
      end

      lazy :join_table do
        if params[:join_table].is_a?(Partial)
          params[:join_table]
        elsif params.include?(:join_table)
          Relational::Tables::Table.new(params[:join_table])
        elsif mapper
          mapper.table
        end
      end

      lazy :mapper do
        if params.include?(:mapper)
          eval(params[:mapper])
        else
          nil
        end
      end

      def associated_with(ids_or_query)
        selector = Selector.new(select: Select[Attributes::All],
          from: ListOfAttributes[join_table])

        if ids_or_query.is_a?(Partial)
          aliased = ids_or_query.as(params[:table].representation)
          selector.copy(join:
            ListOfPartials[Relational::Joins::InnerJoin.new(aliased, condition)])
        else
          selector.copy(where: join_table[params[:fk]].in?(ids_or_query))
        end
      end
    end
  end
end
