require_relative '../partial'
require_relative 'aliasable'

module Relational
  module Attributes
    class AttributeLike < Partial
      include Aliasable

      lazy :select_partial do
        partial
      end
    end
  end
end

