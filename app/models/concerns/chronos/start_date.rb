module Chronos::StartDate
  extend ActiveSupport::Concern

  def date
    start.to_date
  end
end
