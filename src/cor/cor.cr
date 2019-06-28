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

  # Create a new `Cor` instance from hue, saturation, and value.
  def self.from_hsv(h, s, v)
    h, s, v = h.to_f/360, s.to_f/100, v.to_f/100
    h_i = (h*6).to_i
    f = h*6 - h_i
    p = v * (1 - s)
    q = v * (1 - f*s)
    t = v * (1 - (1 - f) * s)
    r, g, b = v, t, p if h_i==0
    r, g, b = q, v, p if h_i==1
    r, g, b = p, v, t if h_i==2
    r, g, b = p, q, v if h_i==3
    r, g, b = t, p, v if h_i==4
    r, g, b = v, p, q if h_i==5
    new(
      (r.not_nil! * 255).to_i,
      (g.not_nil! * 255).to_i,
      (b.not_nil! * 255).to_i
    )
  end

  # Create a new `Cor` instance from hue, saturation, and lightness.
  def self.from_hsl(h, s, l)
    m2 = if l <= 0.5
      l * (s + 1)
    else
      l + s - l * s
    end

    m1 = l * 2 - m2

    rgb = [
      hue_to_rgb(m1, m2, h + 1.0 / 3),
      hue_to_rgb(m1, m2, h),
      hue_to_rgb(m1, m2, h - 1.0 / 3)
    ].map { |c| (c * 0xff).round }

    new(rgb[0], rgb[1], rgb[2])
  end

  # Create a new `Cor` instance from hue, saturation, and brightness.
  def self.from_hsb(h, s, b)
    Cor.from_hsl(h, s, b)
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

    new(arr[0], arr[1], arr[2], arr[3])
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

  # The HSV (hue / saturation / value) of the color
  def to_hsv
    r, g, b = @red.to_f / 255.0, @green.to_f / 255.0, @blue.to_f / 255.0

    max = [r, g, b].max
    min = [r, g, b].min
    delta = max - min
    v = max * 100.0

    if (max != 0.0)
      s = delta / max * 100.0
    else
      s = 0.0
    end

    if (s == 0.0)
      h = 0.0
    else
      if (r == max)
        h = (g - b) / delta
      elsif (g == max)
        h = 2.0 + (b - r) / delta
      else # (b == max)
        h = 4.0 + (r - g) / delta
      end

      h *= 60.0

      if (h < 0)
        h += 360.0
      end
    end

    {h: h, s: s, v: v}
  end

  # The HSV (hue / saturation / lightness) of the color
  def to_hsl


    rgb = [@red / 255.0, @green / 255.0, @blue / 255.0]

    min_rgb, max_rgb = rgb.min, rgb.max
    delta = max_rgb - min_rgb

    l = (max_rgb + min_rgb) / 2.0

    if delta < 1e-5
      h = s = 0
    else
      # Calculate the saturation
      if l < 0.5
        s = delta / (max_rgb + min_rgb)
      else
        s = delta / (2 - max_rgb - min_rgb)
      end

      deltas = rgb.map{ |c| (((max_rgb - c) / 6.0) + (delta / 2.0)) / delta }

      h = if (rgb[0] - max_rgb).abs < 1e-5
        deltas[2] - deltas[1]
      elsif (rgb[1] - max_rgb).abs < 1e-5
        (1.0 / 3.0) + deltas[0] - deltas[2]
      else
        (2.0 / 3.0) + deltas[1] - deltas[0]
      end

      h += 1 if h < 0
      h -= 1 if h > 1
    end

    {h: h, s: s, l: l}
  end

  # The HSb (hue / saturation / brightness) of the color
  def to_hsb
    hsl = to_hsl
    {h: hsl[:h], s: hsl[:s], b: hsl[:l]}
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

  private def hue_percentage(hue)
    hue / 360.0
  end

  # helper for making rgb
  private def self.hue_to_rgb(m1, m2, h)
    h += 1 if h < 0
    h -= 1 if h > 1
    return m1 + (m2 - m1) * h * 6 if h * 6 < 1
    return m2 if h * 2 < 1
    return m1 + (m2 - m1) * (2.0/3 - h) * 6 if h * 3 < 2
    return m1
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
