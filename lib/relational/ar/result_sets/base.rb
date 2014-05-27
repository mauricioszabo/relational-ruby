module Relational
  module AR
    module ResultSets
      class Base
        include Enumerable

        def initialize(connection, query)
          @connection, @query = connection, query
        end
      end
    end
  end
end
