# frozen_string_literal: true

require_relative './board'

class GameException < StandardError; end

class Game
  attr_reader :win_score, :over, :winner

  def initialize(board, player1, player2, win_score: 4)
    validate_win_score(win_score, board)

    @board = board
    @p1 = player1
    @p2 = player2
    @winner = nil # set to a player if he wins
    @over = false
    @win_score = win_score
    @turn = 0
  end

  def state
    @board.state
  end

  def players
    [@p1, @p2]
  end

  def turn
    @turn + 1
  end

  def next_play
    raise GameException, 'game is over' if over?

    player = current_player
    candidate_column = player.get_play(@board.state).to_i
    chosen_row, chosen_col = @board.drop_disc(candidate_column, player.symbol)

    if winner?(chosen_row, chosen_col)
      @winner = player
      @over = true
    elsif @board.filled?
      @over = true
    else
      @turn += 1
    end
  end

  def current_player
    players[@turn % 2]
  end

  def next_player
    players[(@turn + 1) % 2]
  end

  def over?
    @over
  end

  def tie?
    over? && @winner.nil?
  end

  private

  def validate_win_score(win_score, board)
    raise GameException unless win_score <= [board.rows, board.columns].max
  end

  def winner?(last_play_row, last_play_col)
    symbol = @board.at(last_play_row, last_play_col)
    state = @board.state

    return false if symbol.nil?

    [
      score_met?(state.fetch(last_play_row), symbol), # row
      score_met?(state.transpose.fetch(last_play_col), symbol), # col
      score_met?(get_left_diag(last_play_row, last_play_col), symbol), # left diag
      score_met?(get_right_diag(last_play_row, last_play_col), symbol) # right diag
    ].any?
  end

  def score_met?(symbols, target)
    count = 0

    symbols.each do |symbol|
      count = symbol == target ? count + 1 : 0

      return true unless count < @win_score
    end

    false
  end

  # maybe the methods below should be at the board instead?

  def get_left_diag(row, col)
    gen_left_diag(row, col).collect { |r, c| state.dig(r, c) }
  end

  def get_right_diag(row, col)
    gen_right_diag(row, col).collect { |r, c| state.dig(r, c) }
  end

  def gen_left_diag(row, col)
    diag = [leftmost_diag(row, col)]
    diag << [diag[-1][0] + 1, diag[-1][1] + 1] until diag[-1][0] >= @board.rows || diag[-1][1] >= @board.columns
    diag
  end

  def gen_right_diag(row, col)
    diag = [rightmost_diag(row, col)]
    diag << [diag[-1][0] + 1, diag[-1][1] - 1] until diag[-1][0] >= @board.rows || diag[-1][1].zero?
    diag
  end

  def leftmost_diag(row, col)
    # returns the upper leftmost diag of a given coord
    delta = row - col
    delta.positive? ? [delta, 0] : [0, -delta]
  end

  def rightmost_diag(row, col)
    # returns the upper rightmost diag of a given coord
    mirrored_col = @board.columns - col - 1
    r, c = leftmost_diag(row, mirrored_col)
    [r, @board.columns - c - 1]
  end
end
