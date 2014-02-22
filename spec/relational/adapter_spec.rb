require_relative '../helper'

module Relational
  describe Adapter do
    let(:table) { Relational::Tables::Table.new("examples") }
    let(:name) { Relational::Attributes::Attribute.new(table, "name") }

    it 'creates a function in SQL' do
      Attributes::Modifiable.define_function :foobar, all: ->(me, param) do
        ["FOO_BAR(#{me.partial.query}, ?)", [param]]
      end

      name.foobar(10).should have_pseudo_sql("FOO_BAR(examples.name, 10)")
    end

    it 'creates a function in SQL returning a PartialStatement' do
      Attributes::Modifiable.define_function :foobaz, all: ->(me, param) do
        Relational::PartialStatement.new("FOO_BAZ(#{me.partial.query}, ?)", [param])
      end

      name.foobaz(10).should have_pseudo_sql("FOO_BAZ(examples.name, 10)")
    end

    it 'creates a method that has different behaviour for each adapter' do
      Attributes::Modifiable.define_custom_method :bar, all: -> {
        "#{partial.query} Foo"
      }, oracle: -> {
        "#{partial.query} Bar"
      }

      Relational::Adapter.define_driver 'oracle'
      name.bar.should == 'examples.name Bar'

      Relational::Adapter.define_driver 'all'
      name.bar.should == 'examples.name Foo'
    end
  end
end
