# Cor

Cor (which means color in Portuguese) is a library for more easily
working with colors in Crystal. You can think of it as a more
powerful version of `Colorize`. Cor allows you to very
easily convert RGB(A) values to hex and back again for
use in CSS and HTML. It also provides a set of
chainable methods for creting colorful strings
for the terminal using truecolor.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cor:
       github: your-github-user/cor
   ```

2. Run `shards install`

## Usage

### Creating a color

```crystal
require "cor"

red = Cor.new(255, 0, 0)
# or you can do
red = Cor.new("FF0000")
# or you can also do
red = Cor.color(:red)
```

You can also include an alpha value

```crystal
mid_red = Cor.new(255, 0, 0, 0.5)
```

### Getting a hex string

```crystal
blue = Cor.color(:blue)
puts blue.hex_string
# => 0000ff
```

`#hex_string` also provides a couple of formatting options

```crystal
puts blue.hex_string(prefix: true)
# => #0000ff

puts blue.hex_string(alpha: true)
# => 0000ffff

puts blue.hex_string(upcase: true)
# => 0000FF
```

### Retting a RGB string

```crystal
magenta = Cor.color(:magenta)

puts magenta.rgb_string
# => rgb(255, 0, 255)

puts magenta.rgb_string(alpha: true)
# => rgb(255, 0, 255, 1)
```

### Math with colors

The `Cor` class includes the basic math methods as well
which means if, for whatever reason, you want to add,
subtract, multiply, or divide colors, you can.

```crystal
puts Cor.color(:magenta) - Cor.color(:blue)
# => #<Cor:0x7f5892e2df60 @alpha=255, @blue=255, @green=0, @red=0>
```

### 24 bit truecolor strings

Most modern terminals have support for [True color](https://www.wikiwand.com/en/Color_depth)
which allows you to add color to your terminal output. Crystal
already has support for color output via the `Colorize`
module in the standard library, but Cor takes things
a step further by allowing you to not only colorize
your output, but also bold, italicize, underline,
overline, blink, etc.

Cor also provides a `String` patch that gives the `String` class
chainable truecolor methods.

```crystal
puts "This is awesome!".fore(:blue).back(:white)

puts "Bold me!".bold
puts "Italic me!".italic
puts "Strike me!".strike
puts "Blink me like it's 1999!".blink
puts "Faint me!".faint
puts "Underline me!".underline
puts "Overline me!".overline
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/cor/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris Watson](https://github.com/your-github-user) - creator and maintainer
