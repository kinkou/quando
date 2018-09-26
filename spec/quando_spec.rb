require 'spec_helper'
require 'pry'

RSpec.describe Quando do

  let(:matz_bday) { Date.new(1965, 4, 14) }
  let(:matz_bday_txt_rus) { '14 АПРЕЛЬ 1965' }
  let(:rails_release) { Date.new(2005, 12, 13) }
  let(:singe_digit_date) { Date.new(2004, 3, 2) }

  specify 'Default date formats' do
    expect(Quando.parse '14.04.1965').to eq(matz_bday)
    expect(Quando.parse '13.12.05').to eq(rails_release)
    expect(Quando.parse '2-3-04').to eq(singe_digit_date)
    expect(Quando.parse '14 April 1965').to eq(matz_bday)
    expect(Quando.parse '14 Apr. 1965').to eq(matz_bday)
    expect(Quando.parse '14 Apr 1965').to eq(matz_bday)
    expect(Quando.parse 'Dec 05').to eq(Date.new(2005, 12, 1))
    expect(Quando.parse 'Dec').to eq(Date.new(Time.now.year, 12, 1))
  end

  specify 'Default delimiters' do
    expect(Quando.parse '14 04-1965').to eq(matz_bday)
    expect(Quando.parse '14.04/1965').to eq(matz_bday)
    expect(Quando.parse '14\04 1965').to eq(matz_bday)
  end

  specify 'Default text month names' do
    expect(Quando.parse '14 April 1965').to eq(matz_bday)
    expect(Quando.parse '14 april 1965').to eq(matz_bday)
    expect(Quando.parse '14 APRIL 1965').to eq(matz_bday)
    expect(Quando.parse '14 Apr 1965').to eq(matz_bday)
    expect(Quando.parse '14 Apr. 1965').to eq(matz_bday)
  end

  specify 'Invalid dates' do
    expect(Quando.parse nil).to be_nil
    expect(Quando.parse '2 3 4').to be_nil
    expect(Quando.parse '32 3 04').to be_nil
    expect(Quando.parse '2 13 04').to be_nil
    expect(Quando.parse '14 -=*=- 1965').to be_nil
    expect(Quando.parse 'Båtar!').to be_nil
  end

  let(:april_rus_rx) { /(?:АПРЕЛЬ)/i }

  specify 'Simple app-level configuration' do
    expect(Quando.parse matz_bday_txt_rus).to be_nil

    Quando.configure do |c|
      c.apr = april_rus_rx
      c.uniupdate!
    end

    expect(Quando.parse matz_bday_txt_rus).to eq(matz_bday)
    Quando.reset!
  end

  specify 'Simple instance-level configuration' do
    expect(Quando.parse matz_bday_txt_rus).to be_nil

    parser = Quando::Parser.new.configure do |c|
      c.apr = april_rus_rx
      c.uniupdate!
    end

    expect(parser.parse matz_bday_txt_rus).to eq(matz_bday)
    expect(Quando.parse matz_bday_txt_rus).to be_nil
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
  end

end
