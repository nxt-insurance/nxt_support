RSpec.describe NxtSupport::Refinements::Crystalizer do
  describe 'Array#crystalize' do
    class OrdinaryClass
      attr_reader :array

      def initialize(array)
        @array = array
      end

      def crystalize
        array.crystalize
      end
    end

    class RefinedClass
      using NxtSupport::Refinements::Crystalizer

      attr_reader :array

      def initialize(array)
        @array = array
      end

      def crystalize(**options)
        array.crystalize(**options)
      end

      def crystalize_with_block
        array.crystalize { raise StandardError, 'Ambiguous' }
      end
    end

    class RefinedClassWithNxtInit
      include NxtInit
      using NxtSupport::Refinements::Crystalizer

      attr_init :array, crystalized: -> { array.crystalize }

      attr_reader :crystalized
    end

    context 'without refinement' do
      it 'raises an error' do
        expect { OrdinaryClass.new([1, 1, 1]).crystalize }.to raise_error(NoMethodError, /undefined method `crystalize'/)
      end
    end

    context 'with refinement' do
      context 'when no block is given' do
        context 'when the array can be crystalized' do
          it 'crystalizes' do
            expect(RefinedClass.new([1, 1, 1]).crystalize).to eq 1
          end
        end

        context 'when the array cannot be crystalized' do
          it 'raises an error' do
            expect { RefinedClass.new([1, 2, 3]).crystalize }.to raise_error(NxtSupport::Crystalizer::Error, 'Values in collection are not unanimous: [1, 2, 3]')
          end
        end
      end

      context 'when the attribute is specified' do
        context 'when the array can be crystallized' do
          it 'crystallizes' do
            collection = [
              OpenStruct.new({a: 1, b: 0}),
              OpenStruct.new({a: 1, b: 1}),
              OpenStruct.new({a: 1, b: 2}),
            ]
            expect(RefinedClass.new(collection).crystalize(with: :a)).to eq 1
          end
        end

        context 'when the array cannot be crystallized' do
          it 'raises an error' do
            collection = [
              OpenStruct.new({a: 1, b: 0}),
              OpenStruct.new({a: 2, b: 1}),
              OpenStruct.new({a: 3, b: 2}),
            ]
            expect { RefinedClass.new(collection).crystalize(with: :a) }.to raise_error(NxtSupport::Crystalizer::Error, 'Values in collection are not unanimous: [1, 2, 3]')
          end
        end
      end

      context 'when block is given' do
        context 'when the array can be crystalized' do
          it 'crystalizes' do
            expect(RefinedClass.new([1, 1, 1]).crystalize_with_block).to eq 1
          end
        end

        context 'when the array cannot be crystalized' do
          it 'calls the given block' do
            expect { RefinedClass.new([1, 2, 3]).crystalize_with_block }.to raise_error(StandardError, 'Ambiguous')
          end
        end
      end

      context 'within NxtInit' do
        context 'when the array can be crystalized' do
          it 'crystalizes' do
            expect(RefinedClassWithNxtInit.new(array: [1, 1, 1]).crystalized).to eq 1
          end
        end

        context 'when the array cannot be crystalized' do
          it 'raises an error' do
            expect { RefinedClassWithNxtInit.new(array: [1, 2, 3]) }.to raise_error(NxtSupport::Crystalizer::Error, 'Values in collection are not unanimous: [1, 2, 3]')
          end
        end
      end
    end
  end
end
