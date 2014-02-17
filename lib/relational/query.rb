module Relational
  module Query
    class NO_OPT
    end

    class PartialQuery
      include Query

      def initialize(table, selector)
        @table = table
        @selector = selector
      end
    end

    def table
      @table ||= Tables::Table.new(table_name)
    end

    def set_table(table)
      @table = table
    end

    def table_name
      @table_name ||= begin
        class_name = if(self.is_a?(Class))
          name.split("::").last
        else
          self.class.name.split("::").last
        end

        class_name.gsub!(/[A-Z]/) { |letter| "_" + letter.downcase }
        if class_name[0] == "_"
          class_name[1..-1]
        else
          class_name
        end
      end
    end

    def set_table_name(name)
      @table_name = name
    end

    def all
      new_partial_query
    end

    def new_partial_query(options={})
      new_partial_query = selector.copy(options)
      PartialQuery.new(table, new_partial_query)
    end
    private :new_partial_query

    def selector
      @selector ||= Selector.new(
        select: Select[table.*],
        from: ListOfAttributes[table]
      )
    end

    def select(*fields)
      if fields.empty?
        selector.opt(:select)
      else
        select = Select[*convert_fields(fields)]
        new_partial_query(select: select)
      end
    end

    def distinct(*fields)
      select = Select[*convert_fields(fields)].distinct
      new_partial_query(select: select)
    end

    def convert_fields(fields)
      fields.flat_map do |field|
        case field
        when ListOfPartials then convert_fields(field.to_a)
        when Symbol then table[field]
        when Attributes::Literal
          if field.literal.is_a?(Symbol)
            table[field.literal]
          else
            field
          end
        else Partial.wrap(field)
        end
      end
    end
    private :convert_fields

    def query
      new_query = all
      t = table
      new_query.singleton_class.send :define_method, :[] do |value|
        t[value]
      end

      new_query.singleton_class.send :define_method, :method_missing do |method, *args, &b|
        if args.size == 0 && b.nil?
          t[method]
        else
          super
        end
      end

      yield new_query
    end

    def from
      @from ||= ListOfAttributes[table]
    end

    def where(condition=NO_OPT, &block)
      if NO_OPT != condition
        new_partial_query(where: condition)
      elsif block
        where = block.call(table)
        new_partial_query(where: where)
      else
        selector.opt(:where)
      end
    end

    def group(*fields)
      if fields.empty?
        selector.opt(:group)
      else
        group = ListOfAttributes[*convert_fields(fields)]
        new_partial_query(group: group)
      end
    end

    def having(condition=NO_OPT, &block)
      if NO_OPT != condition
        new_partial_query(having: condition)
      elsif block
        having = block.call(table)
        new_partial_query(having: having)
      else
        selector.opt(:having)
      end
    end

    def join
      @join ||= Selector::DEFAULTS[:join]
    end

    def order
      @order  ||= Selector::DEFAULTS[:order]
    end

    def limit
      @limit  ||= Selector::DEFAULTS[:limit]
    end

    def offset
      @offset ||= Selector::DEFAULTS[:offset]
    end

    def partial
      selector.partial
    end
  end
end
