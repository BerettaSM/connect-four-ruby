# frozen_string_literal: true

class Player
  attr_reader :name, :symbol

  def initialize(name, symbol)
    @name = name
    @symbol = symbol
  end

  def get_play(_game_state)
    gets.chomp
  end
end
