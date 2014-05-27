require_relative 'base'

module Relational
  module AR
    module ResultSets
      class MySQL < Base
        def next
          Hash[fields.zip(results.next)]
        rescue StopIteration
          nil
        end

        def each
          executed.each do |row|
            yield Hash[fields.zip(row)]
          end
        end

        def results
          @results ||= executed.to_enum
        end

        def fields
          @fields ||= executed.fields
        end

        def executed
          @executed ||= @connection.execute(@query)
        end
      end
    end
  end
end
