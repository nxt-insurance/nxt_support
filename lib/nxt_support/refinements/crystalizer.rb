module NxtSupport
  module Refinements
    module Crystalizer
      #
      # For ruby versions < 3.0, refining a module that is already included isn't possible.
      #
      _refined_module_or_class = Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.0.0') ? Array : Enumerable

      refine _refined_module_or_class do
        def crystalize(&block)
          ::NxtSupport::Crystalizer.new(collection: self, on_ambiguity: block).call
        end
      end
    end
  end
end
