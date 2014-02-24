require_relative '../partial'
require_relative 'joins_helper'

module Relational
  module Query
    module Joins
      #Association = Struct.new(:kind, :table, :condition, :klass, :params)

      def has(kind, association_name, params={})
        @associations ||= {}

        join_table = params[:table] || association_name
        params = params.merge(table: self.table, join_table: join_table)
        association = Association.new(params)
        @associations[association_name] = association
      end

      def joins(*list_of_joins)
        JoinsHelper.new(self, @associations).execute(list_of_joins)
      end

      def left_joins(*list_of_joins)
        JoinsHelper.new(self, @associations, :left).execute(list_of_joins)
      end
    end
  end
end
