RSpec.describe NxtSupport::Service do
  let(:test_class) do
    Class.new do
      include NxtSupport::Service
      attr_init :test_string
      class_interface call: :build

      def build
        test_string
      end
    end
  end

  let(:test_string) { 'test' }

  subject { test_class.call(test_string: test_string) }

  it do
    expect(subject).to eq(test_string)
  end
end
