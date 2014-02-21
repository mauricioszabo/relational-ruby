begin
require 'active_record'
require_relative 'results'

module Relational
  module AR
    class CachedResults < Results
      attr_reader :cached
      protected :cached

      def each(&b)
        if(@cached)
          @cached.each(&b)
        else
          @cached = []
          while(row = @rows.shift)
            object = map_to(row)
            @cached << object
            b.call object
          end
        end
      end

      def ==(other)
        to_a # force load
        cached == other.cached && model == other.model
      end

      def to_a
        if(@cached)
          @cached
        else
          super
        end
      end

      def [](index)
        if(@cached)
          @cached[index]
        else
          map_to(@rows[index])
        end
      end

      def size
        if(@cached)
          @cached.size
        else
          super
        end
      end
    end
  end
end

rescue LoadError
end

