module Hourglass::TypeParsing
  def parse_type(type, attribute)
    if Rails::VERSION::MAJOR <= 4
      case type
      when :boolean
        ActiveRecord::Type::Boolean.new.type_cast_from_user(attribute)
      when :integer
        ActiveRecord::Type::Integer.new.type_cast_from_user(attribute)
      when :float
        ActiveRecord::Type::Float.new.type_cast_from_user(attribute)
      end
    else
      case type
      when :boolean
        ActiveRecord::Type::Boolean.new.cast(attribute)
      when :integer
        ActiveRecord::Type::Integer.new.cast(attribute)
      when :float
        ActiveRecord::Type::Float.new.cast(attribute)
      end
    end
  end
end