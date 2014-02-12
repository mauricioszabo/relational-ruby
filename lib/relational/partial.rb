require_relative 'lazy'
require_relative 'partial_statement'

module Relational
  class Partial
    extend Lazy

    def append(*partials)
      partial = self.partial
      query = partial.query
      attributes = partial.attributes

      partials.each do |partial|
        partial_statement = partial.partial
        query += " " + partial_statement.query
        attributes += partial_statement.attributes
      end

      PartialStatement.new(query, attributes)
    end
  end
end
