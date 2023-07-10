module NxtSupport
  class Email
    # We enforce
    #  (1) Exactly one '@' char prepended and appended by other text
    #  (2) No whitespace characters
    #  (3) At least one non-whitespace character before the '@' character
    #  (4) No dot ('.') character directly after the '@' character
    #  (5) A hostname after the '@' character of at least one non-whitespace characters length
    #  (6) At least one top level domain ending (e.g. '.com') after the hostname, separated from the hostname by a dot ('.')
    REGEXP = /\A[^@\s]+@([^.@\s]+\.)+[^.^@\s]+\z/.freeze
  end
end
