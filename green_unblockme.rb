require 'green_shoes'

module Unblock
  def range
    min, max = 0, 6 - @car.len
    @car.vertical ? (n, m = @car.x, @car.y) : (n, m = @car.y, @car.x)
    case n
    when min
      max = cal_max n, m, max
    when max
      min = cal_min n, m, min
    else
      min, max = cal_min(n, m, min), cal_max(n, m, max)
    end
    d = @car.vertical ? X : Y
    min, max = min*W+d, max*W+d
    (min..max)
  end

  def cal_max n, m, max
    ((n+1)..max).each do |x|
      (max = x - 1; break) if(@car.vertical ? @board[m][x+@car.len-1] : @board[x+@car.len-1][m])
    end
    max
  end

  def cal_min n, m, min
    (min..(n-1)).to_a.reverse.each do |x|
      (min = x + 1; break) if(@car.vertical ? @board[m][x] : @board[x][m])
    end
    min
  end
end

Shoes.app title: 'Unblock Me!', width: 340, height: 370 do
  X, Y, W = 20, 50, 50
  extend Unblock
  background dimgray
  strokewidth 0

  rect X-10, Y-10, W*6+20, W*6+20, fill: silver, curve: 10
  rect X+10+W*6, Y+W/2*3, X, W*2, fill: silver
  rect X+10+W*6, Y+W, X*2, W, fill: dimgray, curve: 5
  rect X+10+W*6, Y+W*3, X*2, W, fill: dimgray, curve: 5

  stroke white
  strokewidth 5
  
  data, cars = [], []
  games = Dir['./game/*']
  number  = games.map{|file| File.basename file}
  len = number.length
  games.each{|g| data << eval(IO.read g)}
  run = proc do |num|
    @flag = false
    @board = Array.new(6){Array.new 6}
    data[num].each do |y, x, len, color, vh|
      if vh
        len.times{|i| @board[y][x+i] = :exist}
        w, h = W*len-4, W-4
      else
        len.times{|j| @board[y+j][x] = :exist}
        w, h = W-4, W*len-4
      end
    
      car = rect(x*W+X, y*W+Y, w, h, curve: 10, fill: color, vertical: vh, x: x, y: y, len: len)
      cars << car
    
      car.click do
        @flag, @car = true, car 
        b, l, t = mouse
        @dl, @dt = car.left - l, car.top - t
      end
    
      car.release do
        @flag = false
        if @car.vertical
          @car.len.times{|n| @board[@car.y][@car.x+n] = nil}
          @car.move (@car.left.to_i - X + W/2) / W * W + X, @car.top
          @car.x = (@car.left.to_i - X) / W
          @car.len.times{|n| @board[@car.y][@car.x+n] = :exist}
        else
          @car.len.times{|n| @board[@car.y+n][@car.x] = nil}
          @car.move @car.left, (@car.top.to_i - Y + W/2) / W * W + Y
          @car.y = (@car.top.to_i - Y) / W
          @car.len.times{|n| @board[@car.y+n][@car.x] = :exist}
        end
        if @car.fill == red and @car.x == 4
          l, t = @car.left, @car.top
          a = animate do |i|
            i *= 10
            @car.move l + i, t
            a.stop if i > W * 2
          end
        end
      end
    end
  end

  run[n=0]
  
  style Shoes::Link, underline: false, weight: 'bold', stroke: '#FFF'
  style Shoes::LinkHover, underline: false, weight: 'bold', stroke: '#B82'
  b = rect 150, 5, 60, 30, fill: dimgray, curve: 5, strokewidth: 0
  bt = tagline number[n], left: 150, top: 5, stroke: white, weight: 'bold'
  b.click{cars.clear; bt.text = strong fg(number[n], white); run[n]}
  para link("&lt;&lt;"){cars.clear; bt.text = strong fg(number[n=(n-1)%len], white); run[n]}, left: 90, top: 10
  para link('>>'){cars.clear; bt.text = strong fg(number[n=(n+1)%len], white); run[n]}, left: 240, top: 10

  motion do |left, top|
    if @flag
      if @car.vertical
        @car.move(left + @dl, @car.top) if range.include?(left + @dl)
      else
        @car.move(@car.left, top + @dt) if range.include?(top + @dt)
      end
    end
  end
end
