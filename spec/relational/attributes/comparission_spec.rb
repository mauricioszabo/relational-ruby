require_relative '../../helper'

module Relational
  describe Attributes::Modifiable do
    let(:table) { Tables::Table.new("examples") }
    let(:name) { Attributes::Attribute.new(table, "name") }

    it 'defines equalities with values' do
      (name == 'foo').should have_pseudo_sql("examples.name = 'foo'")
    end

    it 'supports SUM' do
      name.sum.should have_pseudo_sql('SUM(examples.name)')
    end
  end
end

