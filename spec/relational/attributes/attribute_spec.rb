require_relative '../../helper'

module Relational
  describe Attributes::Attribute do
    let(:table) { Tables::Table.new("examples") }
    let(:name) { Attributes::Attribute.new(table, "name") }

    it 'has a representation' do
      name.should have_pseudo_sql("examples.name")
    end

    it 'has a representation inside SELECT clause' do
      name.select_partial.to_pseudo_sql.should == "examples.name"
    end

    it 'can represent every attribute on select' do
      Attributes::All.should have_pseudo_sql("*")
    end

    it 'can represent every attribute on a table' do
      table.*.should have_pseudo_sql("examples.*")
    end

    it 'can represent dinamically an attribute on a table' do
      table.name.should have_pseudo_sql("examples.name")
    end

    it 'can represent a literal' do
      Partial.wrap('Foo').should have_pseudo_sql("'Foo'")
    end
  end

  #"Attributes ordering" should {
  #  "define order in SQL clauses" in {
  #    orders.Ascending(name).partial.toPseudoSQL should be === "(examples.name) ASC"
  #    orders.Descending(name).partial.toPseudoSQL should be === "(examples.name) DESC"
  #  }
  #}
end
