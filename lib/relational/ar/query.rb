begin
require 'active_record'
require_relative '../query'
require_relative 'results'
require_relative 'sql_string'

module Relational
  module AR
    module Query
      include Relational::Query

      class PartialQuery
        include Relational::Query
        include Relational::Query::Mapper

        def results
          rs = send_query(partial)
          Relational::AR::Results.new(rs, options[:model])
        end

        def cached_results
          rs = send_query(partial)
          Relational::AR::CachedResults.new(rs, options[:model])
        end

        def count
          count = send_query(count_query.partial).next
          count['count'].to_i
        end

        def send_query(partial)
          model = options[:model]
          query = model.send(:sanitize_sql, [partial.query, *partial.attributes])
          ResultSets.for_db(model.connection, query)
        end
        private :send_query
      end

      def from(*params)
        if(params.size == 1 && params[0].is_a?(ActiveRecord::Relation))
          convert_from_arel(params[0])
        else
          super
        end
      end

      def convert_from_arel(relation)
        arel = relation.arel
        me = self

        if(relation.select_values.size > 0)
          me = me.select(*convert_attrs(relation.select_values))
        end

        me = me.from(*convert_attrs(arel.froms))
        me = me.where(convert_where(relation.where_values))
        me = me.group(*convert_attrs(relation.group_values)) if(relation.group_values.size > 0)
        me = me.having(convert_where(relation.having_values))

        if(arel.join_sources.size > 0)
          me = me.join(ListOfPartials[SQLString.new(arel.join_sql)])
        end

        me = me.order(*convert_attrs(relation.order_values)) if(relation.order_values.size > 0)

        me = me.limit(relation.limit_value) if relation.limit_value
        me = me.offset(relation.offset_value) if relation.offset_value
        me
      end
      private :convert_from_arel

      def convert_attrs(attrs)
        attrs.map do |item|
          if item.is_a?(Arel::Table)
            SQLString.new(item.name)
          elsif item.respond_to?(:to_sql)
            SQLString.new(item.to_sql)
          elsif item.is_a?(String)
            SQLString.new(item)
          else
            item
          end
        end
      end
      private :convert_attrs

      def convert_where(wheres)
        wheres.inject(Relational::Attributes::None) do |clause, where|
          where = if(where.respond_to?(:to_sql))
            SQLString.new(where.to_sql)
          else
            SQLString.new(where)
          end
          clause & where
        end
        #wheres = "(#{wheres.join(" AND ")})"
        #me = me.where(SQLString.new(wheres))
      end
      private :convert_where

      def set_model(model)
        options[:model] = model
        set_table_name model.table_name
        set_composer PartialQuery
      end

      def ar_join(*joins)
        create_join(joins, options[:model], :inner)
      end

      def ar_left_join(*joins)
        create_join(joins, options[:model], :left)
      end

      def create_join(join, model, kind)
        case join
        when Array
          join.inject(self) { |s, j| s.create_join(j, model, kind) }

        when Hash
          join.inject(self) do |s, (join, associates)|
            query_joined = s.create_join(join, model, kind)
            reflection = find_reflection(join, model)

            associated_model = reflection.klass
            query_joined.create_join(associates, associated_model, kind)
          end

        else
          reflection = find_reflection(join, model)
          if(reflection.macro == :has_and_belongs_to_many)
            join_habtm(reflection, model, kind)
          else
            join_using(join, reflection, model, kind)
          end
        end
      end
      protected :create_join

      def find_reflection(join_name, model)
        model.reflect_on_association(join_name) or raise ActiveRecord::ConfigurationError,
          "Association named '#{join_name}' was not found on #{model}."
      end
      private :find_reflection

      def join_habtm(reflection, model, kind)
        join_table_name = reflection.options[:join_table]
        make_join(
          #Join table first
          model.table_name, join_table_name, #Tables
          reflection.active_record_primary_key, reflection.foreign_key, #Fields
          kind
        ).make_join(
          #Now destination table
          join_table_name, reflection.klass.table_name, #Tables
          reflection.association_foreign_key, reflection.association_primary_key, #Fields
          kind
        )
      end
      private :join_habtm

      def join_using(join_name, reflection, model, kind)
        this_field, other_field = find_foreign_keys(reflection)

        make_join(model.table_name, reflection.table_name, this_field, other_field, kind)
      end
      private :join_using

      def make_join(this_table, other_table, this_field, other_field, kind)
        this_table = Relational::Tables::Table.new(this_table)
        other_table = Relational::Tables::Table.new(other_table)
        condition = this_table[this_field] == other_table[other_field]
        if(kind == :left)
          join(join + Relational::Joins::LeftJoin.new(other_table, condition))
        else
          join(join + Relational::Joins::InnerJoin.new(other_table, condition))
        end
      end
      protected :make_join

      # Ok, before I start, let's say how I hate Rails internals:
      # You could have two methods, informing which keys I would use in a join-but no,
      # you MUST have these four methods that, depending on each association you're
      # using, their meaning it's different. So, here we are, making a mess of our code.
      # Thanks, Rails.
      def find_foreign_keys(reflection)
        case reflection.macro
          when :has_many
            if(reflection.nested?)
              raise ActiveRecord::ConfigurationError, "Relational doesn't support has_many :through"
            else
              [reflection.active_record_primary_key, reflection.foreign_key]
            end
          when :belongs_to then [reflection.association_foreign_key, reflection.association_primary_key]
          else raise ActiveRecord::ConfigurationError, "Relational doesn't support #{reflection.macro} associations"
        end
      end
      private :find_foreign_keys
    end
  end
end


rescue LoadError
end
