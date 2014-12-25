

class TicTacToeGame

  attr_reader :dimension, :units, :cursor_index

  def initialize(dimension)
    @dimension = dimension
    @units = @dimension ** 2
    @board = Array.new(units) { Array.new }
    @player_x = Array.new(units) { Array.new }
    @player_o = Array.new(units) { Array.new }
    @cursor_index = 0
    @turn = 1
  end

  def map_board!
    @board.map!.with_index do |el, i| 
      if @player_x[i] == ["x"]
        @player_x[i]
      elsif @player_o[i] == ["o"]
        @player_o[i]
      else
        el
      end
    end
    @board
  end

  def game_end?
    return true if has_line?(@player_x) || has_line?(@player_o)
    false
  end

  def has_line?(player)
    has_horizontal?(player) || has_vertical?(player) || has_diagonal?(player)
  end


  def has_horizontal?(player_board)
    1.upto(dimension) do |row|
      return true if player_board[row_to_range(row)].all? { |marker| !marker.empty? }
    end
    false
  end

  def has_vertical?(player_board)
    1.upto(dimension) do |col|
      return true if columns_to_rows(player_board)[row_to_range(col)].all? { |marker| !marker.empty? }    
    end
    false
  end

  def has_diagonal?(player_board)
    right_left_diagonal(player_board).all? { |marker| !marker.empty? } ||
    left_right_diagonal(player_board).all? { |marker| !marker.empty? } 
  end

  def cmd_up
    @cursor_index -= dimension if (@cursor_index - dimension) >= 0
  end

  def cmd_down
    @cursor_index += dimension if (@cursor_index + dimension) < units
  end

  def cmd_left
    @cursor_index -= 1 if (@cursor_index - 1) >= 0 && 
      (@cursor_index % dimension) > 0
  end

  def cmd_right
    @cursor_index += 1 if (@cursor_index + 1) < units && 
      (@cursor_index % dimension) < (dimension - 1)
  end

  def cmd_enter
    place_marker(@cursor_index)
  end

  private

  def place_marker(index)
    @player_x[index] << "x" if @turn.odd?
    @player_o[index] << "o" if @turn.even?
    @turn +=  1
  end

  # utility methods for conversion


  def row_to_range(row)
    # algorithm practice for fun
    e = row * dimension - 1
    a = (row - 1) * 2
    (a..e)
  end

  def columns_to_rows(player_board)
    # more algorithm practice -> pivoting an array of 'n' dimensions
    converted_board = Array.new(units) { Array.new }
    index = 0
    0.upto(n-1) do |j|  
      1.upto(n) do |i|
        pivot_index = dimension * (i - 1) + j     
        converted_board[index].push player_board[pivot_index] if !player_board[pivot_index].empty? 
        index += 1
      end    
    end
    converted_board
  end
  
  # utility for diagonal check
  def right_left_diagonal(player_board)
    c, r, right_left_diagonal = dimension-1, 0, []
    dimension.times do |i|
      right_left_diagonal << player_board[coords_to_index(c, r)]
      c -= 1 ; r += 1
    end
    right_left_diagonal
  end

  def left_right_diagonal(player_board)
    c, r, left_right_diagonal = 0, 0, []
    dimension.times do |i|
      left_right_diagonal << player_board[coords_to_index(i, i)]
      c += 1 ; r += 1
    end
    left_right_diagonal
  end

  def coords_to_index(c, r)
    # coords to be represented starting from 0, 0
    (r * dimension) + c
  end
end

class TicTacToeController
  attr_reader :game, :cursor_index

  def initialize(game)
    @game = game
  end

  def process(cmd)
    return if cmd == nil
    game.send(cmd)
    @cursor_index = game.cursor_index
  end

end

class TicTacToeScreen

  def display
    puts "     |     |     "
    puts "     |     |     "
    puts "_____|_____|_____"
    puts "     |     |     "
    puts "     |     |     "
    puts "_____|_____|_____"
    puts "     |     |     "
    puts "     |     |     "
    puts "     |     |     "
  end
  # puts "     |     |     "
end

class InputProcesser
  require 'io/console'

  def initialize(controller)
    @controller = controller
    @commands = {
      "\e[A" => :cmd_up,
      "\e[B" => :cmd_down,
      "\e[D" => :cmd_left,
      "\e[C" => :cmd_right,
      "c" => :cmd_quit,
      "n" => :cmd_new_game,
      "\r" => :cmd_enter
    }
  end

  def run
    STDIN.echo = false
    STDIN.raw!
    while true
      action = STDIN.getch
      break if action == "c"
      
      if action == "\e"
        action << STDIN.read_nonblock(3) rescue nil
        action << STDIN.read_nonblock(2) rescue nil

      end
      
      @controller.process(@commands[action])
      puts @controller.cursor_index

      puts "UP" if action == "\e[A"
      puts "DOWN" if action == "\e[B"
      puts "LEFT" if action == "\e[D"
      puts "RIGHT" if action == "\e[C"
      print "\r"
      action = ""
    end
  end
end
# STDIN.echo = false
game = TicTacToeGame.new(3)
controller = TicTacToeController.new(game)
runner = InputProcesser.new(controller)

runner.run
begin
ensure

STDIN.echo = true
STDIN.cooked!

end

