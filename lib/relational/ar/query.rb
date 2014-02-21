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
          model = options[:model]
          partial = self.partial
          query = model.send(:sanitize_sql, [partial.query, *partial.attributes])
          rows = model.connection.select_all(query)
          Relational::AR::Results.new(rows, model)
        end
      end

      def set_model(model)
        options[:model] = model
        set_table_name = model.table_name
        set_composer PartialQuery
      end
    end
  end
end


rescue LoadError
end
