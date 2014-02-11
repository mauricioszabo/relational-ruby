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

        escape_attr(attribute)
      end
    end

    def escape_attr(attribute)
      case attribute
        when String then "'#{attribute.gsub("'", "''")}'"
        when Array then attribute.map { |a| escape_attr(a) }.join(",")
        when nil then "NULL"
        else attribute.to_s
      end
    end
    private :escape_attr
  end
end
