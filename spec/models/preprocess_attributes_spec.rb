RSpec.describe NxtSupport::PreprocessAttributes do
  before do
    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :movies, :force => true do |t|
        t.string :genre
        t.string :director
        t.string :title
      end
    end
  end

  subject do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'movies'
      include NxtSupport::PreprocessAttributes

      preprocess_attributes :genre, :director, preprocessors: %i[strip downcase]
      preprocess_attributes :title, preprocessors: %i[strip]
    end
  end

  context 'when a column has whitespace' do
    let(:movie) { subject.new(genre: '  comedy ') }

    it 'trims the whitespace after saving' do
      movie.save
      expect(movie.reload.genre).to eq('comedy')
    end
  end

  context 'when a column has uppercase values' do
    let(:movie) { subject.new(genre: 'COMEDY') }

    it 'saves the downcased value' do
      movie.save
      expect(movie.reload.genre).to eq('comedy')
    end
  end

  context 'when a column has uppercase values and whitespace' do
    let(:movie) { subject.new(genre: '  COMEDY ') }

    it 'saves the downcased and trimmed value' do
      movie.save
      expect(movie.reload.genre).to eq('comedy')
    end
  end

  context 'when two columns have uppercase values and whitespace' do
    let(:movie) { subject.new(genre: '  COMEDY ', director: ' Peter Jackson') }

    it 'saves the downcased and trimmed value' do
      movie.save
      expect(movie.reload.genre).to eq('comedy')
      expect(movie.reload.director).to eq('peter jackson')
    end
  end

  context 'when a column has a nil value' do
    let(:movie) { subject.new }

    it 'saves the record without changes' do
      movie.save
      expect(movie.reload.genre).to eq(nil)
      expect(movie.reload.director).to eq(nil)
    end
  end
end
