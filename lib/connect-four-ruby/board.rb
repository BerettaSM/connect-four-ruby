# frozen_string_literal: true

class BoardException < StandardError; end

class Board
  attr_reader :state, :rows, :columns

  def initialize(rows = 6, columns = 7)
    @rows = rows
    @columns = columns
    @state = create_board(rows, columns)
  end

  def at(row, column)
    validate_row(row)
    validate_column(column)

    @state[row][column]
  end

  def drop_disc(column, disc)
    raise BoardException, 'full column' unless at(0, column).nil?

    uniq = uniq_discs

    raise BoardException, 'invalid disc' unless uniq.count < 2 || uniq.include?(disc)

    row = 0
    last_row = @rows - 1

    row += 1 while row < last_row && at(row + 1, column).nil?

    @state[row][column] = disc

    [row, column]
  end

  def filled?
    @state.first.compact.count == @columns
  end

  private

  def create_board(rows, columns)
    validate_board_dimension([rows, columns].min)

    Array.new(rows) { Array.new(columns) }
  end

  def validate_board_dimension(dimension)
    raise BoardException, 'invalid dimension' unless dimension.positive?
  end

  def validate_column(column)
    raise BoardException, 'out of bounds column' unless column.between?(0, @columns - 1)
  end

  def validate_row(row)
    raise BoardException, 'out of bounds row' unless row.between?(0, @rows - 1)
  end

  def uniq_discs
    @state.flatten.compact.uniq
  end
end
