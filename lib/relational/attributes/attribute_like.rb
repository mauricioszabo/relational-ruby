require_relative '../partial'

module Relational
  module Attributes
    class AttributeLike < Partial
      lazy :select_partial do
        partial
      end

      def as(alias_name)
        Alias.new(alias_name, self)
      end
    end
  end
end

