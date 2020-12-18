TIME_RANGES = {
  all: (0..23),
  day: (9..17),
  night: (18..23),
  morning: (6..11),
  afternoon: (12..17),
  evening: (17..21),
  midnight: (0..4)
}.freeze

def faker_between(from, to, period = :all, format = nil)
  raise ArgumentError, 'invalid period' unless TIME_RANGES.key? period
  date = Faker::Date.between(from: from, to: to)
  time = ::Time.local(date.year, date.month, date.day, Faker::Base.sample(TIME_RANGES[period].to_a), Faker::Base.sample((0..59).to_a), Faker::Base.sample((0..59).to_a))
  format.nil? ? time : I18n.l(DateTime.parse(time.to_s), format: format)
end
