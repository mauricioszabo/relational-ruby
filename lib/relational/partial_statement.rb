module Relational
  class PartialStatement
    attr_reader :query, :attributes

    def initialize(query, attributes=[])
      @query = query
      @attributes = attributes
    end

    def to_pseudo_sql
      attributes = @attributes.dup

      @query.gsub('?') do
        attribute = attributes.shift

        case attribute
          when String then "'#{attribute.gsub("'", "''")}'"
          when nil then "NULL"
          else attribute.to_s
        end
      end
    end
  end
end
