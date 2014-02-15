module Relational
  module Tables
    class Alias < Table
      attr_accessor :representation

      def initialize(alias_name, partial)
        @representation, @partial = alias_name, partial
      end

      def as(alias_name)
        Alias.new(alias_name, @partial)
      end

      lazy :partial do
        partial = @partial.partial
        Relational::PartialStatement.new(
          "(#{partial.query}) #@representation", partial.attributes
        )
      end
    end
  end
end
