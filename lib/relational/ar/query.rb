begin
require 'active_record'
require_relative '../query'
require_relative 'results'

module Relational
  module AR
    module Query
      include Relational::Query

      class PartialQuery
        include Relational::Query
        include Relational::Query::Mapper

        def results
          rows = send_query(partial)
          Relational::AR::Results.new(rows, options[:model])
        end

        def cached_results
          rows = send_query(partial)
          Relational::AR::CachedResults.new(rows, options[:model])
        end

        def count
          count = send_query(count_query.partial)[0]
          count['count'].to_i
        end

        def send_query(partial)
          model = options[:model]
          query = model.send(:sanitize_sql, [partial.query, *partial.attributes])
          model.connection.select_all(query)
        end
        private :send_query
      end

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
