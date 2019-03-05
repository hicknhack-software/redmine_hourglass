module BooleanParsing
  extend ActiveSupport::Concern

  def parse_boolean(keys, params)
    keys = [keys] if keys.is_a? Symbol
    keys.each do |key|
      params[key] = ActiveRecord::Type::Boolean.new.type_cast_from_user(params[key])
    end
    params
  end
end
