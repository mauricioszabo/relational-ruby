require_relative '../helper'

module Relational
  class People
    extend Query
  end

  describe Query do
    it "finds all records on a table" do
      result = People.all
      result.should have_pseudo_sql "SELECT people.* FROM people"
    end

    it "finds records on a table" do
      result = People.where { |p| (p[:id] > 1) & (p[:id] < 3) }.select(:id, :name)
      result.should have_pseudo_sql "SELECT people.id, people.name " +
        "FROM people WHERE (people.id > 1 AND people.id < 3)"
    end

    it "finds records using HAVING" do
      result = People.having { |p| (p[:id] > 1) & (p[:id] < 3) }.select(:id, :name).group(:id)
      result.should have_pseudo_sql "SELECT people.id, people.name FROM people "+
        "GROUP BY people.id HAVING (people.id > 1 AND people.id < 3)"
    end

    it "finds records reusing 'table' object" do
      result = People.query { |p| p.where(p.id > 10).select(p[:id], p[:name]) }
      result.should have_pseudo_sql "SELECT people.id, people.name FROM people "+
        "WHERE people.id > 10"
    end

    it "finds distinct records" do
      People.distinct(:id, :name).should have_pseudo_sql "SELECT DISTINCT "+
        "people.id, people.name FROM people"
    end

    it 'selects correctly fields' do
      result = People.select(:id)
      result.should have_pseudo_sql "SELECT people.id FROM people"

      result = result.select(:name)
      result.should have_pseudo_sql "SELECT people.name FROM people"

      result = result.select(result.select + :id)
      result.should have_pseudo_sql "SELECT people.name, people.id FROM people"

      result = result.select(:age, result.select)
      result.should have_pseudo_sql "SELECT people.age, people.name, people.id FROM people"
    end

#    "join another table" in {
#      val address = People join 'scala_addresses on { (p, a) => p('id) == a('person_id) }
#      results(address) should be === List((1, "Foo"), (1, "Foo"), (2, "Foo"))
#    }
#
#    "join another with a join object" in {
#      val table = new tables.Table("scala_addresses")
#      val join = new joins.InnerJoin(table, table('person_id) == People.table('id))
#      val address = People join Seq(join)
#      results(address) should be === List((1, "Foo"), (1, "Foo"), (2, "Foo"))
#    }
#
#    "left join another table" in {
#      val address = People leftJoin 'scala_addresses on { (p, a) => p('id) == a('person_id) }
#      results(address) should be === List((1, "Foo"), (1, "Foo"), (2, "Foo"), (3, "Bar"))
#    }
#
#    "counts records on table" in {
#      val names = People query { implicit p => p select ('name.count.as("count"), 'name) group 'name }
#
#      val results = names.copy(connection=globalConnection).results.map { e =>
#        (e attribute 'count as Int, e get 'name)
#      }
#      results should be === List( (2, "Foo"), (1, "Bar") )
#    }
#
#    "order the query" in {
#      val desc = People query { implicit p => p order 'id.desc }
#      results(desc) should be === List( (3, "Bar"), (2, "Foo"), (1, "Foo") )
#    }
#
#    "subselect another query" in {
#      val desc = People query { implicit p => p order 'id.desc }
#      val r = People query { implicit p => p from desc.as("bar") where { p => p('name) -> "Foo" } }
#      results(r) should be === List( (2, "Foo"), (1, "Foo") )
#    }
#
#    "order the query with a subselect" in {
#      object Addresses extends Query { table = "scala_addresses" }
#
#      val primaryQuery = People select '*
#      val r = primaryQuery order {
#        Addresses where { a => a('id) == primaryQuery.table('id) } select 'address
#      }
#
#      r.partial.toPseudoSQL should be === ("SELECT scala_people.* FROM scala_people ORDER BY " +
#        "(SELECT scala_addresses.address FROM scala_addresses WHERE scala_addresses.id = scala_people.id)")
#    }
#  }
#
#  "Query using implicit conversions" should {
#    "find records using symbols" in {
#      var two = People where (implicit p => 'id > 1 && 'id < 3) select ('id, 'name)
#      results(two) should be === List((2, "Foo"))
#
#      two = People where (implicit p => 'id -> 2) select ('id, 'name)
#      results(two) should be === List((2, "Foo"))
#    }
#
#    "find records using symbols and 'query' method" in {
#      val two = People query { implicit p => p where ('id > 1 && 'id < 3) select ('id, 'name) }
#      results(two) should be === List((2, "Foo"))
#    }
#  }
#
#  "Query on more than one table" should {
#    "cast to the first table in FROM" in {
#      val desc = People query { implicit p => p order 'id.desc }
#      val result = People query { implicit p => p
#        .from(desc as "sql")
#        .order { p => Seq(p.name) }
#        .join('scala_addresses).on { (p, a) => p.id == a.person_id }
#        .select('id)
#      }
#
#      result.partial.toPseudoSQL should be === (
#        "SELECT sql.id FROM (SELECT * FROM scala_people ORDER BY (scala_people.id) DESC) sql " +
#        "INNER JOIN scala_addresses ON sql.id = scala_addresses.person_id " +
#        "ORDER BY sql.name"
#      )
#    }
#  }
  end
end
