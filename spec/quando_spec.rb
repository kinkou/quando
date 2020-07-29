# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'securerandom'

RSpec.describe Quando do
  let(:d1965_4_14) { Date.new(1965, 4, 14) }

  def current_year
    Time.now.utc.year
  end

  def freeze_time(time)
    Time.class_exec do
      @_quando_time = time

      class << self
        def frozen_now
          @_quando_time
        end
        
        alias_method :original_now, :now
        alias_method :now, :frozen_now
      end
    end
  end

  def unfreeze_time
    Time.class_exec do
      class << self
        alias_method :now, :original_now
        remove_method :frozen_now
        remove_method :original_now
      end

      remove_instance_variable(:@_quando_time)
    end
  end

  describe 'Default matchers' do
    describe 'Day' do
      it 'Parses 1-digit unpadded' do
        expect(Quando.parse '1.10.2020').to eq(Date.new(2020, 10, 1))
      end

      it 'Parses 1-digit 0-padded' do
        expect(Quando.parse '01.10.2020').to eq(Date.new(2020, 10, 1))
      end

      it 'Parses 2-digit' do
        expect(Quando.parse '31.10.2020').to eq(Date.new(2020, 10, 31))
      end

      it 'Does not match out-of-range values' do
        expect(Quando.parse '0.10.2020').to be_nil
        expect(Quando.parse '32.10.2020').to be_nil
      end

      it 'Requires anchors to work properly' do
        expect('32'[Quando.config.day]).to eq('3')

        unanchored = /#{Quando.config.day} \. #{Quando.config.month_num} \. #{Quando.config.year}/xi
        expect(Quando.parse '32.10.2020', matcher: unanchored).to eq(Date.new(2020, 10, 2))
      end
    end

    describe 'Numerical month' do
      it 'Parses 1-digit unpadded' do
        expect(Quando.parse '14.4.1965').to eq(d1965_4_14)
      end

      it 'Parses 1-digit 0-padded' do
        expect(Quando.parse '14.04.1965').to eq(d1965_4_14)
      end

      it 'Parses 2-digit' do
        expect(Quando.parse '11.12.2020').to eq(Date.new(2020, 12, 11))
      end

      it 'Does not match out-of-range values' do
        expect(Quando.parse '1.0.2020').to be_nil
        expect(Quando.parse '1.13.2020').to be_nil
      end

      it 'Requires anchors to work properly' do
        expect('13'[Quando.config.month_num]).to eq('1')
      end
    end

    describe 'Textual month' do
      it 'Parses short English month names' do
        expect(Quando.parse '2 jan 2020').to eq(Date.new(2020, 1, 2))
        expect(Quando.parse '3 Feb 2020').to eq(Date.new(2020, 2, 3))
        expect(Quando.parse '4 MAR 2020').to eq(Date.new(2020, 3, 4))
        expect(Quando.parse '5 apr 2020').to eq(Date.new(2020, 4, 5))
        expect(Quando.parse '6 May 2020').to eq(Date.new(2020, 5, 6))
        expect(Quando.parse '7 JUN 2020').to eq(Date.new(2020, 6, 7))
        expect(Quando.parse '8 jul 2020').to eq(Date.new(2020, 7, 8))
        expect(Quando.parse '9 Aug 2020').to eq(Date.new(2020, 8, 9))
        expect(Quando.parse '10 SEP 2020').to eq(Date.new(2020, 9, 10))
        expect(Quando.parse '11 oct 2020').to eq(Date.new(2020, 10, 11))
        expect(Quando.parse '12 Nov 2020').to eq(Date.new(2020, 11, 12))
        expect(Quando.parse '13 DEC 2020').to eq(Date.new(2020, 12, 13))
      end

      it 'Parses long English month names' do
        expect(Quando.parse '2 january 2020').to eq(Date.new(2020, 1, 2))
        expect(Quando.parse '3 February 2020').to eq(Date.new(2020, 2, 3))
        expect(Quando.parse '4 MARCH 2020').to eq(Date.new(2020, 3, 4))
        expect(Quando.parse '5 april 2020').to eq(Date.new(2020, 4, 5))
        expect(Quando.parse '6 May 2020').to eq(Date.new(2020, 5, 6))
        expect(Quando.parse '7 JUNE 2020').to eq(Date.new(2020, 6, 7))
        expect(Quando.parse '8 july 2020').to eq(Date.new(2020, 7, 8))
        expect(Quando.parse '9 August 2020').to eq(Date.new(2020, 8, 9))
        expect(Quando.parse '10 SEPTEMBER 2020').to eq(Date.new(2020, 9, 10))
        expect(Quando.parse '11 october 2020').to eq(Date.new(2020, 10, 11))
        expect(Quando.parse '12 November 2020').to eq(Date.new(2020, 11, 12))
        expect(Quando.parse '13 DECEMBER 2020').to eq(Date.new(2020, 12, 13))
      end
    end

    describe 'Year' do
      it 'Parses 4-digit year' do
        expect(Quando.parse '13.12.2020').to eq(Date.new(2020, 12, 13))
      end

      it 'Parses 2-digit year' do
        expect(Quando.parse '13.12.20').to eq(Date.new(2020, 12, 13))
      end

      it 'Does not parse > 4 digits' do
        expect(Quando.parse '13.12.12345').to be_nil
      end

      it 'Does not parse < 2 digits' do
        expect(Quando.parse '13.12.1').to be_nil
      end

      it 'Requires anchors to work properly' do
        expect('12345'[Quando.config.year]).to eq('1234')

        unanchored = /#{Quando.config.day} \. #{Quando.config.month_num} \. #{Quando.config.year}/xi
        expect(Quando.parse '13.12.12345', matcher: unanchored).to eq(Date.new(1234, 12, 13))
      end

      it 'Uses current UTC year for yearless dates' do
        offset = 3 * 60 * 60 # +3 hours
        moment_x = Time.new(2020, 1, 1, 0, 0, 0, offset) # Jan 1 2020 00:00:00 +0300 == Dec 31 2019 21:00:00 +0000
        freeze_time(moment_x)

        expect(Time.now.year).to eq(2020)
        expect(Time.now.utc.year).to eq(2019)
        matcher = /#{Quando.config.day}\.#{Quando.config.month_num}/
        expect(Quando.parse '2.3', matcher: matcher).to eq(Date.new(2019, 3, 2))

        unfreeze_time
      end
    end

    describe 'Delimiter' do
      it 'Matches space dash dot slash' do
        expect(Quando.parse '14 April 1965').to eq(d1965_4_14)
        expect(Quando.parse '14-Apr-1965').to eq(d1965_4_14)
        expect(Quando.parse '14.4.1965').to eq(d1965_4_14)
        expect(Quando.parse '14/04/1965').to eq(d1965_4_14)
        expect(Quando.parse '14 04-1965').to eq(d1965_4_14)
        expect(Quando.parse '14.04/1965').to eq(d1965_4_14)
      end

      it 'Does not match anything else' do
        expect(Quando.parse '14\04\1965').to be_nil
        expect(Quando.parse '14!04$1965').to be_nil
        expect(Quando.parse '14%04^1965').to be_nil
        expect(Quando.parse '14@04#1965').to be_nil
      end
    end

    describe 'Formats' do
      it 'Matches @day @dlm @month_num @dlm @year' do
        expect(Quando.parse '14 04 1965').to eq(d1965_4_14)
      end

      it 'Matches @day @dlm @month_txt @dlm @year' do
        expect(Quando.parse '14 April 1965').to eq(d1965_4_14)
      end

      it 'Matches @month_txt @dlm @year' do
        expect(Quando.parse 'May 2020').to eq(Date.new(2020, 5, 1))
      end

      it 'Matches @day @dlm @month_num @dlm @year2' do
        expect(Quando.parse '2.3.20').to eq(Date.new(2020, 3, 2))
      end

      it 'Matches @month_txt' do
        expect(Quando.parse 'August').to eq(Date.new(current_year, 8, 1))
      end

      it 'Does not match undefined ones' do
        expect(Quando.parse 'April 14, 1965').to be_nil
      end
    end
  end

  describe 'Configuration' do
    let(:random_string) { SecureRandom.hex(3) }
    let(:random_matcher_name) { Quando::Config.const_get(:AUTOUPDATE).sample }

    def setter_name_for(name)
      "#{name}=".to_sym
    end

    describe 'Compound matcher @month_txt' do
      it 'Updated whenever month matcher is set' do
        month = Quando::Config::MONTHS.sample
        Quando.config.send(setter_name_for(month), random_string)
        expect(Quando.config.month_txt.to_s).to include(random_string)
      end
    end

    def formats_updated?
      Quando.config.formats.any? { |f| f.to_s.include?(random_string) }
    end

    describe 'Compound matchers in @formats' do
      it 'Updated whenever month matcher is set' do
        Quando.config.send(setter_name_for(random_matcher_name), random_string)
        expect(formats_updated?).to be(true)
      end
    end

    describe 'Via Quando.config' do
      it "Returns Quando's class-level config object" do
        expect(Quando.config).to eq(Quando.instance_variable_get(:@config))
      end
      
      it 'Lets use setter methods directly' do
        Quando.config.send(setter_name_for(random_matcher_name), random_string)
        expect(Quando.config.send(random_matcher_name)).to eq(random_string)
      end
    end

    describe 'Via Quando.configure' do
      it 'Lets set values by passing a block' do
        Quando.configure { |c| c.send(setter_name_for(random_matcher_name), random_string) }
        expect(formats_updated?).to be(true)
      end
    end

    describe 'Via Quando::Parser.new.configure' do
      it 'Does not change class-level config' do
        original_matcher = Quando.config.send(random_matcher_name)
        parser_instance = Quando::Parser.new
        parser_instance.configure { |c| c.send(setter_name_for(random_matcher_name), random_string) }
        expect(Quando.config.send(random_matcher_name)).to eq(original_matcher)
        expect(parser_instance.config.send(random_matcher_name)).to eq(random_string)
      end
    end

    describe 'Via Quando.parse' do
      before { Quando.reset! }

      let(:date) { '--2--!!--1--!!--3--' }
      let(:matcher) { /(?<month>\d+) \D+ (?<year>\d+) \D+ (?<day>\d+)/x }

      it 'Accepts a matcher via options' do
        expect(Quando.parse(date)).to be_nil
        expect(Quando.parse(date, matcher: matcher)).to eq(Date.new(2001, 2, 3))
      end

      it 'Also accepts an array of matchers' do
        expect(Quando.parse(date, matcher: [matcher])).to eq(Date.new(2001, 2, 3))
      end

      it 'Does not change class-level config' do
        original_formats = Quando.config.formats
        expect(Quando.parse(date, matcher: matcher)).to eq(Date.new(2001, 2, 3))
        expect(Quando.config.formats).to eq(original_formats)
      end
    end

    describe 'Century for 2-digit years' do
      after { Quando.reset! }

      it 'Default is 21' do
        expect(Quando.parse('14.4.65')).to eq(Date.new(2065, 4, 14))
      end

      it 'Can be adjusted via century option in config' do
        Quando.config.century = 1900
        expect(Quando.parse('14.4.65')).to eq(d1965_4_14)
      end

      it 'Can be adjusted via Quando.parse params' do
        expect(Quando.parse('14.4.65', century: 1900)).to eq(d1965_4_14)
      end
    end

    describe 'Typical use case: customized textual month names' do
      before do
        Quando.configure do |c|
          c.jan = /ЯНВ(?:АР[ЯЬ])?/i # matches ЯНВ, ЯНВАРЬ, ЯНВАРЯ
          c.feb = /ФЕВ(?:РАЛ[ЯЬ])?/i # …
          c.mar = /МАР(?:ТА?)?/i
          c.apr = /АПР(?:ЕЛ[ЯЬ])?/i
          c.may = /МА[ЯЙ]/i
          c.jun = /ИЮН(?:[ЯЬ])?/i
          c.jul = /ИЮЛ(?:[ЯЬ])?/i
          c.aug = /АВГ(?:УСТА?)?/i
          c.sep = /СЕН(?:ТЯБР[ЯЬ])?/i
          c.oct = /ОКТ(?:ЯБР[ЯЬ])?/i
          c.nov = /НОЯ(?:БР[ЯЬ])?/i
          c.dec = /ДЕК(?:АБР[ЯЬ])?/i
        end
      end

      after { Quando.reset! }

      it 'Match January' do
        expect(Quando.parse('3 января 1970')).to eq(Date.new(1970, 1, 3))
        expect(Quando.parse('Январь 1970')).to eq(Date.new(1970, 1, 1))
        expect(Quando.parse('янв.1970')).to eq(Date.new(1970, 1, 1))
        expect(Quando.parse('ЯНВ')).to eq(Date.new(current_year, 1, 1))
      end

      it 'Match February' do
        expect(Quando.parse('4 февраля 1971')).to eq(Date.new(1971, 2, 4))
        expect(Quando.parse('Февраль-1971')).to eq(Date.new(1971, 2, 1))
        expect(Quando.parse('фев.1971')).to eq(Date.new(1971, 2, 1))
        expect(Quando.parse('ФЕВ')).to eq(Date.new(current_year, 2, 1))
      end

      it 'Match March' do
        expect(Quando.parse('4 марта 1972')).to eq(Date.new(1972, 3, 4))
        expect(Quando.parse('Март/1972')).to eq(Date.new(1972, 3, 1))
        expect(Quando.parse('мар.1972')).to eq(Date.new(1972, 3, 1))
        expect(Quando.parse('МАР')).to eq(Date.new(current_year, 3, 1))
      end

      it 'Match April' do
        expect(Quando.parse('5 апреля 1973')).to eq(Date.new(1973, 4, 5))
        expect(Quando.parse('Апрель 1973')).to eq(Date.new(1973, 4, 1))
        expect(Quando.parse('апр.1973')).to eq(Date.new(1973, 4, 1))
        expect(Quando.parse('АПР')).to eq(Date.new(current_year, 4, 1))
      end

      it 'Match May' do
        expect(Quando.parse('5 мая 1973')).to eq(Date.new(1973, 5, 5))
        expect(Quando.parse('Май-1973')).to eq(Date.new(1973, 5, 1))
        expect(Quando.parse('май.1973')).to eq(Date.new(1973, 5, 1))
        expect(Quando.parse('МАЙ')).to eq(Date.new(current_year, 5, 1))
      end

      it 'Match June' do
        expect(Quando.parse('5 июня 1973')).to eq(Date.new(1973, 6, 5))
        expect(Quando.parse('Июнь/1973')).to eq(Date.new(1973, 6, 1))
        expect(Quando.parse('июн.1973')).to eq(Date.new(1973, 6, 1))
        expect(Quando.parse('ИЮН')).to eq(Date.new(current_year, 6, 1))
      end

      it 'Match July' do
        expect(Quando.parse('3 июля 1970')).to eq(Date.new(1970, 7, 3))
        expect(Quando.parse('Июль 1970')).to eq(Date.new(1970, 7, 1))
        expect(Quando.parse('июл.1970')).to eq(Date.new(1970, 7, 1))
        expect(Quando.parse('ИЮЛ')).to eq(Date.new(current_year, 7, 1))
      end

      it 'Match August' do
        expect(Quando.parse('4 августа 1971')).to eq(Date.new(1971, 8, 4))
        expect(Quando.parse('Август-1971')).to eq(Date.new(1971, 8, 1))
        expect(Quando.parse('авг.1971')).to eq(Date.new(1971, 8, 1))
        expect(Quando.parse('АВГ')).to eq(Date.new(current_year, 8, 1))
      end

      it 'Match September' do
        expect(Quando.parse('4 сентября 1972')).to eq(Date.new(1972, 9, 4))
        expect(Quando.parse('Сентябрь/1972')).to eq(Date.new(1972, 9, 1))
        expect(Quando.parse('сен.1972')).to eq(Date.new(1972, 9, 1))
        expect(Quando.parse('СЕН')).to eq(Date.new(current_year, 9, 1))
      end

      it 'Match October' do
        expect(Quando.parse('5 октября 1973')).to eq(Date.new(1973, 10, 5))
        expect(Quando.parse('Октябрь 1973')).to eq(Date.new(1973, 10, 1))
        expect(Quando.parse('окт.1973')).to eq(Date.new(1973, 10, 1))
        expect(Quando.parse('ОКТ')).to eq(Date.new(current_year, 10, 1))
      end

      it 'Match November' do
        expect(Quando.parse('5 ноября 1973')).to eq(Date.new(1973, 11, 5))
        expect(Quando.parse('Ноябрь-1973')).to eq(Date.new(1973, 11, 1))
        expect(Quando.parse('ноя.1973')).to eq(Date.new(1973, 11, 1))
        expect(Quando.parse('НОЯ')).to eq(Date.new(current_year, 11, 1))
      end

      it 'Match December' do
        expect(Quando.parse('5 декабря 1973')).to eq(Date.new(1973, 12, 5))
        expect(Quando.parse('Декабрь/1973')).to eq(Date.new(1973, 12, 1))
        expect(Quando.parse('дек.1973')).to eq(Date.new(1973, 12, 1))
        expect(Quando.parse('ДЕК')).to eq(Date.new(current_year, 12, 1))
      end
    end
  end

  describe 'Parsing routine' do
    it 'Returns nil if no format matched' do
      expect(Quando.parse('Day 14, month 4, year 1965')).to be_nil
    end

    describe 'If no named group for' do
      it 'Day, then assumes 1st of month' do
        Quando.configure { |c| c.formats = [/#{c.month_txt} #{c.year}/] }
        expect(Quando.parse('April 1965')).to eq(Date.new(1965, 4, 1))
      end

      it 'Year, then assumes current year (local time)' do
        Quando.configure { |c| c.formats = [/#{c.month_txt}, #{c.day}/] }
        expect(Quando.parse('April, 14')).to eq(Date.new(current_year, 4, 14))
      end
    end
  end
end
