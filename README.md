# Quando

[![Gem Version](https://badge.fury.io/rb/quando.svg)](https://badge.fury.io/rb/quando)
[![Build Status](https://semaphoreci.com/api/v1/kinkou/quando/branches/master/shields_badge.svg)](https://semaphoreci.com/kinkou/quando)
[![Maintainability](https://api.codeclimate.com/v1/badges/b0653fc45ec54c23e05c/maintainability)](https://codeclimate.com/github/kinkou/quando/maintainability)

Quando is a configurable date parser which picks up where ```Date.strptime``` stops. It was made to work with non-standard, multi-language dates (that is, dates recorded by humans in languages other than English) but can be used for almost any date format.

A typical use case for Quando is dealing with input like:

```text
"01 января 2019 г."
"1-ЯНВ-19"
"01.01.19"
"1/Jan/2019"
"yanvar'19"
"ЯНВ"
```

This is a real-life example of how people would routinely write January 1, 2019 in Russia, but since many countries have their own words for month names, it might be a common problem.

## How it works

```bash
gem install quando
```

and then

```ruby
require 'quando'

Quando.configure do |c|
  # Define regular expressions to identify possible month names:
  c.jan = /january|jan|yanvar|январь|января|янв/i # simplified for readability
  # c.feb = …
 
  # …more configuration…

  # Then combine them into regexps that will match the date formats you accept:
  c.formats = [
    /#{c.day} #{c.month_txt} #{c.year} г\./i, # matches "01 января 2019 г."
    /#{c.day}\.#{c.month_num}\.#{c.year2}/i, # matches "01.01.19"
    /#{c.month_txt}'#{c.year2}/i, # matches "январь'19"
    /#{c.month_txt}/i, # matches "ЯНВ"
  ]
end

Quando.parse("01 января 2019 г.") #=> #<Date: 2019-01-01>
Quando.parse("01.01.19") #=> #<Date: 2019-01-01>
Quando.parse("январь'19") #=> #<Date: 2019-01-01>
Quando.parse("ЯНВ") #=> #<Date: 2019-01-01> (given that current year is 2019)
```

## Quando in detail

### Configuration object

Configuration properties can be set by submitting a block to the ```Quando.configure``` method, as seen in the example above, or by calling the setter methods on the configuration object directly:

```ruby
Quando.config.jun = /qershor|mehefin/   # Albanian and Welsh month names
Quando.config.jul = /korrik|gorffennaf/ # will make you cry
```

### Regular expressions

If you need to use grouping, remember that non-capturing groups ```(?:abc)``` provide better performance.

If, for some reason, you need to use named groups ```(?<name>abc)```, avoid names ```day```, ```month``` and ```year```. Quando uses them internally, so conflicts are possible.

### Textual month matchers

To let Quando recognize months in your language you need to define corresponding regular expressions for all months:

```ruby
Quando.configure do |c|
  # In Finland, your matchers might look like this:
  c.jan = /jan(?:uary)?   | tammikuu(?:ta)? /xi
  c.feb = /feb(?:ruary)?  | helmikuu(?:ta)? /xi
  c.mar = /mar(?:ch)?     | maaliskuu(?:ta)?/xi
  c.apr = /apr(?:il)?     | huhtikuu(?:ta)? /xi
  c.may = /may            | toukokuu(?:ta)? /xi
  c.jun = /june?          | kesäkuu(?:ta)?  /xi
  c.jul = /july?          | heinäkuu(?:ta)? /xi
  c.aug = /aug(?:ust)?    | elokuu(?:ta)?   /xi
  c.sep = /sep(?:tember)? | syyskuu(?:ta)?  /xi
  c.oct = /oct(?:ober)?   | lokakuu(?:ta)?  /xi
  c.nov = /nov(?:ember)?  | marraskuu(?:ta)?/xi
  c.dec = /dec(?:ember)?  | joulukuu(?:ta)? /xi
  
  # …more configuration…
end
```

### Numerical matchers

Quando comes with defaults that will probably work in most situations:

```Quando.config.day``` matches numbers from 1 to 31, both zero-padded and unpadded;

```Quando.config.month_num``` matches numbers from 1 to 12, both zero-padded and unpadded;

```Quando.config.year``` matches any 4-digit sequence;
```Quando.config.year2``` matches any 2-digit sequence.

If you need to adjust these matchers make sure that they produce named captures ```day```, ```month``` and ```year```, respectively:

```ruby
Quando.config.day = /(?<day> …)/
Quando.config.month_num = /(?<month> …)/
Quando.config.year = /(?<year> …)/
```

### Delimiter matcher

By default, ```Quando.config.dlm``` will greedily match spaces, dashes, dots and slashes.

### Format matchers

With format matchers you describe the concrete date formats that Quando will recognize. Within them you can include the date part matchers you defined previously.

```Quando.config.day```, ```Quando.config.month_num```, ```Quando.config.month_txt```, ```Quando.config.year```, ```Quando.config.year2``` can be used.

```Quando.config.month_txt``` is a regexp that automatically combines all textual month matchers, and will thus match any month.

```ruby
Quando.configure do |c|
  # …some initial configuration…
 
  c.formats = [
    /^ #{c.day} #{c.dlm} #{c.month_txt} #{c.dlm} #{c.year} $/xi,
    # compiles into something like
    # /^ (?<day> …) [ -.\/]+ (?<month> jan|feb|…) [ -.\/]+ (?<year> …) $/xi
    # and returns ~ #<MatchData "14 Apr 1965" day:"14" month:"Apr" year:"1965">
    # on successful match 
  ]
end
```

### How dates are parsed

Quando matches regular expressions from ```Quando.config.formats```, *in the specified order*, against the input. If there is a match, the resulting ```MatchData``` object is analyzed.

If there is a named capture ```:day``` or ```:month```, either is used in the result, given that they are within correct range. If the format matcher did not define such named group, ```1``` is used:

```ruby
Quando.config.formats = [
  /#{Quando.config.month_num}\.#{Quando.config.year}/
]

Quando.parse('04.2019') #=> #<Date: 2019-04-01>
```

If there is a named capture ```:year```, it is used in the result. If the format matcher did not define such named group, current UTC year is used. If the captured value is less than ```100``` (which is the case for years written as 2-digit numbers), Quando will use the ```Quando.config.century``` setting (defaults to ```21```), effectively converting, for example, ```18``` to ```2018```. Be mindful of this behaviour, adjusting ```Quando.config.century``` accordingly:

```ruby
Quando.config.formats = [Quando.config.year]
Quando.parse('2019') #=> #<Date: 2019-01-01>

Quando.config.formats = [Quando.config.year2]
Quando.parse('65') #=> #<Date: 2065-01-01>

Quando.parse('65', century: 20) #=> #<Date: 1965-01-01>
# or
Quando.config.century = 20
Quando.parse('65') #=> #<Date: 1965-01-01>
```

### Defaults

Out of the box, Quando will parse a reasonable variety of day-month-year ordered numerical and English textual dates. Some examples:

```text
14.4.1965, 14/04/1965, …
14-apr-1965, 14 Apr 1965, …
April 1965, apr 1965, …
13.12.05, 13-12-05, …
April, APR, …
```

See ```Quando.config.formats``` for details.

### Multiple ways to configure

You can configure Quando instances independently of each other and of the class:

```ruby
Quando.parse('14-abril-1965') #=> nil

date_parser = Quando::Parser.new.configure do |c|
  # …some configuration…
end
date_parser.parse('14-abril-1965') #=> #<Date: 1965-04-14>

Quando.parse('14-abril-1965') #=> nil
```

or just pass a format matcher as a parameter:

```ruby
m = /(?<year>#{Quando.config.year}) (?<day>\d\d) (?<month>[A-Z]+)/i
Quando.parse('1965 14 Apr', matcher: m) #=> #<Date: 1965-04-14>
```

In both cases it will not change the global configuration (but note that calling setter methods on ```Quando.config``` will).

### Requirements

Ruby >= 1.9.3. Enjoy!
