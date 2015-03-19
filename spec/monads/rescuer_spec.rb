# encoding: utf-8

require 'monads/rescuer'

module Monads
  class TestException < StandardError; end

  RSpec.describe 'the Rescuer monad' do
    let(:value) { double }
    let(:rescuer) { Rescuer.new(value) }

    describe '#value' do
      it 'retrieves the value from a Rescuer' do
        expect(rescuer.value).to eq value
      end
    end

    describe '.from_value' do
      context 'when a value is passed' do
        it 'wraps the value in a Rescuer' do
          expect(Rescuer.from_value(value).value).to eq value
        end
      end

      context 'when a block is passed' do
        it 'evaluates the block and wraps the result in a Rescuer' do
          expect(Rescuer.from_value { value }.value).to eq value
        end
      end

      context 'when a block is passed that throws an exception' do
        let(:exception) { TestException.new }

        it 'catches the exception and wraps it in a Rescuer' do
          expect(Rescuer.from_value { raise exception }.exception).to eq exception
        end
      end
    end

    describe '#and_then' do
      context 'when an exception has been caught' do
        before(:example) do
          allow(rescuer).to receive(:exception).and_return(double)
        end

        it 'doesn’t call the block' do
          expect { |block| rescuer.and_then(&block) }.not_to yield_control
        end

        it 'returns self' do
          expect(rescuer.and_then {}).to eq(rescuer)
        end
      end

      context 'when no exception has been caught' do
        it 'calls the block with the value' do
          value_passed_to_block = nil
          rescuer.and_then { |value| value_passed_to_block = value; Rescuer.new(double) }
          expect(value_passed_to_block).to eq(value)
        end

        it 'returns the block’s result' do
          result = double
          expect(rescuer.and_then { |value| Rescuer.new(result) }.value).to eq result
        end

        it 'raises an error if the block doesn’t return another Rescuer' do
          expect { rescuer.and_then { double } }.to raise_error(TypeError)
        end
      end

      context 'when the block throws an exception' do
        let(:exception) { TestException.new }

        it 'returns a new Rescuer that wraps the exception thrown' do
          result = rescuer.and_then { |value| raise exception }
          expect(result.exception).to be(exception)
        end
      end
    end

    describe '#within' do
      context 'when an exception has been caught' do
        before(:example) do
          allow(rescuer).to receive(:exception).and_return(double)
        end

        it 'doesn’t call the block' do
          expect { |block| rescuer.within(&block) }.not_to yield_control
        end

        it 'returns self' do
          expect(rescuer.within {}).to eq(rescuer)
        end
      end

      context 'when no exception has been caught' do
        it 'calls the block with the value' do
          expect { |block| rescuer.within(&block) }.to yield_with_args(value)
        end

        it 'returns the block’s result wrapped in a Rescuer' do
          result = double
          expect(rescuer.within { |value| result }.value).to eq result
        end
      end

      context 'when the block throws an exception' do
        let(:exception) { TestException.new }

        it 'returns a new Rescuer that wraps the exception thrown' do
          result = rescuer.within { |value| raise exception }
          expect(result.exception).to be(exception)
        end
      end
    end
  end
end
