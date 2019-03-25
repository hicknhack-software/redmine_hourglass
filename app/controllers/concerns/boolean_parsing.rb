module BooleanParsing
  extend ActiveSupport::Concern

  def parse_boolean(keys, params)
    keys = [keys] if keys.is_a? Symbol
    keys.each do |key|
      if Rails::VERSION::MAJOR <= 4
        params[key] = ActiveRecord::Type::Boolean.new.type_cast_from_user(params[key])
      else
        params[key] = ActiveRecord::Type::Boolean.new.cast(params[key])
      end
    end
    params
  end
end
