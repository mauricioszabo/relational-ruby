require_relative '../../helper'

module Relational
  describe Attributes::Attribute do
    let(:table) { Tables::Table.new("examples") }
    let(:name) { Attributes::Attribute.new(table, "name") }

    it 'has a representation' do
      name.should have_pseudo_sql("examples.name")
    end

    it 'can represent every attribute on a table' do
      table.*.should have_pseudo_sql("examples.*")
    end

    it 'can represent dinamically an attribute on a table' do
      table.name.should have_pseudo_sql("examples.name")
    end

    it 'can represent a literal' do
      Attributes.wrap('Foo').should have_pseudo_sql("'Foo'")
    end
  end
end
