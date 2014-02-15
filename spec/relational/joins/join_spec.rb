require_relative '../../helper'

module Relational::Joins
  describe Join do
    let(:people) { Relational::Tables::Table.new("people") }
    let(:addresses) { Relational::Tables::Table.new("addresses") }

    it "creates left joins" do
      join = LeftJoin.new(addresses, people[:id] == addresses[:people_id])
      join.should have_pseudo_sql "LEFT JOIN addresses ON people.id = addresses.people_id"
    end

    it "creates right joins" do
      join = RightJoin.new(addresses, people[:id] == addresses[:people_id])
      join.should have_pseudo_sql "RIGHT JOIN addresses ON people.id = addresses.people_id"
    end

    it "creates inner joins" do
      join = InnerJoin.new(addresses, people[:id] == addresses[:people_id])
      join.should have_pseudo_sql "INNER JOIN addresses ON people.id = addresses.people_id"
    end
  end
end
