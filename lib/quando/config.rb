# encoding: utf-8
# frozen_string_literal: true

module Quando
  class Config

    MONTHS = [:jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec]
    AUTOUPDATE = [:dlm, :year, :year2, :day, *MONTHS, :month_num]
    COMPOUND = [:month_txt, :formats]
    OPTIONS = [*AUTOUPDATE, *COMPOUND]
    CENTURY = 21

    private_constant :AUTOUPDATE, :COMPOUND, :OPTIONS

    attr_accessor *OPTIONS

    def initialize
      @dlm = /[- .\/]+/
      @year = /(?<year>\d{4})/
      @year2 = /(?<year>\d{2})/
      @month_num = /(?<month> 1[012] | 0?[1-9])/x
      @day = /(?<day> 3[01] | [12]\d | 0?[1-9])/x

      @jan = /JAN(?:UARY)?/i
      @feb = /FEB(?:RUARY)?/i
      @mar = /MAR(?:CH)?/i
      @apr = /APR(?:IL)?/i
      @may = /MAY/i
      @jun = /JUNE?/i
      @jul = /JULY?/i
      @aug = /AUG(?:UST)?/i
      @sep = /SEP(?:TEMBER)?/i
      @oct = /OCT(?:OBER)?/i
      @nov = /NOV(?:EMBER)?/i
      @dec = /DEC(?:EMBER)?/i

      self.century=(CENTURY) # method call

      uniupdate!
    end

    # Sets @month_txt, a compound of all month regexps that matches any month name
    def unimonth!
      all_months_txt_rxs = MONTHS.map { |m| instance_variable_get("@#{m}".to_sym) }.join('|')
      @month_txt = Regexp.new("(?<month>#{all_months_txt_rxs})", true)
    end

    # Sets @formats which is an array of regexps used in succession to match and identify date parts
    def uniformats!
      @formats = [
        # Formats with a 4-digits year
        # 14.4.1965, 14/04/1965, 14-4-1965, 14 04 1965, …
        /^\s* #{@day} #{@dlm} #{@month_num} #{@dlm} #{@year} \s*$/xi,

        # 14-APRIL-1965, 14-apr-1965, 14/Apr/1965, …
        /^\s* #{@day} #{@dlm} #{@month_txt} #{@dlm} #{@year} \s*$/xi,

        # April 1965, apr.1965, …
        /^\s* #{@month_txt} #{@dlm} #{@year} \s*$/xi,

        # Same formats with a 2-digits year
        # 13.12.05, 13/12/05, 13-12-05, …
        /^\s* #{@day} #{@dlm} #{@month_num} #{@dlm} #{@year2} \s*$/xi,

        # April, DECEMBER, sep., …
        /^\s* #{@month_txt} \s*$/xi,
      ]
    end

    # @return [Integer]
    def century
      @century
    end

    # @param value [Integer]
    # @return [Integer]
    def century=(value)
      @century = (value == 0 ? 1 : value) || CENTURY
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
