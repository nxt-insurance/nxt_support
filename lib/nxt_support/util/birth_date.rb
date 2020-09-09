# frozen_string_literal: true

module NxtSupport
  class BirthDate
    include NxtInit
    attr_init date: ->(date_or_string) { parse_date(date_or_string) }

    def to_age(today = Date.current)
      today.year - date.year - (today.month > date.month || (today.month == date.month && today.day >= date.day) ? 0 : 1)
    end

    def to_age_in_months(today = Date.current)
      (today.year * 12 + today.month) - (date.year * 12 + date.month)
    end

    def to_date
      date
    end

    private

    def parse_date(date_or_string)
      date_or_string.is_a?(Date) ? date_or_string : Date.parse(date_or_string)
    end
  end
end
