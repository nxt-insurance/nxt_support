RSpec.describe NxtSupport::Crystalizer do

  describe '#call' do
    context 'without with' do
      subject do
        described_class.new(collection: collection).call
      end

      context 'when the values are unique' do
        let(:collection) { %w[andy andy andy] }

        it 'reveals the value' do
          expect(subject).to eq('andy')
        end
      end

      context 'when the values are not unique' do
        let(:collection) { %w[andy scotty] }

        it 'raises an error' do
          expect { subject }.to raise_error(NxtSupport::Crystalizer::Error, 'Values in collection are not unanimous: ["andy", "scotty"]')
        end
      end

      context 'when the collection is empty' do
        let(:collection) { %w[] }

        it 'raises an error' do
          expect { subject }.to raise_error(NxtSupport::Crystalizer::Error, 'Values in collection are not unanimous: []')
        end
      end
    end

    context 'with :with option' do
      context 'with method' do
        subject do
          described_class.new(collection: collection, with: :name).call
        end

        context 'when the values are unique' do
          let(:collection) { %w[andy andy andy].map { |name| OpenStruct.new(name: name) } }

          it 'reveals the value' do
            expect(subject).to eq('andy')
          end
        end

        context 'when the values are not unique' do
          let(:collection) { %w[andy scotty].map { |name| OpenStruct.new(name: name) } }

          it 'raises an error' do
            expect { subject }.to raise_error(NxtSupport::Crystalizer::Error, /Values in collection are not unanimous:/)
          end
        end

        context 'when the collection is empty' do
          let(:collection) { %w[] }

          it 'raises an error' do
            expect { subject }.to raise_error(NxtSupport::Crystalizer::Error, /Values in collection are not unanimous:/)
          end
        end
      end

      context 'with block' do
        subject do
          described_class.new(collection: collection, with: ->(struct) { struct.name } ).call
        end

        context 'when the values are unique' do
          let(:collection) { %w[andy andy andy].map { |name| OpenStruct.new(name: name) } }

          it 'reveals the value' do
            expect(subject).to eq('andy')
          end

          context 'when the values are not unique' do
            let(:collection) { %w[andy scotty].map { |name| OpenStruct.new(name: name) } }

            it 'raises an error' do
              expect { subject }.to raise_error(NxtSupport::Crystalizer::Error, /Values in collection are not unanimous:/)
            end
          end

          context 'when the collection is empty' do
            let(:collection) { %w[] }

            it 'raises an error' do
              expect { subject }.to raise_error(NxtSupport::Crystalizer::Error, /Values in collection are not unanimous:/)
            end
          end
        end
      end
    end

    context 'custom on_ambiquity handler' do
      let(:collection) { %w[anthony aki] }
      let(:custom_handler) { -> { raise ZeroDivisionError, 'oh oh' } }

      subject do
        described_class.new(collection: collection, on_ambiguity: custom_handler).call
      end

      it 'raises an error' do
        expect { subject }.to raise_error(ZeroDivisionError)
      end
    end
  end
end
