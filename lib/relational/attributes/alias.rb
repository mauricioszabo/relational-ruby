module Relational
  module Attributes
    class Alias < AttributeLike
      def initialize(alias_name, partial)
        @alias_name, @partial = alias_name, partial
      end

      lazy :select_partial do
        partial = @partial.partial

        Relational::PartialStatement.new(
          "(#{partial.query}) #@alias_name", partial.attributes
        )
      end

      lazy :partial do
        Relational::PartialStatement.new(@alias_name, [])
      end
    end
  end
end
