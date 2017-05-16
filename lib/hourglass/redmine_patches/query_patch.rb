module Hourglass
  module RedminePatches
    module QueryPatch
      extend ActiveSupport::Concern

      def self.prepended(klass)
        klass.class_eval do
          self.operators = operators.merge 'q' => :label_this_quarter
          self.operators_by_filter_type[:date] << 'q'
          self.operators_by_filter_type[:date_past] << 'q'
        end
      end

      def validate_query_filters
        filters.each_key do |field|
          if values_for(field)
            case type_for(field)
              when :integer
                add_filter_error(field, :invalid) if values_for(field).detect {|v| v.present? && !v.match(/\A[+-]?\d+(,[+-]?\d+)*\z/) }
              when :float
                add_filter_error(field, :invalid) if values_for(field).detect {|v| v.present? && !v.match(/\A[+-]?\d+(\.\d*)?\z/) }
              when :date, :date_past
                case operator_for(field)
                  when "=", ">=", "<=", "><"
                    add_filter_error(field, :invalid) if values_for(field).detect {|v|
                      v.present? && (!v.match(/\A\d{4}-\d{2}-\d{2}(T\d{2}((:)?\d{2}){0,2}(Z|\d{2}:?\d{2})?)?\z/) || parse_date(v).nil?)
                    }
                  when ">t-", "<t-", "t-", ">t+", "<t+", "t+", "><t+", "><t-"
                    add_filter_error(field, :invalid) if values_for(field).detect {|v| v.present? && !v.match(/^\d+$/) }
                end
            end
          end

          add_filter_error(field, :blank) unless
              # filter requires one or more values
              (values_for(field) and !values_for(field).first.blank?) or
                  # filter doesn't require any value
                  ["o", "c", "!*", "*", "t", "ld", "w", "lw", "l2w", "m", "lm", "y", "*o", "!o", "q"].include? operator_for(field)
        end if filters
      end
    end
  end
end
