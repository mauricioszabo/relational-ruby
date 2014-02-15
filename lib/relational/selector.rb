require_relative 'partial'

require_relative 'select'
require_relative 'attributes/none'

module Relational
  class Selector < Partial

    DEFAULT_INIT = {
      select: Select,
      from: '',
      where: Attributes::None,
      group: ListOfPartials,
      having: Attributes::None,
      join: ListOfPartials,
      order:  ListOfPartials,
      limit: -1,
      offset: -1
    }

    def initialize(query_options={})
      @query_options = DEFAULT_INIT.merge(query_options)
    end

    lazy :partial do
      partial = opt(:select).append_with("FROM ", opt(:from))
      partial = partial.append_with("WHERE ", opt(:where)) if opt(:where) != Attributes::None
      partial = partial.append_with("HAVING ", opt(:having)) if opt(:having) != Attributes::None
      partial = partial.append_with("GROUP BY ", opt(:group)) unless opt(:group).empty?
      partial = partial.append_with("ORDER BY ", opt(:order)) unless opt(:order).empty?

      partial.partial
    end

    def opt(key)
      @query_options[key]
    end
    private :opt

    def copy(query_options = {})
      Selector.new(@query_options.merge(query_options))
    end
  end
end