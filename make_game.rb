require 'green_shoes'

module Unblock
  def show_hide j, i
    n, m = j*6+i, COLORS.index(@color)
    @colors[n].each &:hide
    @colors[n][m].show
    @game[j][i] = m.to_s
  end
  
  def cell_clear j, i
    @colors[j*6+i].each &:hide
    @game[j][i] = '*'
  end
  
  def output
    out = '['
    @game.each_with_index do |line, j|
      line = line.join
      i = line.index '0'
      if i
        out << format(j, i, 2, :pink, :true)
        if line[i+2] == '0'
          out << format(j, i+2, 2, :pink, :true)
        elsif i < 3
          i = line[3..-1].index '0'
          (out << format(j, i+3, 2, :pink, :true)) if i
        end
      end
      i = line.index '1'
      (out << format(j, i, 3, :lightgreen, :true)) if i
      i = line.index '4'
      (out << format(j, i, 2, :red, :true)) if i
    end
    
    6.times do |i|
      line = (0..5).to_a.map{|j| @game[j][i]}.join
      j = line.index '2'
      if j
        out << format(j, i, 2, :lightblue, :false)
        if line[j+2] == '2'
          out << format(j+2, i, 2, :lightblue, :false)
        elsif j < 3
          j = line[3..-1].index '2'
          (out << format(j+3, i, 2, :lightblue, :false)) if j
        end
      end
      j = line.index '3'
      (out << format(j, i, 3, :gold, :false)) if j
    end
    file = ask_save_file
    open file, 'w' do |f|
      f.puts (out[0...-2] << ']')
    end if file
  end
  
  def format j, i, l, color, vh
    "[%s, %s, %s, %s, %s], " % [j, i, l, color, vh]
  end
end

Shoes.app title: 'Unblock Me! - Make Game', width: 340, height: 370 do
  X, Y, W = 20, 50, 50
  COLORS = [pink, lightgreen, lightblue, gold, red]
  ATTR = [:v2, :v3, :h2, :h3, :v2]
  @colors, @game = [], Array.new(6){Array.new(6){'*'}}
  @color = COLORS.first
  extend Unblock
  background dimgray
  strokewidth 0
  rect X-10, Y-10, W*6+20, W*6+20, fill: silver, curve: 10
  rect X+10+W*6, Y+W/2*3, X, W*2, fill: silver
  rect X+10+W*6, Y+W, X*2, W, fill: dimgray, curve: 5
  rect X+10+W*6, Y+W*3, X*2, W, fill: dimgray, curve: 5

  stroke white
  strokewidth 1
  nofill
  6.times do |j|
    6.times do |i|
      rect(X+W*i, Y+W*j, W+1, W+1).
      click{|b| b == 1 ? show_hide(j, i): cell_clear(j, i)}
      color = []
      COLORS.each{|c| color << rect(X+W*i+1, Y+W*j+1, W-1, W-1, strokewidth: 0, fill: c, hidden: true)}
      @colors << color
    end
  end
  
  nostroke
  COLORS.each_with_index do |c, i|
    rect(20+45*i, 5, 40, 30, fill: c).
    click{@color = c}
    para ATTR[i], left: 30+45*i, top: 10, stroke: white, weight: 'bold'
  end

  button('save'){output}.move 280, 10
end
