module Nlp

  class SqlQuery
    def initialize
      @from = Array.new
      @select = Hash.new
      @where = Hash.new
    end
    def addTable(table)
      @from << table
    end
    def addField(table, field)
      @select.has_key?(table) ? @select[table] << field : @select[table] = [field]
    end
    def addCondition(table, field, operator, value)
      condition = SqlCondition.new(table + "." + field, operator, value)
      @where.has_key?(table) ? @where[table] << condition : @where[table] = [condition]
    end
    def to_s
      ret = ""
      @from.each do |table|
        if @select.has_key?(table)
          ret += "SELECT " + @select[table].join(", ")
        end
        ret += " FROM " + table
        if @where.has_key?(table)
          ret += " WHERE " + @where[table].join(" AND ")
        end
      end
      return ret
    end
  end
  class SqlCondition
    def initialize(field, operator, value)
      @field = field
      @operator = operator
      @value = value
    end
    def to_s
      return @field + " " + @operator + " " + @value
    end
  end
end
