module Relational
  module Tables
    class Table
      include Partial
      attr_accessor :representation

      def initialize(table_name)
        @representation = table_name.to_s
      end

      def *
        self['*']
      end

      def method_missing(name, *args, &b)
        if args.size == 0 && b.nil?
          self[name]
        else
          super
        end
      end

      def [](name)
        Attributes::Attribute.new(self, name)
      end

      def as(alias_name)
        Alias.new(alias_name, self)
      end

      lazy :partial do
        Relational::PartialStatement.new(@representation, [])
      end
    end
  end
end
