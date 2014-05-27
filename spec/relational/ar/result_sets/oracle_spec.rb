begin
require_relative 'shared'

module Relational::AR::ResultSets
  describe Oracle do
    it_should_behave_like 'a result set' do
      let(:connection) { stub_connection({'ID' => 20, 'NAME' => 'Foo'}, {'ID' => 30, 'NAME' => 'Bar'}) }
    end

    def stub_connection(*hashes)
      conn = double
      conn.stub(:fetch_hash).and_return(*hashes, nil)
      double(execute: conn)
    end
  end
end

rescue LoadError
end
