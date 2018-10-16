# encoding: utf-8
# frozen_string_literal: true

module Quando
  class Config

    MONTHS = [:jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec]

    OPTIONS = [:dlm, :year, :year2, :day, *MONTHS, :month_num, :month_txt, :formats, :century]

    private_constant :OPTIONS

    attr_accessor *OPTIONS

    def initialize
      @century = 2000

      @dlm = /[ -.\/\\]+/
      @year = /(?<year> \d{4})/x
      @year2 = /(?<year> \d{2})/x
      @month_num = /(?<month> 1[0-2] | 0?[1-9])/x
      @day = /(?<day> 3[0-1] | [12][0-9] | 0?[1-9])/x

      @jan = /JANUARY | JAN/ix
      @feb = /FEBRUARY | FEB/ix
      @mar = /MARCH | MAR/ix
      @apr = /APRIL | APR/ix
      @may = /MAY/ix
      @jun = /JUNE | JUN/ix
      @jul = /JULY | JUL/ix
      @aug = /AUGUST | AUG/ix
      @sep = /SEPTEMBER | SEPT?/ix
      @oct = /OCTOBER | OCT/ix
      @nov = /NOVEMBER | NOV/ix
      @dec = /DECEMBER | DEC/ix

      uniupdate!
    end

    def uniformats!
      @formats = [
        # Formats with a 4-digits year
        # 14.4.1965, 14/04/1965, 14-4-1965, 14 04 1965, 14\04\1965, …
        /\A\s* #{@day} #{@dlm} #{@month_num} #{@dlm} #{@year} \s*\z/xi,

        # 14-APRIL-1965, 14-apr-1965, 14/Apr/1965, …
        /\A\s* #{@day} #{@dlm} #{@month_txt} #{@dlm} #{@year} \s*\z/xi,

        # April 1965, apr.1965, …
        /\A\s* #{@month_txt} #{@dlm} #{@year} \s*\z/xi,

        # Same formats with a 2-digits year
        # 13.12.05, 13/12/05, 13-12-05, …
        /\A\s* #{@day} #{@dlm} #{@month_num} #{@dlm} #{@year2} \s*\z/xi,

        # 13-DECEMBER-05, 13-dec-05, …
        /\A\s* #{@day} #{@dlm} #{@month_txt} #{@dlm} #{@year2} \s*\z/xi,

        # Dec 05, dec.05, DEC-05, …
        /\A\s* #{@month_txt} #{@dlm} #{@year2} \s*\z/xi,

        # April, DECEMBER, sep., …
        /\A\s* #{@month_txt} \s*\z/xi,
      ]
    end

    def unimonth!
      all_months_txt_rxs = MONTHS.map { |m| instance_variable_get("@#{m}".to_sym) }.join('|')
      @month_txt = Regexp.new("(?<month>#{all_months_txt_rxs})", true)
    end

    def uniupdate!
      unimonth!
      uniformats!
    end

  end

  # @return [Quando::Config]
  def self.config
    @config ||= Config.new
  end

  def self.configure
    config unless @config
    yield(config) if block_given?
  end

  def self.reset!
    @config = Config.new
  end

  configure

end
