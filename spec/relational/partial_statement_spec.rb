require_relative '../helper'

module Relational
  describe PartialStatement do
    it 'has a "pseudo-sql" representation' do
      partial = PartialStatement.new("str = ? AND num = ?", ['foo', 10])
      partial.to_pseudo_sql.should == "str = 'foo' AND num = 10"
    end

    it 'has a pseudo-sql when attributes have interrogation' do
      partial = PartialStatement.new("str = ? AND num = ?", ['foo?', 10])
      partial.to_pseudo_sql.should == "str = 'foo?' AND num = 10"
    end
  end
end
