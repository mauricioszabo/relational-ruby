require_relative 'base'

module Relational
  module AR
    module ResultSets
      class SQLite < Base
        def each(&b)
          @connection.execute(@query).each(&b)
        end

        def results
          @results ||= @connection.execute(@query).to_enum
        end
      end
    end
  end
end
