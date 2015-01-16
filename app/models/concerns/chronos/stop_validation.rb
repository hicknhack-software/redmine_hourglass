module Chronos::StopValidation
  extend ActiveSupport::Concern

  private
  def stop_is_valid
    errors.add :stop, :invalid if stop.present? && start.present? && stop <= start
  end
end