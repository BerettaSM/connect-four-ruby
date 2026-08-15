# frozen_string_literal: true

require_relative '../../lib/connect-four-ruby/player'

RSpec.describe Player do
  subject { Player.new 'dummy', '@' }

  context '#name' do
    it 'should be callable' do
      expect(subject).to respond_to :name
    end
  end

  context '#symbol' do
    it 'should be callable' do
      expect(subject).to respond_to :symbol
    end
  end

  context '#get_play' do
    it 'should be callable' do
      expect(subject).to respond_to(:get_play).with(1).argument
    end
  end
end
