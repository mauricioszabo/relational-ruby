require_relative '../../helper'

module Relational
  describe Attributes::Modifiable do
    let(:table) { Tables::Table.new("examples") }
    let(:name) { Attributes::Attribute.new(table, "name") }

    before { Relational::Adapter.define_driver('all') }

    it 'defines equalities with values' do
      (name == 'foo').should have_pseudo_sql("examples.name = 'foo'")
    end

    it 'defines a "blackhole-kind" attribute' do
      none = Attributes::None
      (none | (name == 'foo')).should have_pseudo_sql("examples.name = 'foo'")
      (none & (name == 'foo')).should have_pseudo_sql("examples.name = 'foo'")
    end

    it "defines inequality with values" do
      (name <= "Foo").should have_pseudo_sql("examples.name <= 'Foo'")
      (name < "Foo").should have_pseudo_sql("examples.name < 'Foo'")
      (name >= "Foo").should have_pseudo_sql("examples.name >= 'Foo'")
      (name > "Foo").should have_pseudo_sql("examples.name > 'Foo'")
      (name != "Foo").should have_pseudo_sql("examples.name <> 'Foo'")
    end

    it 'defines if is null or not' do
      (name.null?).should have_pseudo_sql('examples.name IS NULL')
      (name.not_null?).should have_pseudo_sql('examples.name IS NOT NULL')
    end

    it "defines equality with LIKE and NOT LIKE" do
      (name =~ "Foo").should have_pseudo_sql("examples.name LIKE 'Foo'")
      (name.like "Foo").should have_pseudo_sql("examples.name LIKE 'Foo'")
      (name !~ "Foo").should have_pseudo_sql("examples.name NOT LIKE 'Foo'")
      (name.not_like "Foo").should have_pseudo_sql("examples.name NOT LIKE 'Foo'")
    end

    it "defines equality and inequality with other attributes" do
      (name == table[:id]).should have_pseudo_sql("examples.name = examples.id")
      (name != table[:id]).should have_pseudo_sql("examples.name <> examples.id")
    end

    it "negates a whole condition" do
      result = !(name <= "Foo")
      result.should have_pseudo_sql("NOT(examples.name <= 'Foo')")
    end

    it "finds IN a list of parameters" do
      name.in?(['Foo', 'Bar']).should have_pseudo_sql("examples.name IN ('Foo','Bar')")
      name.not_in?(['Foo', 'Bar']).should have_pseudo_sql("examples.name NOT IN ('Foo','Bar')")
    end

    it "splits IN into multiple clauses if in Oracle" do
      Relational::Adapter.define_driver 'oracle'
      numbers = (1..1500).to_a
      result = name.in?(numbers)
      expected = "(examples.name IN (#{
        numbers[0...1000].join(",")}) OR examples.name IN (#{
        numbers[1000..-1].join(",")}))"

      result.partial.to_pseudo_sql.should == expected
    end

    it "splits NOT IN into multiple clauses if in Oracle" do
      Relational::Adapter.define_driver 'oracle'
      numbers = (1..1500).to_a
      result = name.not_in?(numbers)
      expected = "(examples.name NOT IN (#{
        numbers[0...1000].join(",")}) AND examples.name NOT IN (#{
        numbers[1000..-1].join(",")}))"

      result.partial.to_pseudo_sql.should == expected
    end

    it "adds an OR or AND condition" do
      c1 = (name == "Foo")
      c2 = (table[:id] == 10)
      (c1 | c2).should have_pseudo_sql("(examples.name = 'Foo' OR examples.id = 10)")
      (c1 & c2).should have_pseudo_sql("(examples.name = 'Foo' AND examples.id = 10)")
    end

    it 'supports SUM, AVERAGE, MAX, MIN, COUNT' do
      name.sum.should have_pseudo_sql('SUM(examples.name)')
      name.avg.should have_pseudo_sql("AVG(examples.name)")
      name.max.should have_pseudo_sql("MAX(examples.name)")
      name.min.should have_pseudo_sql("MIN(examples.name)")
      name.count.should have_pseudo_sql("COUNT(examples.name)")
      name.count_distinct.should have_pseudo_sql("COUNT(DISTINCT examples.name)")
    end

    it "supports LENGTH, UPPER, LOWER" do
      (name.length == 1).should have_pseudo_sql "LENGTH(examples.name) = 1"
      (name.upper == "UP").should have_pseudo_sql "UPPER(examples.name) = 'UP'"
      (name.lower == "up").should have_pseudo_sql "LOWER(examples.name) = 'up'"
    end
  end
end
