RSpec.describe NxtSupport::IndifferentlyAccessibleJsonAttrs do
  subject do
    klass = Class.new(ActiveRecord::Base) do
      include NxtSupport::IndifferentlyAccessibleJsonAttrs

      self.table_name = 'snapshots'

      indifferently_accessible_json_attrs :data, :meta_data
    end

    klass.new
  end

  let!(:db_schema) do
    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :snapshots, :force => true do |t|
        t.json :data
        t.json :meta_data
      end
    end
  end

  context 'when a hash is assigned' do
    context 'when not persisted' do
      it do
        expect(subject).to_not be_changed
        subject.data = { 'ruby' => 'is awesome' }

        expect(subject.data[:ruby]).to eq('is awesome')
        expect(subject.data['ruby']).to eq('is awesome')
      end
    end

    context 'when persisted' do
      before do
        subject.data = { 'ruby' => 'is awesome' }
        subject.save!
      end

      it do
        expect(subject.changed?).to be_falsey
        expect(subject.data[:ruby]).to eq('is awesome')
        expect(subject.data['ruby']).to eq('is awesome')
      end
    end
  end

  context 'when a indifferently accessible hash is assigned' do
    context 'when persisted' do
      before do
        subject.data = { 'ruby' => 'is awesome' }.with_indifferent_access
        subject.save!
      end

      it do
        expect(subject).to_not be_changed

        expect(subject.data[:ruby]).to eq('is awesome')
        expect(subject.data['ruby']).to eq('is awesome')
      end
    end

    context 'when not persisted' do
      it do
        expect(subject).to_not be_changed
        subject.data = { 'ruby' => 'is awesome' }.with_indifferent_access

        expect(subject.data[:ruby]).to eq('is awesome')
        expect(subject.data['ruby']).to eq('is awesome')
      end
    end
  end

  context 'when an array is assigned' do
    context 'when persisted' do
      before do
        subject.meta_data = [{ 'ruby' => 'is awesome' }, { javascript: 'is ok'} ]
        subject.save!
      end

      it do
        expect(subject).to_not be_changed
        expect(subject.meta_data.first[:ruby]).to eq('is awesome')
        expect(subject.meta_data.first['ruby']).to eq('is awesome')
        expect(subject.meta_data.second['javascript']).to eq('is ok')
        expect(subject.meta_data.second[:javascript]).to eq('is ok')
      end
    end

    context 'when not persisted' do
      it do
        expect(subject).to_not be_changed
        subject.meta_data = [{ 'ruby' => 'is awesome' }, { javascript: 'is ok'} ]

        expect(subject.meta_data.first[:ruby]).to eq('is awesome')
        expect(subject.meta_data.first['ruby']).to eq('is awesome')
        expect(subject.meta_data.second['javascript']).to eq('is ok')
        expect(subject.meta_data.second[:javascript]).to eq('is ok')
      end
    end
  end

  context 'when an array that contains indifferently accessible hashes is assigned' do
    context 'when persisted' do
      before do
        subject.meta_data = [{ 'ruby' => 'is awesome' }.with_indifferent_access, { javascript: 'is ok'} ]
        subject.save!
      end

      it do
        expect(subject).to_not be_changed
        expect(subject.meta_data.first[:ruby]).to eq('is awesome')
        expect(subject.meta_data.first['ruby']).to eq('is awesome')
        expect(subject.meta_data.second['javascript']).to eq('is ok')
        expect(subject.meta_data.second[:javascript]).to eq('is ok')
      end
    end

    context 'when not persisted' do
      it do
        subject.meta_data = [{ 'ruby' => 'is awesome' }.with_indifferent_access, { javascript: 'is ok'} ]

        expect(subject.meta_data.first[:ruby]).to eq('is awesome')
        expect(subject.meta_data.first['ruby']).to eq('is awesome')
        expect(subject.meta_data.second['javascript']).to eq('is ok')
        expect(subject.meta_data.second[:javascript]).to eq('is ok')
      end
    end
  end

  context 'when nil is assigned' do
    it do
      subject.data = nil
      expect(subject.data).to be_nil
      expect(subject.changed?).to be_falsey
    end
  end

  context 'when nothing is assigned' do
    it do
      expect(subject.changed?).to be_falsey
    end
  end
end
