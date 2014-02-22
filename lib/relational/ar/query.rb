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

      def joins(*joins)
        create_join(joins, options[:model], :inner)
      end

      def left_joins(*joins)
        create_join(joins, options[:model], :left)
      end

      def create_join(join, model, kind)
        case join
          when Array then join.inject(self) { |s, j| s.create_join(j, model, kind) }
          when Hash then join.inject(self) do |s, (join, associates)|
            query_joined = s.create_join(join, model, kind)
            reflection = find_reflection(join, model)

            associated_model = extract_model_from(model, reflection.class_name)
            query_joined.create_join(associates, associated_model, kind)
          end
          else join_using(join, model, kind)
        end
      end
      protected :create_join

      def extract_model_from(this_model, reflection_model)
        this_model_name = this_model.name
        other_has_module_info = reflection_model =~ /::/
        this_has_no_module_info = this_model_name !~ /::/

        if(other_has_module_info || this_has_no_module_info)
          reflection_model.constantize
        else
          this_module_name = this_model_name.gsub(/(.*)::.*/, '\\1')
          "#{this_module_name}::#{reflection_model}".constantize
        end
      end
      private :extract_model_from

      def join_using(join_name, model, kind)
        reflection = find_reflection(join_name, model)
        this_table = Relational::Tables::Table.new(model.table_name.to_sym)
        other_table = Relational::Tables::Table.new(reflection.table_name.to_sym)

        condition = this_table[reflection.association_primary_key] == other_table[reflection.foreign_key]
        if(kind == :left)
          join(join + Relational::Joins::LeftJoin.new(other_table, condition))
        else
          join(join + Relational::Joins::InnerJoin.new(other_table, condition))
        end
      end
      private :join_using

      def find_reflection(join_name, model)
        model.reflect_on_association(join_name) or raise ActiveRecord::ConfigurationError,
          "Association named '#{join_name}' was not found on #{model}."
      end
      private :find_reflection
    end
  end
end


rescue LoadError
end
