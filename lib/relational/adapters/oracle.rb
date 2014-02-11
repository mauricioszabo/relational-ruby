require_relative 'default'

module Relational
  module Adapters
    module Oracle
      extend Default
    end

    register_driver('oracle', Oracle)
  end
end

