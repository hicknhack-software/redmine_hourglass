module BooleanParsing
  extend ActiveSupport::Concern

  def parse_boolean(keys, params = self.params)
    keys = [keys] if keys.is_a? Symbol
    keys.each do |key|
      params[key] = case params[key].class.name
                      when 'String'
                        params[key] == '1' || params[key] == 'true'
                      when 'Fixnum', 'Integer'
                        params[key] == 1
                      else
                        params[key]
                    end
    end
    params
  end

  def parse_float(keys, params = self.params)
    keys = [keys] if keys.is_a? Symbol
    keys.each do |key|
      params[key] = case params[key].class.name
                    when 'String', 'Fixnum', 'Integer'
                      params[key].to_f
                    else
                      params[key]
                    end
    end
    params
  end

  def parse_int(keys, params = self.params)
    keys = [keys] if keys.is_a? Symbol
    keys.each do |key|
      params[key] = case params[key].class.name
                    when 'String', 'Fixnum', 'Integer'
                      params[key].to_i
                    else
                      params[key]
                    end
    end
    params
  end
end
