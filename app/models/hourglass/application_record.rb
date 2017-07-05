module Hourglass
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    before_save :execute_temporary_proc

    def serializable_hash(options)
      super(options).select { |_, v| v }
    end

    def with_before_save(proc)
      @temporary_proc = proc
      result = yield
      @temporary_proc = nil
      result
    end

    private
    attr_accessor :temporary_proc

    def execute_temporary_proc
      temporary_proc.call if temporary_proc.is_a? Proc
    end
  end
end
