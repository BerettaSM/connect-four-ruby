# frozen_string_literal: true

require_relative '../../lib/connect-four-ruby/game'

RSpec.describe Game do
  let(:player1) { double('player1', name: 'player1', symbol: 'x', get_play: 0) }
  let(:player2) { double('player2', name: 'player2', symbol: 'y', get_play: 1) }
  let(:board) { Board.new }

  subject(:game) { described_class.new(board, player1, player2) }

  context '#initialize' do
    let(:board1) { Board.new(1, 4) }
    let(:board2) { Board.new(4, 1) }

    it 'should not throw if win score is attainable column wise' do
      expect { described_class.new(board1, player1, player2, win_score: 4) }.not_to raise_error
    end

    it 'should not throw if win score is attainable row wise' do
      expect { described_class.new(board2, player1, player2, win_score: 4) }.not_to raise_error
    end

    it 'should throw if win score is unattainable due to board dimensions' do
      expect { described_class.new(board1, player1, player2, win_score: 5) }.to raise_error GameException
    end
  end

  context '#players' do
    it 'should return an array' do
      expect(subject.players).to be_an_instance_of Array
    end

    it 'should return both players' do
      expect(subject.players).to eq [player1, player2]
    end
  end

  context '#state' do
    it 'should return the game state' do
      expect(subject.state).to eq board.state
    end
  end

  context '#turn' do
    it 'should return 1 when no plays occurred' do
      expect(subject.turn).to eq 1
    end

    it 'should return 2 after a single play occurred' do
      subject.next_play

      expect(subject.turn).to eq 2
    end

    it 'should return 3 when after 2 plays occurred' do
      subject.next_play
      subject.next_play

      expect(subject.turn).to eq 3
    end
  end

  context '#next_play' do
    let(:board) do
      b = Board.new(4, 4)
      allow(b).to receive(:drop_disc).and_return([0, 3], [1, 3])
      b
    end

    subject(:game) do
      described_class.new(board, player1, player2)
    end

    it 'should call drop_disc on board' do
      expect(board).to receive(:drop_disc).once

      subject.next_play
    end

    context 'on first call' do
      it 'should request a play from player 1' do
        expect(player1).to receive(:get_play).once

        subject.next_play
      end

      it 'should not request a play from player 2' do
        expect(player2).not_to receive(:get_play)

        subject.next_play
      end
    end

    context 'on second call' do
      it 'should request a play from player 2' do
        expect(player2).to receive(:get_play).once

        subject.next_play
        subject.next_play
      end

      it 'should not request a play from player 1' do
        expect(player1).to receive(:get_play).at_most(1)

        subject.next_play
        subject.next_play
      end
    end

    context 'on any call' do
      let(:board) do
        s = Board.new(3, 3)
        s.instance_variable_set(:@state, [
                                  [nil, nil, nil],
                                  ['y', 'x', 'x'],
                                  ['x', 'y', 'y']
                                ])
        s
      end

      subject(:game) do
        s = described_class.new(board, player1, player2, win_score: 3)
        s.instance_variable_set(:@turn, 6)
        s
      end

      context 'on a winning play' do
        it 'should set game as over' do
          allow(player1).to receive(:get_play).and_return(2)

          subject.next_play

          expect(subject).to be_over
        end
      end

      context 'on a non game ending play' do
        xit 'should not set game as over' do
          allow(player1).to receive(:get_play).and_return(1)

          subject.next_play

          expect(subject).to_not be_over
        end
      end
    end

    context 'when game is not yet over' do
      it 'should not raise an exception' do
        expect { subject.next_play }.to_not raise_error
      end
    end

    context 'when game is already over' do
      subject(:game) do
        s = described_class.new(board, player1, player2)
        s.instance_variable_set(:@over, true)
        s
      end

      it 'should raise an exception' do
        expect { subject.next_play }.to raise_error(GameException)
      end
    end

    context 'when a tie occurs' do
      let(:board) do
        b = Board.new(3, 3)
        b.instance_variable_set(:@state, [
                                  ['x', 'y', nil],
                                  ['x', 'x', 'y'],
                                  ['y', 'x', 'y']
                                ])
        b
      end

      subject do
        s = described_class.new(board, player1, player2, win_score: 3)
        s.instance_variable_set(:@turn, 8)
        s
      end

      before do
        allow(player1).to receive(:get_play).and_return(2)
      end

      it 'should be over' do
        subject.next_play

        expect(subject).to be_over
      end

      it 'should not have a winner' do
        subject.next_play

        expect(subject.winner).to be_nil
      end

      it 'should not go to next turn' do
        expect { subject.next_play }.to_not(change { subject.turn })
      end
    end

    context 'when a win occurs' do
      let(:board) do
        b = Board.new(3, 3)
        b.instance_variable_set(:@state, [
                                  ['y', 'x', nil],
                                  ['y', 'y', 'x'],
                                  ['x', 'y', 'x']
                                ])
        b
      end

      subject do
        s = described_class.new(board, player1, player2, win_score: 3)
        s.instance_variable_set(:@turn, 8)
        s
      end

      before do
        allow(player1).to receive(:get_play).and_return(2)
      end

      it 'should be over' do
        subject.next_play

        expect(subject).to be_over
      end

      it 'should set a winner' do
        subject.next_play

        expect(subject.winner).to_not be_nil
      end

      it 'should not go to next turn' do
        expect { subject.next_play }.to_not(change { subject.turn })
      end
    end

    context 'when no win or tie occurs' do
      it 'should go to next turn' do
        expect { subject.next_play }.to(change { subject.turn }.by(1))
      end
    end
  end
end
