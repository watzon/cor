class String
  def truecolor(**options)
    Cor.truecolor_string(self, **options)
  end

  def fore(color) : self
    color.is_a?(Symbol) ? Cor.color(color) : color
    truecolor(fore: color)
  end

  def back(color) : self
    color.is_a?(Symbol) ? Cor.color(color) : color
    truecolor(back: color)
  end

  def underline : self
    truecolor(underline: true)
  end

  def overline : self
    truecolor(overline: true)
  end

  def bold : self
    truecolor(bold: true)
  end

  def italic : self
    truecolor(italic: true)
  end

  def strike : self
    truecolor(strike: true)
  end

  def blink : self
    truecolor(blink: true)
  end

  def faint : self
    truecolor(faint: true)
  end
end
