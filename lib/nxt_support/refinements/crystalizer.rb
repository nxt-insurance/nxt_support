module NxtSupport
  module Refinements
    module Crystalizer
      refine Array do
        def crystalize(&block)
          ::NxtSupport::Crystalizer.new(collection: self, on_ambiguity: block).call
        end
      end
    end
  end
end
