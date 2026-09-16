require 'active_record'
require 'jsonpath'

module NxtSupport
  module RSpec
    module Encryption
      def raw_column_value(record, column)
        klass = record.class
        connection = klass.connection
        sql = klass.sanitize_sql_array(
          [
            "SELECT #{connection.quote_column_name(column)} FROM #{klass.quoted_table_name} " \
            "WHERE #{connection.quote_column_name(klass.primary_key)} = ?",
            record.id
          ]
        )

        connection.select_value(sql)
      end

      def be_encrypted
        BeEncrypted.new
      end

      def be_encrypted_at(path)
        BeEncryptedAt.new(path)
      end

      def self.envelope?(value)
        value.is_a?(::String) && ActiveRecord::Encryption.encryptor.encrypted?(value)
      end

      class BeEncrypted
        def matches?(actual)
          @actual = actual
          Encryption.envelope?(actual)
        end

        def failure_message
          "expected #{@actual.inspect} to be an Active Record encryption envelope"
        end

        def failure_message_when_negated
          "expected #{@actual.inspect} not to be an Active Record encryption envelope"
        end

        def description
          'be encrypted'
        end
      end

      class BeEncryptedAt
        def initialize(path)
          @path = path
        end

        def matches?(actual)
          resolve(actual)
          @leaves.any? && @leaves.all? { |leaf| Encryption.envelope?(leaf) }
        end

        def does_not_match?(actual)
          resolve(actual)
          @leaves.any? && @leaves.none? { |leaf| Encryption.envelope?(leaf) }
        end

        def failure_message
          return @parse_error if @parse_error
          return "expected #{@path} to match at least one leaf in #{@actual.inspect}, but it matched none" if @leaves.empty?

          plaintext = @leaves.reject { |leaf| Encryption.envelope?(leaf) }
          "expected every leaf at #{@path} to be an Active Record encryption envelope, but found #{plaintext.inspect}"
        end

        def failure_message_when_negated
          return @parse_error if @parse_error
          return "expected #{@path} to match at least one leaf in #{@actual.inspect}, but it matched none" if @leaves.empty?

          encrypted = @leaves.select { |leaf| Encryption.envelope?(leaf) }
          "expected no leaf at #{@path} to be an Active Record encryption envelope, but found #{encrypted.inspect}"
        end

        def description
          "be encrypted at #{@path}"
        end

        private

        def resolve(actual)
          @actual = actual
          @leaves = JsonPath.new(@path).on(parse(actual))
        rescue JSON::ParserError => error
          @parse_error = "expected #{actual.inspect} to be a JSON document, but it could not be parsed: #{error.message}"
          @leaves = []
        end

        def parse(actual)
          JSON.parse(actual.is_a?(::String) ? actual : actual.to_json)
        end
      end
    end
  end
end
