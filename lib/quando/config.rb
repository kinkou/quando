# encoding: utf-8
# frozen_string_literal: true

module Quando
  class Config

    AVAILABLE_OPTIONS = [
      :dlm, :year, :day,
      :jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec,
      :month_num, :month_txt,
      :formats
    ]

    attr_accessor *AVAILABLE_OPTIONS

    MONTHS = [:jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec]

    private_constant :AVAILABLE_OPTIONS

    def initialize
      @dlm = /[ -.\/\\]/
      @year = /(?<year>(?:\d{2})|(?:\d{4}))/i
      @month_num = /(?<month>(?:1[0-2])|(?:0?[1-9]))/
      @day = /(?<day>(?:[3][0-1])|(?:[1-2][0-9])|(?:0?[1-9]))/

      @jan = /(?:JANUARY)|(?:JAN\.?)/i
      @feb = /(?:FEBRUARY)|(?:FEB\.?)/i
      @mar = /(?:MARCH)|(?:MAR\.?)/i
      @apr = /(?:APRIL)|(?:APR\.?)/i
      @may = /(?:MAY\.?)/i
      @jun = /(?:JUNE)|(?:JUN\.?)/i
      @jul = /(?:JULY)|(?:JUL\.?)/i
      @aug = /(?:AUGUST)|(?:AUG\.?)/i
      @sep = /(?:SEPTEMBER)|(?:SEPT?\.?)/i
      @oct = /(?:OCTOBER)|(?:OCT\.?)/i
      @nov = /(?:NOVEMBER)|(?:NOV\.?)/i
      @dec = /(?:DECEMBER)|(?:DEC\.?)/i

      uniupdate!
    end

    def uniformats!
      @formats = [
        # 14.4.1965, 14/04/1965, 13-12-05
        /\A\s* #{@day} #{@dlm} #{@month_num} #{@dlm} #{@year} \s*\z/xi,

        # 14-APRIL-1965, 14-apr-65, 13/Dec/05, …
        /\A\s* #{@day} #{@dlm} #{@month_txt} #{@dlm} #{@year} \s*\z/xi,

        # April 1965, apr.1965, DEC-05, …
        /\A\s* #{@month_txt} #{@dlm} #{@year} \s*\z/xi,

        # April, DECEMBER, apr., …
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
