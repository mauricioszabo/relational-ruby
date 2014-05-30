require_relative 'base'

module Relational
  module AR
    module ResultSets
      class Oracle < Base
        def each
          result_set = @connection.execute(@query)
          while(row = result_set.fetch_hash)
            yield to_hash(row)
          end
        end

        def to_hash(row)
          hash = {}
          row.each do |field, value|
            hash[field.downcase] = value
          end
          hash
        end
        private :to_hash
      end
    end
  end
end
