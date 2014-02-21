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
    end
  end
end


rescue LoadError
end
