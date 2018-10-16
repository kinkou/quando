# encoding: utf-8
# frozen_string_literal: true

module Quando
  class Config

    MONTHS = [:jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec]
    AUTOUPDATE = [:dlm, :year, :year2, :day, *MONTHS, :month_num]
    COMPOUND = [:month_txt, :formats]
    OPTIONS = [*AUTOUPDATE, *COMPOUND, :century]

    private_constant :AUTOUPDATE, :COMPOUND, :OPTIONS

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

    # Sets @month_txt which is a compound of all month regexps and matches any month name
    def unimonth!
      all_months_txt_rxs = MONTHS.map { |m| instance_variable_get("@#{m}".to_sym) }.join('|')
      @month_txt = Regexp.new("(?<month>#{all_months_txt_rxs})", true)
    end

    # Sets @formats which is an array of regexps used in succession to match and identify parts of the dates
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

    # A single method to update all compound matchers when a part matcher was changed
    def uniupdate!
      unimonth!
      uniformats!
    end

    # Batch-define setters for date part matchers (listed in AUTOUPDATE) that, when set,
    # automatically update the compound matchers (listed in COMPOUND)
    AUTOUPDATE.each do |var|
      # def jan=(regexp)
      #   return regexp if @jan == regexp
      #   @jan = regexp
      #   uniupdate!
      # end
      define_method("#{var}=".to_sym) do |regexp|
        var_name = "@#{var}".to_sym
        return regexp if instance_variable_get(var_name) == regexp
        instance_variable_set(var_name, regexp)
        uniupdate!
      end
    end
  end

  # Quando's class-level configuration
  # @return [Quando::Config]
  def self.config
    @config ||= Config.new
  end

  # @return [Quando::Config]
  def self.configure
    config unless @config
    yield(config) if block_given?
    @config
  end

  # Reset Quando's class-level configuration to defaults
  # @return [Quando::Config]
  def self.reset!
    @config = Config.new
  end

  configure

end
