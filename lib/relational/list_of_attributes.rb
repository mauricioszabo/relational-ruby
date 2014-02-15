require_relative 'list_of_partials'

module Relational
  class ListOfAttributes < ListOfPartials
    lazy :partial do
      queries, attributes = queries_and_attributes
      query = queries.join(', ')
      Relational::PartialStatement.new(query, attributes)
    end
  end
end
