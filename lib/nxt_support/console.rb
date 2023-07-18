# frozen_string_literal: true

module NxtSupport
  module Console
    # Better CLI arguments for Rake tasks, using Ruby's OptionParser
    # See https://docs.ruby-lang.org/en/2.1.0/OptionParser.html
    #
    # Example usage in a task:
    #
    #   task :my_task do
    #     opts = NxtSupport::Console.rake_cli_options do
    #       option '--simulate'
    #       option '--contract_numbers=', Array, default: []
    #       option '--limit=', Integer, default: 10
    #       option '--effective_at='
    #     end
    #
    #     p opts
    #   end
    #
    # On the CLI:
    #   rake my_task -- --simulate --contract_numbers=123,456 --effective_at=2022-01-02 --limit=20
    #
    # Results:
    #   {:contract_numbers=>["123", "456"], :simulate=>true, :effective_at=>"2022-01-02", :limit=>20}
    #
    # Note that the extra "--" must be passed after the task name and all Rake-specific flags.
    #
    # Also, only arguments which are supplied on the CLI or had defaults defined will be present in the returned hash
    #   rake my_task -- --effective_at=2022-10-13
    #   => {:limit=>10, :effective_at=>"2022-10-13", :contract_numbers=>[]}
    def rake_cli_options(argv = ARGV.dup, &option_definition_block)
      require 'optparse'

      argv.shift while argv.include?('--') # Remove task name and --
      options = {}

      OptionParser.new do |parser|
        parser.define_singleton_method(:option) do |switch, type = nil, default: nil|
          if default
            switch_name = switch.sub('--', '').sub('=', '')
            options[:"#{switch_name}"] = default
          end
          type ? def_option(switch, type) : def_option(switch)
        end
        parser.instance_eval(&option_definition_block)
      end.parse!(argv, into: options)

      options
    end

    module_function :rake_cli_options
  end
end
