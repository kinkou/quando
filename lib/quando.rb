# frozen_string_literal: true

require 'date'
require 'quando/version'
require 'quando/config'
require 'quando/parser'

module Quando

  # @param date [String]
  # @param opts [Hash]
  # @option opts [Regexp, Array<Regexp>] :matcher
  # @option opts [Integer] :century
  # @return [Date, nil]
  def self.parse(date, opts = {})
    return if (date = date.to_s.strip).empty?

    p = Parser.new

    if opts[:matcher]
      p.configure do |c|
        c.formats = [opts[:matcher]].flatten
      end
    end

    if opts[:century]
      p.configure do |c|
        c.century = opts[:century]
      end
    end

    p.parse(date)
  end

end
