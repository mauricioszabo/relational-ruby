require_relative 'base'

module Relational
  module AR
    module ResultSets
      class MySQL < Base
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
      end
    end
  end
end
