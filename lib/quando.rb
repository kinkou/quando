# frozen_string_literal: true

require 'date'
require 'quando/version'
require 'quando/config'
require 'quando/parser'

module Quando

  # @param date [String]
  # @param opts [Hash]
  # @option opts [Regexp, Array<Regexp>] :matcher (nil)
  # @option opts [Integer] :century (nil)
  # @return [Date, nil]
  def self.parse(date, opts = {})
    return if (date = date.to_s.strip).empty?

    p = Parser.new

    p.config.formats = [opts[:matcher]].flatten if opts[:matcher]
    p.config.century = opts[:century] if opts[:century]

    p.parse(date)
  end

end
