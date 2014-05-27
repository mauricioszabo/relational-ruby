require_relative 'base'

module Relational
  module AR
    module ResultSets
      class Oracle < Base
        def next
          row = results.fetch_hash
          if row
            to_hash(row)
          end
        end

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

        def results
          @results ||= @connection.execute(@query)
        end
      end
    end
  end
end
