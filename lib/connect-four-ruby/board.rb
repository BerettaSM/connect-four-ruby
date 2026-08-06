# frozen_string_literal: true

class BoardException < StandardError; end

class Board
  attr_reader :state, :rows, :columns

  def initialize(rows = 6, columns = 7, win_condition: 4)
    @rows = rows
    @columns = columns
    @win_condition = win_condition
    @state = create_board(rows, columns)
  end

  def drop_disc(column, disc)
    validate_drop_column(column)

    row = 0

    # TODO: Get a helper method to fetch disc by row/col and get rid of this
    row += 1 while row < @rows - 1 && @state[row + 1][column].nil?

    @state[row][column] = disc
  end

  private

  def create_board(rows, columns)
    validate_board_dimension([rows, columns].min)

    Array.new(rows) { Array.new(columns) }
  end

  def validate_board_dimension(dimension)
    raise BoardException, 'invalid dimension' unless dimension.positive?
  end

  def validate_drop_column(column)
    raise BoardException, 'out of bounds column' unless column.between?(0, @columns - 1)
  end
end
