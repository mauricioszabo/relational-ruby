module Relational
  module Lazy
    def lazy(name, &block)
      lazies = @lazies ||= {}

      define_method name do
        lazies[name] ||= instance_exec(&block)
      end
    end
  end
end
