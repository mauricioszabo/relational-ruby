require_relative 'partial'

require_relative 'select'
require_relative 'list_of_attributes'
require_relative 'attributes/none'

module Relational
  class Selector < Partial

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

      partial.partial
    end

    def opt(key)
      @query_options[key]
    end

    def copy(query_options = {})
      Selector.new(@query_options.merge(query_options))
    end
  end
end
