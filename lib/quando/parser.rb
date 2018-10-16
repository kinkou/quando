# frozen_string_literal: true

module Quando

  class Parser

    def initialize
      @config = nil
    end

    # @return [Quando::Parser]
    def configure
      yield(@config = Quando.config.dup)
      self
    end

    # @return [Quando::Config]
    def config
      @config || Quando.config
    end

    # @param text_date [String]
    # @return [Date, nil]
    def parse(text_date)
      config.formats.each do |rx|
        @date_parts = text_date.match(rx)
        next unless @date_parts

        @current_format = rx
        year, month, day = detect_year, detect_month, detect_day
        next unless (year && month && day)

        return Date.new(year, month, day)
      end

      nil
    end

    private

    # @return [Integer, nil]
    def detect_year
      unless searched?(:year)
        return Time.current.year if Time.respond_to?(:current)
        return Time.now.getlocal.year
      end

      return unless found?(:year)

      year = @date_parts[:year].to_i
      year < 100 ? year + config.century : year
    end

    # @return [Integer, nil]
    def detect_month
      return 1 unless searched?(:month)
      return unless found?(:month)

      month = @date_parts[:month]

      if config.month_num.match(month)
        month.to_i
      else
        month_index = Quando::Config::MONTHS.find_index do |month_name|
          month_name_rx = config.send(month_name)
          month_name_rx.match(month)
        end

        month_index + 1 if month_index
      end
    end

    # @return [Integer, nil]
    def detect_day
      return 1 unless searched?(:day)
      return unless found?(:day)

      day = @date_parts[:day].to_i
      day if (1..31).include?(day)
    end

    # @param date_part [Symbol]
    def found?(date_part)
      !@date_parts[date_part.to_s].to_s.squeeze.empty?
    end

    # @param date_part [Symbol]
    def searched?(date_part)
      !!@current_format.named_captures[date_part.to_s]
    end

  end

end
