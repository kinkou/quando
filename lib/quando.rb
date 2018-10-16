# frozen_string_literal: true

require 'date'
require 'quando/version'
require 'quando/config'
require 'quando/parser'

module Quando

  # @param opts [Hash]
  # @option opts [Regexp, Array<Regexp>] :matcher (nil)
  # @param date [String]
  # @return [Date, nil]
  def self.parse(date, opts = {})
    return if (date = date.to_s.strip).empty?

    p = Parser.new

    if opts[:matcher]
      p.configure do |c|
        c.formats = [opts[:matcher]].flatten
      end
    end

    p.parse(date)
  end

end
