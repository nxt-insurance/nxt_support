RSpec.describe NxtSupport::SafelyFindOrCreateable do
  subject do
    Class.new(ActiveRecord::Base) do
      include NxtSupport::SafelyFindOrCreateable

      self.table_name = 'entries'
    end
  end

  let!(:db_schema) do
    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :entries, :force => true do |t|
        t.string :unique_column
        t.index :unique_column, unique: true
      end
    end
  end

  describe '::safely_find_or_create_by' do
    context 'when the column value is taken already' do
      let!(:taken_record) { subject.create!(unique_column: 'moch') }

      it 'returns the taken record' do
        expect(subject.safely_find_or_create_by(unique_column: 'moch')).to eq taken_record
      end

      it 'does not create a new record' do
        expect { subject.safely_find_or_create_by(unique_column: 'moch') }.not_to change { subject.count }
      end
    end

    context 'when the column value is free' do
      it 'creates a new record' do
        expect { subject.safely_find_or_create_by(unique_column: 'moch') }.to change { subject.count }.from(0).to(1)
      end

      context 'and an insert happens after the find but before the create' do
        let!(:taken_record) { subject.create!(unique_column: 'moch') }

        before do
          allow(subject).to receive(:create).and_raise(ActiveRecord::RecordNotUnique)
        end

        it 'returns the taken record' do
          expect(subject.safely_find_or_create_by(unique_column: 'moch')).to eq taken_record
        end

        it 'does not raise an error' do
          expect { subject.safely_find_or_create_by(unique_column: 'moch') }.not_to raise_error
        end
      end
    end
  end

  describe '::safely_find_or_create_by!' do
    context 'when the column value is taken already' do
      let!(:taken_record) { subject.create!(unique_column: 'moch') }

      it 'returns the taken record' do
        expect(subject.safely_find_or_create_by!(unique_column: 'moch')).to eq taken_record
      end

      it 'does not create a new record' do
        expect { subject.safely_find_or_create_by!(unique_column: 'moch') }.not_to change { subject.count }
      end
    end

    context 'when the column value is free' do
      it 'creates a new record' do
        expect { subject.safely_find_or_create_by!(unique_column: 'moch') }.to change { subject.count }.from(0).to(1)
      end

      context 'and an insert happens after the find but before the create' do
        let!(:taken_record) { subject.create!(unique_column: 'moch') }

        before do
          allow(subject).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique)
        end

        it 'returns the taken record' do
          expect(subject.safely_find_or_create_by!(unique_column: 'moch')).to eq taken_record
        end

        it 'does not raise an error' do
          expect { subject.safely_find_or_create_by!(unique_column: 'moch') }.not_to raise_error
        end
      end
    end
  end
end
