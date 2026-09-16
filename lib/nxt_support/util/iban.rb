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

    def to_s
      normalize.to_s
    end

    def country_code
      to_s.first(2).presence
    end

    def last4
      to_s.last(4).presence
    end
  end
end
