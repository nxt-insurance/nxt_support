module NxtSupport
  class Iban
    require 'nxt_init'

    include NxtInit
    attr_init :iban

    def self.normalize(iban)
      new(iban: iban).normalize
    end

    def normalize
      return iban unless iban.is_a?(String)

      iban.upcase.gsub(/\s+/, '')
    end
  end
end
