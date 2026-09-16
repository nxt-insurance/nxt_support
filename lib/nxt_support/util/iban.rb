module NxtSupport
  class Iban
    require 'nxt_init'

    include NxtInit
    attr_init :iban

    COUNTRY_CODE_LENGTH = 2
    VISIBLE_CHARACTERS = 4
    MASK = '****'.freeze

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
      to_s.first(COUNTRY_CODE_LENGTH).presence
    end

    def last4
      to_s.last(VISIBLE_CHARACTERS).presence
    end

    def redacted_s
      normalized = to_s

      return '' if normalized.empty?
      return "#{country_code}#{MASK}" if normalized.length <= COUNTRY_CODE_LENGTH + VISIBLE_CHARACTERS

      "#{country_code}#{MASK}#{last4}"
    end
  end
end
