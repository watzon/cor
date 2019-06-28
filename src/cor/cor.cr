require "./colors"

class Cor
  include Comparable(Cor)
  include Cor::Colors

  # red value for this color
  getter red : Int32

  # green value for this color
  getter green : Int32

  # blue value for this color
  getter blue : Int32

  # alpha (opacity) value for this color
  getter alpha : Int32

  # Creates a new `Cor` instance from `red`, `green`, `blue`
  # and `alpha` values.
  def initialize(red, green, blue, alpha = 255)
    red = validate_color(red)
    green = validate_color(green)
    blue = validate_color(blue)
    alpha = validate_color(alpha)

    @red, @green, @blue, @alpha = red, green, blue, alpha
  end

  # Creates a new `Cor` instance from a hex string.
  def self.new(hex : String)
    hex = hex.gsub(/^#/, "")

    # Raise if the hex string contains invalid characters
    if !(hex =~ /[a-fA-F0-9]+/)
      raise "hex string `#{hex}` contains invalid characters"
    end

    # Raise if the hexstring isn't of a valid length
    if !([3, 6, 8].includes?(hex.size))
      raise "hex string must be either 3, 6, or 8 characters long"
    end

    # Make the hex string the correct length
    if [3, 4].includes?(hex.size)
      hex = hex.split("").map(&.* 2).join
    end

    # Add alpha on there if it doesn't exist
    if hex.size == 6
      hex += "ff"
    end

    # Subdivide it up into rgb values
    components = hex.scan(/.{2}/)
    red, green, blue, alpha = components.map(&.[0].to_i(16))

    new(red, green, blue, alpha)
  end

  # Gets one of the many color values defined in `COLORS`
  # as a `Cor` instance.
  def self.color(color)
    raise "the color #{color} has not been defined in `Cor`" unless COLORS.has_key?(color)
    new(*COLORS[color])
  end

  # Implements the comparison operator for `Cor`.
  def <=>(other)
    self.to_a <=> other.to_a
  end

  {% for operator in ['+', '-', '*', '/'] %}
  def {{ operator.id }}(other : Cor)
    arr = self.to_tuple.zip(other.to_tuple).map do |(a, b)|
      num = a * b
      num = 0 if num < 0
      num = 255 if num > 255
      num
    end

    Cor.new(arr[0], arr[1], arr[2], arr[3])
  end
  {% end %}

  # Outputs this `Cor` instance as a `hex` string.
  def hex_string(prefix = false, alpha = false, upcase = false)
    hex = String.build do |str|
      str << "#" if prefix
      str << [@red, @green, @blue].map { |i| sprintf("%02x", i) }.join
    end
    hex = hex.upcase if upcase
    hex
  end

  # Outputs this `Cor` instance as a css `rgb(a)` string.
  def rgb_string(alpha = false)
    String.build do |str|
      str << "rgb"
      str << "a" if alpha
      str << "("
      str << [@red, @green, @blue].join(", ")
      if alpha
        alpha = (@alpha.to_f64 / 255).round(2)
        alpha = 1 if alpha == 1.0
        alpha = 0 if alpha == 0.0
        str << ", #{alpha}"
      end
      str << ")"
    end
  end

  # Converts `string` to an ANSI escape sequence for use with
  # truecolor enabled terminals. `fore` and
  # `back` can be either a `Cor` instance or
  # a symbol representing a `COLORS` value.
  def self.truecolor_string(
    string : String,
    fore = nil,
    back = nil,
    bold = false,
    faint = false,
    italic = false,
    underline = false,
    blink = false,
    strike = false,
    overline = false
  )
    fore = fore.is_a?(Symbol) ?
      Cor.color(fore) :
      fore

    back = back.is_a?(Symbol) ?
      Cor.color(back) :
      back

    String.build do |str|
      if bc = back
        str << sprintf("\033[48;2;%d;%d;%dm", [bc.red, bc.green, bc.blue])
      end

      if fc = fore
        str << sprintf("\033[38;2;%d;%d;%dm", [fc.red, fc.green, fc.blue])
      end

      str << "\033[1m"  if bold
      str << "\033[2m"  if faint
      str << "\033[3m"  if italic
      str << "\033[4m"  if underline
      str << "\033[5m"  if blink
      str << "\033[9m"  if strike
      str << "\033[53m" if overline

      str << sprintf("%s\033[0m", string)
    end
  end

  # Set the red value for this color
  def red=(value)
    value = validate_color(value)
    @red = value
  end

  # Set the green value for this color
  def green=(value)
    value = validate_color(value)
    @red = value
  end

  # Set the blue value for this color
  def blue=(value)
    value = validate_color(value)
    @blue = value
  end

  # Set the alpha value for this color. Can be either
  # a float between 0 and 1, or a integer value
  # between 0 and 255.
  def alpha=(value)
    if value.is_a?(Float)
      if value < 0.0 || value > 1.0
        value = validate_color(value)
        @alpha = value
      else
        @alpha = (value * 255).to_i
      end
    else
      value = validate_color(value)
      @alpha = value
    end
  end

  # Returns a new `Cor` that's the inverse of self.
  def inverse
    inverted = hex_string(alpha: true).to_i(16) ^ 0x00ffffff
    inverted = sprintf("%08x", inverted)
    Cor.new(inverted)
  end

  # The brigthess/lightness value of the color.
  #
  # Algoritm adapted from [http://alienryderflex.com/hsp.html](http://alienryderflex.com/hsp.html)
  def brightness
    pr, pg, pb = 0.299, 0.587, 0.114
    Math.sqrt(@red * @red * pr + @green * @green * pg + @blue * @blue + pb)
  end

  # The hue of the color.
  #
  # Algoritm adapted from [http://alienryderflex.com/hsp.html](http://alienryderflex.com/hsp.html)
  def hue
    r, g, b = @red, @green, @blue
    return 0.0 if r == g == b
    if r > g && r > b
      if b > g
        6.0 / 6.0 - 1.0 / 6.0 * (b - g) / (r - g)
      else
        0.0 / 6.0 + 1.0 / 6.0 * (g - b) / (r - b)
      end
    elsif g >= r && g >= b
      if r >= b
        2.0 / 6.0 - 1.0 / 6.0 * (r - b) / (g - b)
      else
        2.0 / 6.0 + 1.0 / 6.0 * (b - r) / (g - r)
      end
    else
      if g >= r
        4.0 / 6.0 - 1.0 / 6.0 * (g - r) / (b - r)
      else
        4.0 / 6.0 + 1.0 / 6.0 * (r - g) / (b - g)
      end
    end
  end

  # The saturation of the color.
  #
  # Algoritm adapted from [http://alienryderflex.com/hsp.html](http://alienryderflex.com/hsp.html)
  def saturation
    r, g, b = @red, @green, @blue
    return 0.0 if r == g == b
    if r > g && r > b
      if b > g
        1 - g / r
      else
        1 - b / r
      end
    elsif g >= r && g >= b
      if r >= b
        1 - b / g
      else
        1 - r / g
      end
    else
      if g >= r
        1 - r / b
      else
        1 - g / b
      end
    end
  end

  # Convert the `Cor` to an array.
  def to_a
    [@red, @green, @blue, @alpha]
  end

  # Convert the `Cor` to a tuple.
  def to_tuple
    {@red, @green, @blue, @alpha}
  end

  # Convert the `Cor` to a hash.
  def to_h
    {
      "red" => @red,
      "green" => @green,
      "blue" => @blue,
      "alpha" => @alpha
    }
  end

  # Convert to a string
  def to_s
    "Cor{#{@red}, #{@green}, #{blue}, #{@alpha}}"
  end

  # Pretty print (it's a rainbow!)
  def pretty_print(pp)
    rainbow = ->(string : String) {
      color_hash = Colors::COLORS.to_a
      colors = 0.upto(string.size - 1).to_a.map { |i| color_hash[i][0] }
      string.split("").map_with_index do |c, i|
        Cor.truecolor_string(c.to_s, colors[i])
      end.join
    }

    pp.text(rainbow.call("#<Cor: @red: #{@red}, @green: #{green}, @blue: #{blue}, @alpha: #{@alpha}>"))
  end

  private def validate_color(color)
    if color.is_a?(Float) && (color < 1.0 && color > 0.0)
      color = (255 * color).to_i
    end

    if color > 255 || color < 0
      raise "color values must be between 0 and 255"
    end

    color.to_i
  end
end
