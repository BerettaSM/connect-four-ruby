# frozen_string_literal: true

require_relative '../../lib/connect-four-ruby/board'

RSpec.describe Board do
  context '#initialize' do
    let(:rows) { 5 }
    let(:columns) { 4 }
    subject { described_class.new rows, columns }

    it 'should create a properly sized state' do
      state = subject.state

      expect(state.length).to eq rows
      expect(state[0].length).to eq columns
    end

    it 'should raise BoardException when given row size of zero' do
      expect { described_class.new 0, columns }.to raise_error BoardException
    end

    it 'should raise BoardException when given col size of zero' do
      expect { described_class.new rows, 0 }.to raise_error BoardException
    end

    it 'should raise BoardException when given a negative row size' do
      expect { described_class.new(-1, columns) }.to raise_error BoardException
    end

    it 'should raise BoardException when given a negative col size' do
      expect { described_class.new(rows, -1) }.to raise_error BoardException
    end
  end

  context '#state' do
    it 'should be callable' do
      expect(subject).to respond_to :state
    end

    it 'should return an array' do
      expect(subject.state).to be_an_instance_of Array
    end
  end

  context '#drop_disc' do
    let(:disc) { 'x' }
    let(:column) { 0 }
    let(:neg_out_of_bounds_column) { -1 }
    let(:pos_out_of_bounds_column) { subject.columns }

    it 'should be callable with 2 arguments' do
      expect(subject).to respond_to(:drop_disc).with(2).arguments
    end

    it 'should raise BoardException when given a negative out of bonds column' do
      expect { subject.drop_disc(neg_out_of_bounds_column, disc) }.to raise_error BoardException
    end

    it 'should raise BoardException when given a positive out of bonds column' do
      expect { subject.drop_disc(pos_out_of_bounds_column, disc) }.to raise_error BoardException
    end

    context 'when called on an empty column' do
      it 'should drop the disc in the last row' do
        subject.drop_disc(column, disc)

        # TODO: Get a helper method to fetch disc by row/col and get rid of this
        expect(subject.state.dig(subject.rows - 1, 0)).to eq disc
      end
    end

    context 'when called on a column with one disc' do
      subject do
        s = described_class.new(3, 3)
        s.instance_variable_set(:@state, [
                                  [nil, nil, nil],
                                  [nil, nil, nil],
                                  ['y', nil, nil]
                                ])
        s
      end

      it 'should not overwrite the existing disc' do
        subject.drop_disc(column, disc)

        # TODO: Get a helper method to fetch disc by row/col and get rid of this
        expect(subject.state.dig(subject.rows - 1, 0)).not_to eq disc
      end
    end
  end
end
