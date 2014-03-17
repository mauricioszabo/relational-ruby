require_relative '../../helper'

describe Relational::AR::SQLString do
  it 'returns a SQL string EXACTLY as we sent it' do
    str = Relational::AR::SQLString.new("FOO BAR baz")
    str.should have_pseudo_sql("FOO BAR baz")
  end
end
