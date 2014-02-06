module Relational
  module Tables
    class Table
      attr_accessor :representation

      def initialize(table_name)
        @representation = table_name
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
    end
  end
end

