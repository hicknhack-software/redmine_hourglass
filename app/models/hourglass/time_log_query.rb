

module Hourglass
  class TimeLogQuery < Query
    include QueryBase

    set_available_columns(
        comments: {},
        user: {sortable: lambda { User.fields_for_order_statement }, groupable: true},
        date: {sortable: "#{queried_class.table_name}.start", groupable: sql_timezoned_date("#{queried_class.table_name}.start")},
        start: {},
        stop: {},
        hours: {totalable: true},
        booked?: {}
    )

    def initialize_available_filters
      add_user_filter
      add_date_filter
      add_comments_filter
      add_available_filter 'booked', label: :field_booked?, type: :list, values: [[I18n.t(:general_text_Yes), true]]
      add_associations_custom_fields_filters :user
    end

    def available_columns
      @available_columns ||= self.class.available_columns.dup.tap do |available_columns|
        UserCustomField.visible.each do |custom_field|
          available_columns << QueryAssociationCustomFieldColumn.new(:user, custom_field)
        end
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
