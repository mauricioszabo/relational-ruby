require_relative 'partial'

module Relational
  class ListOfPartials < Partial
    include Enumerable

    def self.[](*list_of_attributes)
      new(list_of_attributes, false)
    end

    def initialize(list_of_attributes, distinct)
      @list_of_attributes = list_of_attributes.map { |a| Partial.wrap(a) }
      @distinct = distinct
    end

    def self.+(attribute)
      Select.new([Partial.wrap(attribute)], false)
    end

    def +(attribute)
      Select.new(@list_of_attributes + [Partial.wrap(attribute)], @distinct)
    end

    def self.prepend(attribute)
      Select.new([Partial.wrap(attribute)], false)
    end

    def prepend(attribute)
      Select.new([Partial.wrap(attribute)] + @list_of_attributes, @distinct)
    end

    def [](key)
      @list_of_attributes[key]
    end

    def self.each
    end

    def each(&b)
      @list_of_attributes.each(&b)
    end

    def self.empty?
      true
    end

    def empty?
      @list_of_attributes.empty?
    end

    lazy :partial do
      queries, attributes = queries_and_attributes
      query = queries.join(' ')
      Relational::PartialStatement.new(query, attributes)
    end

    def queries_and_attributes
      queries = []
      attributes = @list_of_attributes.flat_map do |attribute|
        partial = attribute.partial
        queries << partial.query
        partial.attributes
      end

      [queries, attributes]
    end
    private :queries_and_attributes
  end
end

