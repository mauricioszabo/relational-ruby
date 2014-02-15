require_relative '../helper'

module Relational
  describe Partial do
    class Foo < Partial
      def initialize(query, attrs)
        @query, @attrs = query, attrs
      end
      def partial
        PartialStatement.new(@query, @attrs)
      end
    end

    it 'concatenates partials with a query between then' do
      ps1 = Foo.new('SELECT ? FROM dual', ['foo'])
      ps2 = Foo.new('name = ?', ['bar'])
      partial = ps1.append_with("WHERE ", ps2)
      partial.should have_pseudo_sql "SELECT 'foo' FROM dual WHERE name = 'bar'"
    end

    it 'concatenates partials' do
      ps1 = Foo.new('SELECT ? FROM dual', ['foo'])
      ps2 = Foo.new('WHERE name = ?', ['bar'])
      ps3 = Foo.new('ORDER BY name = ?', ['baz'])
      partial = ps1.append(ps2, ps3)
      partial.should have_pseudo_sql "SELECT 'foo'
          FROM dual
          WHERE name = 'bar'
          ORDER BY name = 'baz'".gsub(/\s*\n\s*/, " ")
    end
  end
end

