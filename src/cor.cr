require "./cor/cor"

# Cor (which means color in Portuguese) is a library for more easily
# working with colors in Crystal. You can think of it as a more
# powerful version of `Colorize`. Cor allows you to very
# easily convert RGB(A) values to hex and back again for
# use in CSS and HTML. It also provides a set of
# chainable methods for creting colorful strings
# for the terminal using truecolor.
#
# For full usage instructions see the README.
class Cor
end

require "./cor/string"

# Cor::COLORS.to_h.in_groups_of(Cor::COLORS.size / 8) do |block|
#   block.each do |tuple|
#     if tup = tuple
#       color = Cor.color(tup[0])
#       puts tup[0].to_s.fore(color).back(color.inverse)
#     end
#   end
# end

red = Cor.color(:red)
pp red
hsb = red.to_hsb
red = Cor.from_hsb(**hsb)
pp red
