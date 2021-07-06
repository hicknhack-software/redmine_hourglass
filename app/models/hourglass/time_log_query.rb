

module Hourglass
  class TimeLogQuery < Query
    include QueryBase
    self.queried_class = TimeLog

    self.available_columns = [
      QueryColumn.new(:comments),
      QueryColumn.new(:user, sortable: lambda { User.fields_for_order_statement }, groupable: true),
      TimestampQueryColumn.new(:date, sortable: "#{TimeLog.table_name}.start", groupable: true),
      QueryColumn.new(:start),
      QueryColumn.new(:stop),
      QueryColumn.new(:hours, totalable: true),
      QueryColumn.new(:booked?),
    ]

    def initialize(attributes=nil, *args)
      super attributes
      self.filters ||= {'date' => {:operator => "m", :values => [""]}}
    end

    def initialize_available_filters
      add_user_filter
      add_date_filter
      add_comments_filter
      add_available_filter 'booked', label: :field_booked?, type: :list, values: [[I18n.t(:general_text_Yes), true]]
      add_associations_custom_fields_filters :user
    end

    def available_columns
      @available_columns ||= self.class.available_columns.dup.tap do |available_columns|
        # 2021-07-06 arBmind: custom fields for users cannot be properly authorized
        # available_columns.push *associated_custom_field_columns(:user, UserCustomField, totalable: false)
      end
    end

    def default_columns_names
      @default_columns_names ||= [:booked?, :date, :start, :stop, :hours, :comments]
    end

    def base_scope
      super.eager_load(:user, time_booking: :project)
    end

    def sql_for_booked_field(field, operator, _value)
      operator_to_use = operator == '=' ? '*' : '!*'
      sql_for_field(field, operator_to_use, nil, TimeBooking.table_name, 'id')
    end

    def sql_for_comments_field(field, operator, value)
      sql_for_field(field, operator, value, TimeLog.table_name, 'comments', true)
    end

    def total_for_hours(scope)
      map_total(
          scope.sum db_datetime_diff "#{queried_class.table_name}.start", "#{queried_class.table_name}.stop"
      ) { |t| Hourglass::DateTimeCalculations.in_hours(t).round(2) }
    end

    private
    def db_datetime_diff(datetime1, datetime2)
      case ActiveRecord::Base.connection.adapter_name.downcase.to_sym
        when :mysql2
          "TIMESTAMPDIFF(SECOND, #{datetime1}, #{datetime2})"
        when :sqlite
          "(strftime('%s', #{datetime2}) - strftime('%s', #{datetime1}))"
        when :postgresql
          "EXTRACT(EPOCH FROM (#{datetime2} - #{datetime1}))"
        else
          "(#{datetime2} - #{datetime1})"
      end
    end
  end
end
