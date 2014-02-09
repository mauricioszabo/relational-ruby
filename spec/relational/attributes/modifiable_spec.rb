require_relative '../../helper'

module Relational
  describe Attributes::Modifiable do
    let(:table) { Tables::Table.new("examples") }
    let(:name) { Attributes::Attribute.new(table, "name") }


    it 'defines equalities with values' do
      (name == 'foo').should have_pseudo_sql("examples.name = 'foo'")
    end

    it "defines inequality with values" do
      (name <= "Foo").should have_pseudo_sql("examples.name <= 'Foo'")
      (name < "Foo").should have_pseudo_sql("examples.name < 'Foo'")
      (name >= "Foo").should have_pseudo_sql("examples.name >= 'Foo'")
      (name > "Foo").should have_pseudo_sql("examples.name > 'Foo'")
      (name != "Foo").should have_pseudo_sql("examples.name <> 'Foo'")
    end

    it "defines equality with NULL" do
      (name == nil).should have_pseudo_sql("examples.name IS NULL")
      (name != nil).should have_pseudo_sql("examples.name IS NOT NULL")
      (name < nil).should have_pseudo_sql("examples.name < NULL")
      (name.nil?).should have_pseudo_sql("examples.name IS NULL")
    end

    it 'supports SUM' do
      name.sum.should have_pseudo_sql('SUM(examples.name)')
    end
  end
end

