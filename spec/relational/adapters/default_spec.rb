require_relative '../../helper'

module Relational::Adapters
  describe Default do
    let(:table) { Relational::Tables::Table.new("examples") }
    let(:name) { Relational::Attributes::Attribute.new(table, "name") }

    it 'creates a function in SQL' do
      Relational::Adapters.define_function :foobar, all: ->(me, param) do
        ["FOO_BAR(#{me.partial.query}, ?)", [param]]
      end

      name.foobar(10).should have_pseudo_sql("FOO_BAR(examples.name, 10)")
    end
  end
end
