# Quando

[![Gem Version](https://badge.fury.io/rb/quando.svg)](https://badge.fury.io/rb/quando)
[![Build Status](https://semaphoreci.com/api/v1/kinkou/quando/branches/master/shields_badge.svg)](https://semaphoreci.com/kinkou/quando)
[![Maintainability](https://api.codeclimate.com/v1/badges/b0653fc45ec54c23e05c/maintainability)](https://codeclimate.com/github/kinkou/quando/maintainability)

Quando is a configurable date parser. Show it what's what and parse any (Gregorian calendar) date. Quando can be configured on:

#### Application-level:
```ruby
Quando.configure do |c|
  c.dlm = /[ ,-]/

  c.jan = /janeiro/i
  c.feb = /fevereiro/i
  c.mar = /março/i
  c.apr = /abril/i
  # …
  c.unimonth!

  c.formats = [
    /#{c.month_num} #{c.dlm} #{c.month_txt} #{c.dlm} #{c.year}/xi,
    /#{c.year} #{c.dlm} #{c.month_txt} #{c.dlm} #{c.month_num}/xi,
  ]
end

Quando.parse('14-abril-1965') #=> #<Date: 1965-04-14>
Quando.parse('1965, abril 14') #=> #<Date: 1965-04-14>
```

#### Instance-level:
It will not affect your application-level configuration.
```ruby
Quando.parse('14-abril-1965') #=> nil

date_parser = Quando::Parser.new.configure do |c|
  # here be the options from the previous example
end
date_parser.parse('14-abril-1965') #=> #<Date: 1965-04-14>

Quando.parse('14-abril-1965') #=> nil
```

#### Or just one-time usage:
```ruby
m = /(?<year>#{Quando.config.year}) (?<day>\d\d) (?<month>[A-Z]+)/i
Quando.parse('1965 14 Apr', matcher: m) #=> #<Date: 1965-04-14>
```

Enjoy.
