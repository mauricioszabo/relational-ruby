module Relational
  module Attributes
    module Aliasable
      def as(alias_name)
        Alias.new(alias_name, self)
      end
    end
  end
end

