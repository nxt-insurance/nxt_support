RSpec.describe NxtSupport::Services::ClassMethods do
  context 'when #call is used by default' do
    context 'when no attributes are initialized' do
      let(:test_class) do
        Class.new do
          include NxtSupport::Services::ClassMethods
          def call
            'hello there'
          end
        end
      end

      subject { test_class.call }

      it do
        expect(subject).to eq('hello there')
      end
    end

    context 'when some attributes are initialized with NxtInit' do
      let(:test_class) do
        Class.new do
          include NxtSupport::Services::ClassMethods
          include NxtInit

          attr_init :test_string

          def call
            test_string
          end
        end
      end

      let(:test_string) { 'abc' }

      subject { test_class.call(test_string: test_string) }

      it do
        expect(subject).to eq(test_string)
      end
    end
  end

  context 'when a custom method name is used' do
    context 'when no attributes are initialized' do
      let(:test_class) do
        Class.new do
          include NxtSupport::Services::ClassMethods

          class_interface call: :build

          def build
            'building..'
          end
        end
      end

      subject { test_class.build }

      it do
        expect(subject).to eq('building..')
      end
    end

    context 'when some attributes are initialized with NxtInit' do
      let(:test_class) do
        Class.new do
          include NxtSupport::Services::ClassMethods
          include NxtInit

          attr_init :test_string
          class_interface call: :build

          def build
            test_string
          end
        end
      end

      let(:test_string) { 'abc' }

      subject { test_class.build(test_string: test_string) }

      it do
        expect(subject).to eq(test_string)
      end
    end
  end
end
