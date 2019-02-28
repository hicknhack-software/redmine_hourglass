module TypeParsing
  extend ActiveSupport::Concern

  def parse_type(type, keys, params)
    keys = [keys] if keys.is_a? Symbol
    case type
    when :boolean
      keys.each do |key|
        params[key] = ActiveRecord::Type::Boolean.new.type_cast_from_user(params[key])
      end
    when :integer
      keys.each do |key|
        params[key] = ActiveRecord::Type::Integer.new.type_cast_from_user(params[key])
      end
    when :float
      keys.each do |key|
        params[key] = ActiveRecord::Type::Float.new.type_cast_from_user(params[key])
      end
    end
    params
  end
end
