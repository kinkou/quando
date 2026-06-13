# frozen_string_literal: true

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
        expect(described_class.parse('1.10.2020')).to eq(Date.new(2020, 10, 1))
      end

      it 'Parses 1-digit 0-padded' do
        expect(described_class.parse('01.10.2020')).to eq(Date.new(2020, 10, 1))
      end

      it 'Parses 2-digit' do
        expect(described_class.parse('31.10.2020')).to eq(Date.new(2020, 10, 31))
      end

      it 'Does not match out-of-range values' do
        expect(described_class.parse('0.10.2020')).to be_nil
        expect(described_class.parse('32.10.2020')).to be_nil
      end

      it 'Requires anchors to work properly' do
        expect('32'[described_class.config.day]).to eq('3')

        unanchored = /#{described_class.config.day} \. #{described_class.config.month_num} \. #{described_class.config.year}/xi
        expect(described_class.parse('32.10.2020', matcher: unanchored)).to eq(Date.new(2020, 10, 2))
      end
    end

    describe 'Numerical month' do
      it 'Parses 1-digit unpadded' do
        expect(described_class.parse('14.4.1965')).to eq(d1965_4_14)
      end

      it 'Parses 1-digit 0-padded' do
        expect(described_class.parse('14.04.1965')).to eq(d1965_4_14)
      end

      it 'Parses 2-digit' do
        expect(described_class.parse('11.12.2020')).to eq(Date.new(2020, 12, 11))
      end

      it 'Does not match out-of-range values' do
        expect(described_class.parse('1.0.2020')).to be_nil
        expect(described_class.parse('1.13.2020')).to be_nil
      end

      it 'Requires anchors to work properly' do
        expect('13'[described_class.config.month_num]).to eq('1')
      end
    end

    describe 'Textual month' do
      it 'Parses short English month names' do
        expect(described_class.parse('2 jan 2020')).to eq(Date.new(2020, 1, 2))
        expect(described_class.parse('3 Feb 2020')).to eq(Date.new(2020, 2, 3))
        expect(described_class.parse('4 MAR 2020')).to eq(Date.new(2020, 3, 4))
        expect(described_class.parse('5 apr 2020')).to eq(Date.new(2020, 4, 5))
        expect(described_class.parse('6 May 2020')).to eq(Date.new(2020, 5, 6))
        expect(described_class.parse('7 JUN 2020')).to eq(Date.new(2020, 6, 7))
        expect(described_class.parse('8 jul 2020')).to eq(Date.new(2020, 7, 8))
        expect(described_class.parse('9 Aug 2020')).to eq(Date.new(2020, 8, 9))
        expect(described_class.parse('10 SEP 2020')).to eq(Date.new(2020, 9, 10))
        expect(described_class.parse('11 oct 2020')).to eq(Date.new(2020, 10, 11))
        expect(described_class.parse('12 Nov 2020')).to eq(Date.new(2020, 11, 12))
        expect(described_class.parse('13 DEC 2020')).to eq(Date.new(2020, 12, 13))
      end

      it 'Parses long English month names' do
        expect(described_class.parse('2 january 2020')).to eq(Date.new(2020, 1, 2))
        expect(described_class.parse('3 February 2020')).to eq(Date.new(2020, 2, 3))
        expect(described_class.parse('4 MARCH 2020')).to eq(Date.new(2020, 3, 4))
        expect(described_class.parse('5 april 2020')).to eq(Date.new(2020, 4, 5))
        expect(described_class.parse('6 May 2020')).to eq(Date.new(2020, 5, 6))
        expect(described_class.parse('7 JUNE 2020')).to eq(Date.new(2020, 6, 7))
        expect(described_class.parse('8 july 2020')).to eq(Date.new(2020, 7, 8))
        expect(described_class.parse('9 August 2020')).to eq(Date.new(2020, 8, 9))
        expect(described_class.parse('10 SEPTEMBER 2020')).to eq(Date.new(2020, 9, 10))
        expect(described_class.parse('11 october 2020')).to eq(Date.new(2020, 10, 11))
        expect(described_class.parse('12 November 2020')).to eq(Date.new(2020, 11, 12))
        expect(described_class.parse('13 DECEMBER 2020')).to eq(Date.new(2020, 12, 13))
      end
    end

    describe 'Year' do
      it 'Parses 4-digit year' do
        expect(described_class.parse('13.12.2020')).to eq(Date.new(2020, 12, 13))
      end

      it 'Parses 2-digit year' do
        expect(described_class.parse('13.12.20')).to eq(Date.new(2020, 12, 13))
      end

      it 'Does not parse > 4 digits' do
        expect(described_class.parse('13.12.12345')).to be_nil
      end

      it 'Does not parse < 2 digits' do
        expect(described_class.parse('13.12.1')).to be_nil
      end

      it 'Requires anchors to work properly' do
        expect('12345'[described_class.config.year]).to eq('1234')

        unanchored = /#{described_class.config.day} \. #{described_class.config.month_num} \. #{described_class.config.year}/xi
        expect(described_class.parse('13.12.12345', matcher: unanchored)).to eq(Date.new(1234, 12, 13))
      end

      it 'Uses current UTC year for yearless dates' do
        offset = 3 * 60 * 60 # +3 hours
        moment_x = Time.new(2020, 1, 1, 0, 0, 0, offset) # Jan 1 2020 00:00:00 +0300 == Dec 31 2019 21:00:00 +0000
        freeze_time(moment_x)

        expect(Time.now.year).to eq(2020)
        expect(Time.now.utc.year).to eq(2019)
        matcher = /#{described_class.config.day}\.#{described_class.config.month_num}/
        expect(described_class.parse('2.3', matcher: matcher)).to eq(Date.new(2019, 3, 2))

        unfreeze_time
      end

      it 'Parses negative years' do
        matcher  = /#{described_class.config.day} #{described_class.config.month_num} (?<year>-?\d+)/

        expect(described_class.parse('2 3 16', matcher: matcher, century: 1)).to eq(Date.new(16, 3, 2))
        expect(described_class.parse('2 3 -16', matcher: matcher, century: -1)).to eq(Date.new(-16, 3, 2))

        expect(described_class.parse('2 3 16', matcher: matcher, century: 2)).to eq(Date.new(116, 3, 2))
        expect(described_class.parse('2 3 -16', matcher: matcher, century: -2)).to eq(Date.new(-116, 3, 2))

        expect(described_class.parse('2 3 16', matcher: matcher, century: 16)).to eq(Date.new(1516, 3, 2))
        expect(described_class.parse('2 3 -16', matcher: matcher, century: -16)).to eq(Date.new(-1516, 3, 2))

        expect(described_class.parse('2 3 616', matcher: matcher)).to eq(Date.new(616, 3, 2))
        expect(described_class.parse('2 3 -616', matcher: matcher)).to eq(Date.new(-616, 3, 2))

        expect(described_class.parse('2 3 -1616', matcher: matcher)).to eq(Date.new(-1616, 3, 2))
      end
    end

    describe 'Delimiter' do
      it 'Matches space dash dot slash' do
        expect(described_class.parse('14 April 1965')).to eq(d1965_4_14)
        expect(described_class.parse('14-Apr-1965')).to eq(d1965_4_14)
        expect(described_class.parse('14.4.1965')).to eq(d1965_4_14)
        expect(described_class.parse('14/04/1965')).to eq(d1965_4_14)
        expect(described_class.parse('14 04-1965')).to eq(d1965_4_14)
        expect(described_class.parse('14.04/1965')).to eq(d1965_4_14)
      end

      it 'Does not match anything else' do
        expect(described_class.parse('14\04\1965')).to be_nil
        expect(described_class.parse('14!04$1965')).to be_nil
        expect(described_class.parse('14%04^1965')).to be_nil
        expect(described_class.parse('14@04#1965')).to be_nil
      end
    end

    describe 'Formats' do
      it 'Matches @day @dlm @month_num @dlm @year' do
        expect(described_class.parse('14 04 1965')).to eq(d1965_4_14)
      end

      it 'Matches @day @dlm @month_txt @dlm @year' do
        expect(described_class.parse('14 April 1965')).to eq(d1965_4_14)
      end

      it 'Matches @month_txt @dlm @year' do
        expect(described_class.parse('May 2020')).to eq(Date.new(2020, 5, 1))
      end

      it 'Matches @day @dlm @month_num @dlm @year2' do
        expect(described_class.parse('2.3.20')).to eq(Date.new(2020, 3, 2))
      end

      it 'Matches @month_txt' do
        expect(described_class.parse('August')).to eq(Date.new(current_year, 8, 1))
      end

      it 'Does not match undefined ones' do
        expect(described_class.parse('April 14, 1965')).to be_nil
      end
    end
  end

  describe 'Configuration' do
    def build_random_string
      SecureRandom.hex(3)
    end

    def build_random_matcher_name
      Quando::Config.const_get(:AUTOUPDATE).sample
    end

    let(:random_string) { build_random_string }
    let(:random_matcher_name) { build_random_matcher_name }

    def setter_name_for(name)
      :"#{name}="
    end

    describe 'Compound matcher @month_txt' do
      it 'Updated whenever month matcher is set' do
        month = Quando::Config::MONTHS.sample
        described_class.config.send(setter_name_for(month), random_string)
        expect(described_class.config.month_txt.to_s).to include(random_string)
      end
    end

    def formats_updated?
      Quando.config.formats.any? { |f| f.to_s.include?(random_string) }
    end

    describe 'Compound matchers in @formats' do
      it 'Updated whenever month matcher is set' do
        described_class.config.send(setter_name_for(random_matcher_name), random_string)
        expect(formats_updated?).to be(true)
      end
    end

    describe 'Via Quando.config' do
      it "Returns Quando's class-level config object" do
        expect(described_class.config).to eq(described_class.instance_variable_get(:@config))
      end

      it 'Lets use setter methods directly' do
        described_class.config.send(setter_name_for(random_matcher_name), random_string)
        expect(described_class.config.send(random_matcher_name)).to eq(random_string)
      end
    end

    describe 'Via Quando.configure' do
      it 'Lets set values by passing a block' do
        described_class.configure { |c| c.send(setter_name_for(random_matcher_name), random_string) }
        expect(formats_updated?).to be(true)
      end
    end

    describe 'Via Quando::Parser.new.configure' do
      def build_parser_instance
        Quando::Parser.new
      end

      it 'Does not change class-level config' do
        original_matcher = described_class.config.send(random_matcher_name)
        instance = build_parser_instance
        instance.configure { |c| c.send(setter_name_for(random_matcher_name), random_string) }
        expect(described_class.config.send(random_matcher_name)).to eq(original_matcher)
        expect(instance.config.send(random_matcher_name)).to eq(random_string)
      end

      it 'Allows use #configure many times preserving all settings' do
        random_string2 = build_random_string
        until (random_matcher_name2 = build_random_matcher_name) != random_matcher_name do end

        instance = build_parser_instance
        instance.configure { |c| c.send(setter_name_for(random_matcher_name), random_string) }
        instance.configure { |c| c.send(setter_name_for(random_matcher_name2), random_string2) }

        expect(instance.config.send(random_matcher_name)).to eq(random_string)
        expect(instance.config.send(random_matcher_name2)).to eq(random_string2)
      end
    end

    describe 'Via Quando.parse' do
      before { described_class.reset! }

      let(:date) { '--2--!!--1--!!--3--' }
      let(:matcher) { /(?<month>\d+) \D+ (?<year>\d+) \D+ (?<day>\d+)/x }

      it 'Accepts a matcher via options' do
        expect(described_class.parse(date)).to be_nil
        expect(described_class.parse(date, matcher: matcher)).to eq(Date.new(2001, 2, 3))
      end

      it 'Also accepts an array of matchers' do
        expect(described_class.parse(date, matcher: [matcher])).to eq(Date.new(2001, 2, 3))
      end

      it 'Does not change class-level config' do
        original_formats = described_class.config.formats
        expect(described_class.parse(date, matcher: matcher)).to eq(Date.new(2001, 2, 3))
        expect(described_class.config.formats).to eq(original_formats)
      end
    end

    describe 'Century for 2-digit years' do
      after { described_class.reset! }

      it 'Default is 21' do
        expect(described_class.parse('14.4.65')).to eq(Date.new(2065, 4, 14))
        expect(described_class.parse('14.4.65', century: nil)).to eq(Date.new(2065, 4, 14))
      end

      it 'Can be adjusted via century option in config' do
        described_class.config.century = 20
        expect(described_class.parse('14.4.65')).to eq(d1965_4_14)
      end

      it 'Can be adjusted via Quando.parse params' do
        expect(described_class.parse('14.4.65', century: 20)).to eq(d1965_4_14)
      end

      it 'Assumes century 0 is century 1' do
        expect(described_class.parse('2 3 16', century: 0)).to eq(Date.new(16, 3, 2))
      end

      it 'Reset to default for nil and 0' do
        described_class.config.century = 0
        expect(described_class.config.century).to eq(1)

        described_class.config.century = nil
        expect(described_class.config.century).to eq(21)
      end
    end

    describe 'Typical use case: customized textual month names' do
      before do
        described_class.configure do |c|
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

      after { described_class.reset! }

      it 'Match January' do
        expect(described_class.parse('3 января 1970')).to eq(Date.new(1970, 1, 3))
        expect(described_class.parse('Январь 1970')).to eq(Date.new(1970, 1, 1))
        expect(described_class.parse('янв.1970')).to eq(Date.new(1970, 1, 1))
        expect(described_class.parse('ЯНВ')).to eq(Date.new(current_year, 1, 1))
      end

      it 'Match February' do
        expect(described_class.parse('4 февраля 1971')).to eq(Date.new(1971, 2, 4))
        expect(described_class.parse('Февраль-1971')).to eq(Date.new(1971, 2, 1))
        expect(described_class.parse('фев.1971')).to eq(Date.new(1971, 2, 1))
        expect(described_class.parse('ФЕВ')).to eq(Date.new(current_year, 2, 1))
      end

      it 'Match March' do
        expect(described_class.parse('4 марта 1972')).to eq(Date.new(1972, 3, 4))
        expect(described_class.parse('Март/1972')).to eq(Date.new(1972, 3, 1))
        expect(described_class.parse('мар.1972')).to eq(Date.new(1972, 3, 1))
        expect(described_class.parse('МАР')).to eq(Date.new(current_year, 3, 1))
      end

      it 'Match April' do
        expect(described_class.parse('5 апреля 1973')).to eq(Date.new(1973, 4, 5))
        expect(described_class.parse('Апрель 1973')).to eq(Date.new(1973, 4, 1))
        expect(described_class.parse('апр.1973')).to eq(Date.new(1973, 4, 1))
        expect(described_class.parse('АПР')).to eq(Date.new(current_year, 4, 1))
      end

      it 'Match May' do
        expect(described_class.parse('5 мая 1973')).to eq(Date.new(1973, 5, 5))
        expect(described_class.parse('Май-1973')).to eq(Date.new(1973, 5, 1))
        expect(described_class.parse('май.1973')).to eq(Date.new(1973, 5, 1))
        expect(described_class.parse('МАЙ')).to eq(Date.new(current_year, 5, 1))
      end

      it 'Match June' do
        expect(described_class.parse('5 июня 1973')).to eq(Date.new(1973, 6, 5))
        expect(described_class.parse('Июнь/1973')).to eq(Date.new(1973, 6, 1))
        expect(described_class.parse('июн.1973')).to eq(Date.new(1973, 6, 1))
        expect(described_class.parse('ИЮН')).to eq(Date.new(current_year, 6, 1))
      end

      it 'Match July' do
        expect(described_class.parse('3 июля 1970')).to eq(Date.new(1970, 7, 3))
        expect(described_class.parse('Июль 1970')).to eq(Date.new(1970, 7, 1))
        expect(described_class.parse('июл.1970')).to eq(Date.new(1970, 7, 1))
        expect(described_class.parse('ИЮЛ')).to eq(Date.new(current_year, 7, 1))
      end

      it 'Match August' do
        expect(described_class.parse('4 августа 1971')).to eq(Date.new(1971, 8, 4))
        expect(described_class.parse('Август-1971')).to eq(Date.new(1971, 8, 1))
        expect(described_class.parse('авг.1971')).to eq(Date.new(1971, 8, 1))
        expect(described_class.parse('АВГ')).to eq(Date.new(current_year, 8, 1))
      end

      it 'Match September' do
        expect(described_class.parse('4 сентября 1972')).to eq(Date.new(1972, 9, 4))
        expect(described_class.parse('Сентябрь/1972')).to eq(Date.new(1972, 9, 1))
        expect(described_class.parse('сен.1972')).to eq(Date.new(1972, 9, 1))
        expect(described_class.parse('СЕН')).to eq(Date.new(current_year, 9, 1))
      end

      it 'Match October' do
        expect(described_class.parse('5 октября 1973')).to eq(Date.new(1973, 10, 5))
        expect(described_class.parse('Октябрь 1973')).to eq(Date.new(1973, 10, 1))
        expect(described_class.parse('окт.1973')).to eq(Date.new(1973, 10, 1))
        expect(described_class.parse('ОКТ')).to eq(Date.new(current_year, 10, 1))
      end

      it 'Match November' do
        expect(described_class.parse('5 ноября 1973')).to eq(Date.new(1973, 11, 5))
        expect(described_class.parse('Ноябрь-1973')).to eq(Date.new(1973, 11, 1))
        expect(described_class.parse('ноя.1973')).to eq(Date.new(1973, 11, 1))
        expect(described_class.parse('НОЯ')).to eq(Date.new(current_year, 11, 1))
      end

      it 'Match December' do
        expect(described_class.parse('5 декабря 1973')).to eq(Date.new(1973, 12, 5))
        expect(described_class.parse('Декабрь/1973')).to eq(Date.new(1973, 12, 1))
        expect(described_class.parse('дек.1973')).to eq(Date.new(1973, 12, 1))
        expect(described_class.parse('ДЕК')).to eq(Date.new(current_year, 12, 1))
      end
    end
  end

  describe 'Parsing routine' do
    it 'Returns nil if no format matched' do
      expect(described_class.parse('Day 14, month 4, year 1965')).to be_nil
    end

    describe 'If no named group for' do
      it 'Day, then assumes 1st of month' do
        described_class.configure { |c| c.formats = [/#{c.month_txt} #{c.year}/] }
        expect(described_class.parse('April 1965')).to eq(Date.new(1965, 4, 1))
      end

      it 'Year, then assumes current year (local time)' do
        described_class.configure { |c| c.formats = [/#{c.month_txt}, #{c.day}/] }
        expect(described_class.parse('April, 14')).to eq(Date.new(current_year, 4, 14))
      end
    end
  end
end
