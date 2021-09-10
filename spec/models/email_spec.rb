RSpec.describe NxtSupport::Email do
  describe '::REGEXP' do
    subject { NxtSupport::Email::REGEXP }

    let(:valid_emails) do
      %w[john.doe@example.org john@example.co.uk john@ex-ample.org a@b.c]
    end

    let(:invalid_emails) do
      ['john doe@example.org', 'john@.example.org', 'john@example', 'john@example..org', 'john@example.org.', 'john@.example.org']
    end

    it 'matches valid emails' do
      valid_emails.each do |valid_email|
        expect(subject).to match valid_email
      end
    end

    it 'does not match invalid emails' do
      invalid_emails.each do |invalid_email|
        expect(subject).not_to match invalid_email
      end
    end
  end
end
