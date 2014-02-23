require_relative 'partial'

require_relative 'select'
require_relative 'list_of_attributes'
require_relative 'attributes/none'
require_relative 'adapter/function_definition'

module Relational
  class Selector < Partial
    extend Adapter::FunctionDefinition

    DEFAULTS = {
      select: Select,
      from: ListOfAttributes,
      where: Attributes::None,
      group: ListOfAttributes,
      having: Attributes::None,
      join: ListOfPartials,
      order:  ListOfAttributes,
      limit: -1,
      offset: -1
    }

    def initialize(query_options={})
      @query_options = DEFAULTS.merge(query_options)
    end

    def as(alias_name)
      Relational::Tables::Alias.new(alias_name, self)
    end

    lazy :partial do
      partial = opt(:select)
      partial = partial.append_with("FROM ", opt(:from)) unless opt(:from).empty?
      partial = partial.append_with("", opt(:join)) unless opt(:join).empty?
      partial = partial.append_with("WHERE ", opt(:where)) if opt(:where) != Attributes::None
      partial = partial.append_with("GROUP BY ", opt(:group)) unless opt(:group).empty?
      partial = partial.append_with("HAVING ", opt(:having)) if opt(:having) != Attributes::None
      partial = partial.append_with("ORDER BY ", opt(:order)) unless opt(:order).empty?

      treat_pagination(partial)
    end

    define_custom_method :treat_pagination, all: ->(partial) {
      partial_statement = partial.partial
      query = partial_statement.query
      attributes = partial_statement.attributes

      if opt(:limit).to_i >= 0
        query += " LIMIT ?"
        attributes += [opt(:limit)]
      end

      if opt(:offset).to_i >= 0
        query += " OFFSET ?"
        attributes += [opt(:offset)]
      end

      PartialStatement.new(query, attributes)
    }, oracle: ->(partial) {
      all = Attributes::All
      if(opt(:limit).to_i >= 0 || opt(:offset).to_i >= 0)
        query = partial.partial.query
        attributes = partial.partial.attributes

        wheres = []
        offset = opt(:offset).to_i
        if offset > 0
          wheres << %{"oracle row" >= ?}
          attributes += [offset]
        end

        limit = opt(:limit).to_i
        if limit > 0
          offset = 0 if offset < 0
          wheres << %{"oracle row" <= ?}
          attributes += [limit + offset]
        end


        query = "SELECT * FROM (SELECT " +
          %{"pagination 1".*, rownum "oracle row" FROM (#{query}) "pagination 1") "pagination 2"} +
          " WHERE " + wheres.join(" AND ")
        PartialStatement.new(query, attributes)
      else
        partial.partial
      end
    }

    def opt(key)
      @query_options[key]
    end

    def copy(query_options = {})
      Selector.new(@query_options.merge(query_options))
    end
  end
end
