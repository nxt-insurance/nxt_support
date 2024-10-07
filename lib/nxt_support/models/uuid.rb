module NxtSupport
  class Uuid
    REGEXP = /\A(\h{32}|\h{8}-\h{4}-\h{4}-\h{4}-\h{12})\z/
  end
end
