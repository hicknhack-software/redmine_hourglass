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
      v.each { parse_date_time(v) } if v.is_a?(Array) && v.all? { |vv| vv.is_a? Hash }
      if %w(start stop).include?(k) && !iso_string?(v)
        params[k] = DateTime.strptime(detranslate(v) + " #{utc_offset}", date_time_format + ' %:z')
      end
    end
  end

  def utc_offset
    user_time_zone = User.current.time_zone
    return user_time_zone.now.formatted_offset if user_time_zone
    time = Time.now
    return time.localtime.formatted_offset if time.utc?
    time.formatted_offset
  end

  def date_time_strings_map
    translated = I18n.t([:month_names, :abbr_month_names, :day_names, :abbr_day_names], scope: :date).flatten.compact +
        I18n.t([:am, :pm], scope: :time) + I18n.t([:am, :pm], scope: :time).map(&:upcase)
    original = (Date::MONTHNAMES + Date::ABBR_MONTHNAMES + Date::DAYNAMES + Date::ABBR_DAYNAMES + %w(am pm AM PM)).compact
    translated.zip(original)
  end

  private
  def detranslate(datetime_string)
    date_time_strings_map.inject(datetime_string) { |str, (k, v)| str.gsub(k, v) }
  end

  def iso_string?(datetime_string)
    DateTime.iso8601 datetime_string
    true
  rescue ArgumentError
    false
  end
end
