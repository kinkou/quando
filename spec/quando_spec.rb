# encoding: utf-8
# frozen_string_literal: true

require 'securerandom'

RSpec.describe Quando do
  let(:matz_bday) { Date.new(1965, 4, 14) }
  let(:matz_bday_txt_rus) { '14 АПРЕЛЯ 1965 г.' }
  let(:april_rus_rx) { /АПРЕЛ[ЬЯ]/i }
  let(:year_rus_rx) { /(?<year> \d{4}) \s* (?:Г\.?)?/xi }
  let(:rails_release) { Date.new(2005, 12, 13) }
  let(:singe_digit_date) { Date.new(2004, 3, 2) }
  let(:nonsense) { 'Båtar!' }

  describe 'Default day matcher regexp' do
    let(:matcher) { Quando.config.day }
    let(:matcher_w_boundaries) { /^#{matcher}$/ }
    let(:valid_numbers) { (1..31).map(&:to_s) }
    let(:valid_numbers_padded) { valid_numbers.map { |n| sprintf('%02i', n) } }

    it 'Matches day numbers' do
      valid_numbers.each do |unpadded|
        expect(unpadded[matcher]).to eq(unpadded)
      end
    end

    it 'Also matches 0-padded day numbers' do
      valid_numbers_padded.each do |padded|
        expect(padded[matcher]).to eq(padded)
      end
    end

    it 'Requires boundary matchers to indentify a day properly' do
      expect('32'[matcher]).to eq('3')
      expect('32'[matcher_w_boundaries]).to be_nil
    end

    it 'Does not match anything else' do
      %w(0 00 32 42).each { |n| expect(n[matcher_w_boundaries]).to be_nil }
    end
  end

  describe 'Default month number matcher regexp' do
    let(:matcher) { Quando.config.month_num }
    let(:matcher_w_boundaries) { /^#{matcher}$/ }
    let(:valid_numbers) { (1..12).map(&:to_s) }
    let(:valid_numbers_padded) { valid_numbers.map { |n| sprintf('%02i', n) } }

    it 'Matches month numbers' do
      valid_numbers.each do |unpadded|
        expect(unpadded[matcher]).to eq(unpadded)
      end
    end

    it 'Also matches 0-padded month numbers' do
      valid_numbers_padded.each do |padded|
        expect(padded[matcher]).to eq(padded)
      end
    end

    it 'Requires boundary matchers to indentify a month properly' do
      expect('32'[matcher]).to eq('3')
      expect('32'[matcher_w_boundaries]).to be_nil
    end

    it 'Does not match anything else' do
      %w(0 00 13 21).each { |n| expect(n[matcher_w_boundaries]).to be_nil }
    end
  end

  describe 'Default month name matcher regexps' do
    let(:matcher) {  }
  end

  describe 'Configuration' do
    context 'Class-level' do
      after { Quando.reset! }

      let(:default_jan_matcher) { Quando.config.jan.source }
      let(:new_matcher) { SecureRandom.hex(3) }

      it 'Allows set options' do
        expect(default_jan_matcher).not_to eq(new_matcher)

        Quando.configure do |c|
          c.jan = new_matcher
        end

        expect(Quando.config.jan).to eq(new_matcher)
      end

      def month_txt_updated?
        Quando.config.month_txt.source.include?(new_matcher)
      end

      def formats_updated?
        formats_src = Quando.config.formats.map { |f| f.source }
        formats_src.any? { |r| r.include?(new_matcher) }
      end

      it 'Autoupdates compound matchers when part matchers are set' do
        expect(month_txt_updated?).to eq(false)
        expect(formats_updated?).to eq(false)

        # c.<feb|sep|etc> = new_matcher
        random_month = "#{Quando::Config::MONTHS.sample}=".to_sym
        Quando.configure do |c|
          c.send(random_month, new_matcher)
        end

        expect(month_txt_updated?).to eq(true)
        expect(formats_updated?).to eq(true)
      end

      it 'Actually works' do
        expect(Quando.parse matz_bday_txt_rus).to be_nil

        Quando.configure do |c|
          c.year = year_rus_rx
          c.apr = april_rus_rx
        end

        expect(Quando.parse matz_bday_txt_rus).to eq(matz_bday)
      end
    end

    context 'Instance-level' do
      it 'Works like class-level but can be configured independently' do
        expect(Quando.parse matz_bday_txt_rus).to be_nil

        parser = Quando::Parser.new.configure do |c|
          c.year = year_rus_rx
          c.apr = april_rus_rx
        end

        expect(parser.parse matz_bday_txt_rus).to eq(matz_bday)
        expect(Quando.parse matz_bday_txt_rus).to be_nil
      end
    end
  end

  describe 'Default configuration' do
    context 'When input is unrecognizable' do
      let(:gibberish) do
        [
          nil,
          '2 3 4',
          '32 3 04',
          '2 13 04',
          '14 -=*=- 1965',
          nonsense,
        ]
      end

      it 'Returns nil' do
        gibberish.each { |g| expect(Quando.parse(g)).to be_nil }
      end
    end

    context 'But when it is recognizable' do
      let(:matz_bday_variety) do
        [
          '14.04.1965',
          '14.4.1965',
          '14-4-1965',
          '14 04-1965',
          '14 4 1965',
          '14/4/1965',
          '14 04-1965',
          '14.04/1965',
          '14 April 1965',
          '14 april 1965',
          '14 APRIL 1965',
          '14 Apr 1965',
          '14 Apr. 1965',
        ]
      end

      it 'Can parse Matz birthday date in many forms (see inside)' do
        matz_bday_variety.each { |mbd| expect(Quando.parse(mbd)).to eq(matz_bday) }
      end
    end
  end

  specify 'Default date formats' do
    expect(Quando.parse '13.12.05').to eq(rails_release)
    expect(Quando.parse '2-3-04').to eq(singe_digit_date)
    expect(Quando.parse 'Dec').to eq(Date.new(Time.now.getlocal.year, 12, 1))
  end

  specify 'Simple one-time configuration' do
    custom_date = 'All your base belong to *4*_1965=%14'
    expect(Quando.parse custom_date).to be_nil

    matcher = /
      \*#{Quando.config.month_num}\*
      _#{Quando.config.year}
      =%#{Quando.config.day}
    /xi

    result = Quando.parse(custom_date, matcher: matcher)
    expect(result).to eq(matz_bday)

    result = Quando.parse('1965 14 Apr', matcher: /(?<year>\d{4}) (?<day>\d\d) (?<month>[A-Z]+)/i)
    expect(result).to eq(matz_bday)

    result = Quando.parse('14 Apr 1965', matcher: [/^(?<day>\d+) (?<month>\d+) (?<year>\d+)$/i, /^(?<day>\d+) (?<month>\D+) (?<year>\d+)$/i])
    expect(result).to eq(matz_bday)

    [nonsense, 'Arpil'].each do |m|
      result = Quando.parse(m, matcher: /(?<month>.+)/i)
      expect(result).to be_nil
    end
  end

end
