RSpec.describe NxtSupport::Services::Base do
  describe '#class_interface' do
    context 'when #call is used by default' do
      let(:test_class) do
        Class.new do
          include NxtSupport::Services::Base
          def call
            'hello there'
          end
        end
      end

      subject { test_class.call }

      it 'successfully calls the class method' do
        expect(subject).to eq('hello there')
      end
    end

    context 'when #call is used by default and attributes are initialized' do
      let(:test_class) do
        Class.new do
          include NxtSupport::Services::Base
          include NxtInit

          attr_init :test_string

          def call
            test_string
          end
        end
      end

      let(:test_string) { 'abc' }

      subject { test_class.call(test_string: test_string) }

      it 'successfully calls the class method with attributes' do
        expect(subject).to eq(test_string)
      end
    end

    context 'when a custom method name is used' do
      let(:test_class) do
        Class.new do
          include NxtSupport::Services::Base

          class_interface :build

          def build
            'building..'
          end
        end
      end

      subject { test_class.build }

      it 'successfully calls the custom class method' do
        expect(subject).to eq('building..')
      end
    end

    context 'when a custom method name is used and attributes are initialized' do
      let(:test_class) do
        Class.new do
          include NxtSupport::Services::Base
          include NxtInit

          attr_init :test_string
          class_interface :build

          def build
            test_string
          end
        end
      end

      let(:test_string) { 'abc' }

      subject { test_class.build(test_string: test_string) }

      it 'successfully calls the custom class method with attributes' do
        expect(subject).to eq(test_string)
      end
    end

    context 'when a wrong value is given to the method' do
      let(:test_class) do
        Class.new do
          include NxtSupport::Services::Base

          class_interface 123
        end
      end

      subject { test_class.call }

      it 'raises an error' do
        expect { test_class.call }.to raise_error(ArgumentError)
          .with_message(/Wrong configuration. Please use 'class_interface :your_method_name'/)
      end
    end
  end
end
