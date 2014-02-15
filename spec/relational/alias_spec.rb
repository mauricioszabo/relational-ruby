require_relative '../helper'

describe 'Aliases' do
  let(:people) { Relational::Tables::Table.new('people') }

  context "in tables" do
    let(:new_people) { people.as('p') }

    it "renames tables in SELECT clauses" do
      new_people.should have_pseudo_sql "(people) p"
    end

    it "renames attributes" do
      new_people[:id].should have_pseudo_sql "p.id"
    end

    it "renames itself" do
      new_people.as("foo").should have_pseudo_sql "(people) foo"
    end
  end

  context "Alias in attributes" do
    it "renames attribute" do
      people[:id].as("foo").select_partial.to_pseudo_sql.should == "(people.id) foo"
      people[:id].as("foo").should have_pseudo_sql "foo"
    end

    it "renames itself" do
      people[:id].as("foo").as("bar").should have_pseudo_sql "bar"
    end
  end

  #context "Alias in select" do
  #  val selector = new Selector(new clauses.Select(false, people, 'id), Seq(people))

  #  it "renames queries" do
  #    selector.as("sql").partial.toPseudoSQL should be === "(SELECT people.id FROM people) sql"
  #  end

  #  it "renames attributes within those queries" do
  #    val alias = selector.as("sql")
  #    alias('id).partial.toPseudoSQL should be === "sql.id"
  #  end
  #end
end
