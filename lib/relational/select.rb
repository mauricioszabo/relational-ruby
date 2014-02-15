require_relative 'list_of_partials'

module Relational
  class Select < ListOfPartials
    def distinct
      Select.new(@list_of_attributes, true)
    end

    def indistinct
      Select.new(@list_of_attributes, false)
    end

    lazy :partial do
      queries = []
      attributes = @list_of_attributes.flat_map do |attribute|
        partial = attribute.select_partial
        queries << partial.query
        partial.attributes
      end

      query = "SELECT #{'DISTINCT ' if @distinct}#{queries.join(', ')}"
      Relational::PartialStatement.new(query, attributes)
    end
  end
end
