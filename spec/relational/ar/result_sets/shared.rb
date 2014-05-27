require 'active_record'
require_relative '../../../helper'

shared_examples "a result set" do
  it 'returns a result set' do
    rs = described_class.new(connection, 'SELECT *')
    rs.next.should == {'id' => 20, 'name' => 'Foo'}
    rs.next.should == {'id' => 30, 'name' => 'Bar'}
    rs.next.should be_nil
    rs.next.should be_nil
  end

  it 'transforms into a array' do
    rs = described_class.new(connection, 'SELECT *')
    rs.to_a.should == [
      {'id' => 20, 'name' => 'Foo'},
      {'id' => 30, 'name' => 'Bar'}
    ]
  end
end
