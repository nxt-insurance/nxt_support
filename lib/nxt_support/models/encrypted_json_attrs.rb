module NxtSupport
  module EncryptedJsonAttrs
    extend ActiveSupport::Concern

    class_methods do
      def encrypts_json_entirely(*attrs, default: -> { {}.with_indifferent_access }, **encryption_options)
        attrs.each do |attr|
          attribute attr, IndifferentJsonType.new, default: default
          encrypts attr, **encryption_options
        end
      end

      def encrypts_json_attrs(column:, paths:, deterministic: false, default: -> { {}.with_indifferent_access })
        attribute column, EncryptedJsonPathsType.new(*paths, deterministic: deterministic), default: default
      end

      def encrypted_json_value_for(attr, value)
        type_for_attribute(attr).encrypt_for_query(value)
      end

      def where_encrypted_json(attr, path:, value:)
        column = "#{quoted_table_name}.#{connection.quote_column_name(attr)}"
        matches = sanitize_sql_array(
          [
            "SELECT 1 FROM jsonb_path_query(#{column}, ?) AS match WHERE match #>> '{}' = ?",
            sql_json_path(path),
            encrypted_json_value_for(attr, value)
          ]
        )

        where("EXISTS (#{matches})")
      end

      private

      def sql_json_path(path)
        EncryptedJsonPathsType.normalize_path(path).gsub('..', '.**.')
      end
    end
  end
end
