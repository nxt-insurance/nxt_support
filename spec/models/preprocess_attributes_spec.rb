RSpec.describe NxtSupport::PreprocessAttributes do
  before :all do
    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :movies, :force => true do |t|
        t.string :genre
        t.string :director
        t.string :title
        t.integer :views
      end
    end

    class Movie < ActiveRecord::Base
      include NxtSupport::PreprocessAttributes
      preprocess_attributes :genre, :director, preprocessors: %i[strip downcase]
    end
  end

  context 'when a column has whitespace' do
    let(:movie) { Movie.new(genre: '  comedy ') }

    it 'trims the whitespace after saving' do
      movie.save
      expect(movie.reload.genre).to eq('comedy')
    end
  end

  context 'when a column has uppercase values' do
    let(:movie) { Movie.new(genre: 'COMEDY') }

    it 'saves the downcased value' do
      movie.save
      expect(movie.reload.genre).to eq('comedy')
    end
  end

  context 'when a column has uppercase values and whitespace' do
    let(:movie) { Movie.new(genre: '  COMEDY ') }

    it 'saves the downcased and trimmed value' do
      movie.save
      expect(movie.reload.genre).to eq('comedy')
    end
  end

  context 'when two columns have uppercase values and whitespace' do
    let(:movie) { Movie.new(genre: '  COMEDY ', director: ' Peter Jackson') }

    it 'saves the downcased and trimmed value' do
      movie.save
      expect(movie.reload.genre).to eq('comedy')
      expect(movie.reload.director).to eq('peter jackson')
    end
  end

  context 'when a column has a nil value' do
    let(:movie) { Movie.new }

    it 'saves the record without changes' do
      movie.save
      expect(movie.reload.genre).to eq(nil)
      expect(movie.reload.director).to eq(nil)
    end
  end

  context 'registering a new preprocesser' do
    before do
      class CompressPreprocessor
        attr_accessor :value

        def initialize(value)
          @value = value
        end

        def call
          return value unless value.is_a?(String)

          value.squeeze!(' ')
          value
        end
      end

      NxtSupport::Preprocessor.register(:compress, CompressPreprocessor)
    end

    let!(:movie_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        include NxtSupport::PreprocessAttributes

        preprocess_attributes :director, preprocessors: %i[strip downcase compress]
      end
    end

    let(:movie) { movie_class.create(director: 'Peter     Jackson') }
    it 'makes the newly registered preprocesser available' do
      expect(movie.reload.director).to eq('peter jackson')
    end
  end

  context 'with a lambda' do
    let!(:movie_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        include NxtSupport::PreprocessAttributes
        preprocess_attributes :director, preprocessors: [:strip, :downcase, ->(value) { value + ' is a director' if value }]
      end
    end

    let(:movie) { movie_class.create(director: ' Peter Jackson ') }
    it 'uses the lamba as a preprocessor' do
      expect(movie.reload.director).to eq('peter jackson is a director')
    end
  end

  context 'with an integer' do
    before do
      class AddOnePreprocessor
        attr_accessor :value

        def initialize(value)
          @value = value
        end

        def call
          return value if value.nil?

          value = self.value + 1
          value
        end
      end

      NxtSupport::Preprocessor.register(:add_one, AddOnePreprocessor, :integer)
    end

    let!(:movie_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        include NxtSupport::PreprocessAttributes
        preprocess_attributes :views, preprocessors: [:add_one], column_type: :integer
      end
    end

    let(:movie) { movie_class.create(views: 1000) }
    it 'uses the registered preprocessor' do
      expect(movie.reload.views).to eq(1001)
    end
  end

  context 'with an incorrect type' do
    let!(:movie_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        include NxtSupport::PreprocessAttributes
        preprocess_attributes :views, preprocessors: [:downcase]
      end
    end

    let(:movie) { movie_class.create(views: 1000) }
    it 'uses raises an error' do
      expect { movie }.to raise_error(NxtSupport::Preprocessors::WrongTypeError)
    end
  end

  context 'with no preprocessors provided' do
    let(:movie_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        include NxtSupport::PreprocessAttributes
        preprocess_attributes :views
      end
    end

    it 'raises an error' do
      expect { movie_class }.to raise_error(ArgumentError)
    end
  end
end
