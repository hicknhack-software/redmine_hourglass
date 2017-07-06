module DateTimeParsing
  extend ActiveSupport::Concern

  def date_time_format
    date = Setting.date_format.blank? ? I18n.t('date.formats.default') : Setting.date_format
    time = Setting.time_format.blank? ? I18n.t('time.formats.time') : Setting.time_format
    "#{date} #{time}"
  end

  def parse_date_time(params = self.params)
    params.each do |k, v|
      parse_date_time(v) if v.is_a? Hash
      v.each { parse_date_time(v) } if v.is_a? Array
      params[k] = DateTime.strptime(v + " #{utc_offset}", date_time_format + ' %:z') if %w(start stop).include? k
    end
  end

  def utc_offset
    user_time_zone = User.current.time_zone
    return user_time_zone.formatted_offset if user_time_zone
    time = Time.now
    return time.localtime.formatted_offset if time.utc?
    time.formatted_offset
  end
end
