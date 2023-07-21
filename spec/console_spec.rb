require 'rake'

describe NxtSupport::Console do
  describe '.rake_cli_options' do
    subject do |example|
      @opts = nil
      argv = ["test_task_#{example.object_id}", "--silent", "--", *option_string.split(' ')]
      Rake::Task.define_task "test_task_#{example.object_id}" do
        @opts = NxtSupport::Console.rake_cli_options(argv, &option_definition_block)
      end

      Rake.application.run(argv)
      @opts
    end

    let(:option_definition_block) do
      proc do
        option '--simulate'
        option '--contract_numbers=', Array
        option '--limit=', Integer, default: 10
        option '--effective_at='
      end
    end

    context 'when correct options are passed' do
      let(:option_string) do
        '--simulate --contract_numbers=123,456 --effective_at=2022-01-02 --limit=20'
      end

      it 'parses CLI options correctly' do
        expect(subject).to eq(
          {
            simulate: true,
            contract_numbers: %w[123 456],
            effective_at: '2022-01-02',
            limit: 20,
          }
        )
      end
    end

    context 'when some options are not passed' do
      let(:option_string) do
        '--contract_numbers=123,456'
      end

      it 'falls back to default if specified, or does not include the option, if no default' do
        expect(subject).to eq(
          {
            contract_numbers: %w[123 456],
            limit: 10,
          }
        )
      end
    end

    context 'when no options are passed' do
      let(:option_string) { ' ' }

      it 'returns only defaults' do
        expect(subject).to eq(
          {
            limit: 10,
          }
        )
      end
    end

    context 'when unknown options are passed' do
      let(:option_string) do
        '--simulate --extra-arg=4'
      end

      it 'raises an error' do
        expect { subject }.to raise_error(SystemExit) do |e|
          expect(e.cause).to be_an(OptionParser::InvalidOption)
          expect(e.cause.message).to match(/invalid option: --extra-arg/)
        end
      end
    end

    context 'when wrong data types are passed' do
      let(:option_string) do
        '--simulate=123,456 --effective_at=2022-01-02 --limit=20'
      end

      it 'raises an error' do
        expect { subject }.to raise_error(SystemExit) do |e|
          expect(e.cause).to be_an(OptionParser::NeedlessArgument)
          expect(e.cause.message).to match(/needless argument: --simulate=123,456/)
        end
      end
    end
  end
end
