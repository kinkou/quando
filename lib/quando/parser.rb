# frozen_string_literal: true

module Quando
  class Parser

    def initialize
      @config = nil
    end

    # @return [Quando::Parser]
    def configure
      yield(@config ||= Quando.config.dup)
      self
    end

    # @return [Quando::Config]
    def config
      @config || Quando.config
    end

    # @param text_date [String]
    # @return [Date, nil]
    def parse(text_date)
      config.formats.each do |regexp|
        @date_parts = text_date.match(regexp)
        next unless @date_parts

        @current_format = regexp
        year, month, day = detect_year, detect_month, detect_day
        next unless (year && month && day)

        return Date.new(year, month, day)
      end

      nil
    end

    private

    # @return [Integer, nil]
    def detect_year
      return Time.now.utc.year unless wanted?(:year)
      return unless found?(:year)

      year = @date_parts[:year].to_i
      year.abs < 100 ? year + century_to_hundreds : year
    end

    # @return [Integer, nil]
    def detect_month
      return 1 unless wanted?(:month)
      return unless found?(:month)

      month = @date_parts[:month]

      month_index = Quando::Config::MONTHS.find_index do |month_name|
        config.send(month_name) =~ month
      end

      if month_index
        month_index += 1
        return month_index if valid_month?(month_index)
      end

      month.to_i if valid_month?(month)
    end

    # @return [Integer, nil]
    def detect_day
      return 1 unless wanted?(:day)
      return unless found?(:day)

      day = @date_parts[:day].to_i
      day if valid_day?(day)
    end

    # @param date_part [Symbol]
    def found?(date_part)
      !@date_parts[date_part.to_s].to_s.squeeze.empty?
    end

    # @param date_part [Symbol]
    def wanted?(date_part)
      @current_format.names.include?(date_part.to_s)
    end

    # @param value [Integer]
    def valid_month?(value)
      (1..12).include?(value.to_i)
    end

    # @param value [Integer]
    def valid_day?(value)
      (1..31).include?(value.to_i)
    end

    def century_to_hundreds
      (config.century > 0 ? config.century - 1 : config.century + 1) * 100
    end

  end
end
