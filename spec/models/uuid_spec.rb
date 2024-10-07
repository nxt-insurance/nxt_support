RSpec.describe NxtSupport::Uuid, aggregate_failures: true do
  describe '::REGEXP' do
    subject { NxtSupport::Uuid::REGEXP }

    let(:valid_uuids) do
      %w(
        e78edff6-11cc-4308-9b9e-ee81afc0f0a2
        3d6aa0d0-c53f-42bb-a71d-aca7da47863b
        9FE1721F-DF1E-4FDB-838F-12E4986709BF
      )
    end

    let(:invalid_uuids) do
      %w(
        e78edff611cc43089b9ee81afc0f0a2
        fd79ba5d-a0da-4aa2-b2d4-8e599$388bc2
        e78edff6-11cc-4308-9b9e-ee81afc0f0a
        9FE1721F-DF1E-4FDB-838F-12E4986709B
      )
    end

    it 'matches valid uuids' do
      valid_uuids.each do |valid_uuid|
        expect(subject).to match valid_uuid
      end
    end

    it 'does not match invalid uuids' do
      invalid_uuids.each do |invalid_uuid|
        expect(subject).not_to match invalid_uuid
      end
    end
  end
end
