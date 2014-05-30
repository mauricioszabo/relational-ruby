begin
require_relative 'shared'

module Relational::AR::ResultSets
  describe PostgreSQL do
    context 'when driver supports single row mode' do
      let(:pg) { double(send_query: nil, set_single_row_mode: nil) }
      let(:pool) { double(checkin: nil, checkout: checked_conn) }
      let(:checked_conn) { double(instance_variable_get: pg) }

      let(:connection) do
        pg.stub(:get_result).and_return(
          double(to_a: [{'id' => 20, 'name' => 'Foo'}]),
          double(to_a: [{'id' => 30, 'name' => 'Bar'}]),
          nil)

        double(connection_pool: pool)
      end

      it_should_behave_like 'a result set'

      it 'resets the connection if each is broken' do
        pg.should_receive(:reset)
        pool.should_receive(:checkin).with(checked_conn)
        PostgreSQL.new(connection, "QUERY").each { |x| break }
      end
    end

    context 'when driver does not support single row mode' do
      it_should_behave_like 'a result set' do
        let(:connection) do
          pg = double(send_query: nil)
          each = double()
          each.stub(:each).and_yield('id' => 20, 'name' => 'Foo').and_yield('id' => 30, 'name' => 'Bar')
          pg.stub(:get_result).and_return(each, nil)

          double(
            connection_pool: double(
              checkin: nil,
              checkout: double(
                instance_variable_get: pg
              )
            )
          )
        end
      end
    end
  end
end

rescue LoadError
end

