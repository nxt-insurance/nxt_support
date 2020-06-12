RSpec.describe NxtSupport::AssignableValues do
  describe 'A class with one column with assignable_values' do
    subject do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        include NxtSupport::AssignableValues

        assignable_values_for :genre do
          %w[action adventure comedy romance]
        end
      end
    end

    let!(:db_schema) do
      ActiveRecord::Schema.define do
        self.verbose = false

        create_table :movies, :force => true do |t|
          t.string :genre
          t.string :director
          t.string :title
        end
      end
    end

    context 'when a record is initialized' do
      let(:movie) { subject.new }

      it 'can return a list of valid values for an attribute' do
        expect(movie.valid_genres).to eq(%w[action adventure comedy romance])
      end
    end

    context 'when a record is initialized with a valid value' do
      let(:movie) { subject.new(genre: 'action') }

      it 'passes validation' do
        expect(movie.valid?).to be(true)
        expect(movie.errors).to be_empty
      end
    end

    context 'when a record is initialized with an invalid value' do
      let(:movie) { subject.new(genre: 'rock') }

      it 'fails validation' do
        expect(movie.valid?).to be_falsey
        expect(movie.errors[:genre].first).to eq('the value rock is not in the list of acceptable values')
      end
    end

    context 'when a record is initialized with no value' do
      let(:movie) { subject.new }

      it 'passes validation' do
        expect(movie.valid?).to be(true)
        expect(movie.errors).to be_empty
      end
    end

    context 'when a valid value is assigned after a record is initialized' do
      let(:movie) { subject.new }

      before do
        movie.genre = 'action'
      end

      it 'is valid' do
        expect(movie.valid?).to be(true)
        expect(movie.errors).to be_empty
      end
    end

    context 'when an invalid value is assigned after a record is initialized' do
      let(:movie) { subject.new }

      before do
        movie.genre = 'rock'
      end

      it 'fails validation' do
        expect(movie.valid?).to be_falsey
        expect(movie.errors[:genre].first).to eq('the value rock is not in the list of acceptable values')
      end
    end

    context 'when a record that already contains an invalid value is updated' do
      let(:movie) { subject.create(genre: subject.assignable_values[:genre][:values].first) }

      before do
        movie.update_column(:genre, 'country')
      end

      it 'passes validation and saves' do
        expect(movie.valid_genres).not_to include(movie.genre)
        expect(movie.valid?).to be(true)
        expect(movie.errors).to be_empty
        expect(movie.save!).to be(true)
      end
    end
  end

  describe 'A class with multiple columns with assignable_values' do
    subject do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        include NxtSupport::AssignableValues

        assignable_values_for :genre do
          %w[action adventure comedy romance]
        end

        assignable_values_for :director do
          %w[andy nils anthony scott]
        end
      end
    end

    let!(:db_schema) do
      ActiveRecord::Schema.define do
        self.verbose = false

        create_table :movies, :force => true do |t|
          t.string :genre
          t.string :director
          t.string :title
        end
      end
    end

    context 'when a record is initialized with both valid values' do
      let(:movie) { subject.new(genre: 'action', director: 'anthony') }

      it 'is valid' do
        expect(movie.valid?).to be(true)
        expect(movie.errors).to be_empty
      end
    end

    context 'when a record is initialized with an invalid value and a valid value' do
      let(:movie) { subject.new(genre: 'action', director: 'john') }

      it 'is not valid' do
        expect(movie.valid?).to be_falsey
        expect(movie.errors[:director].first).to eq('the value john is not in the list of acceptable values')
      end
    end
  end

  describe 'Multiple classes with assignable_values' do
    let!(:movie_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        include NxtSupport::AssignableValues

        assignable_values_for :genre do
          %w[action adventure comedy romance]
        end

        assignable_values_for :director do
          %w[andy nils anthony scott]
        end
      end
    end

    let!(:career_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'careers'
        include NxtSupport::AssignableValues

        assignable_values_for :industry do
          %w[tech agriculture media]
        end
      end
    end

    let!(:db_schema) do
      ActiveRecord::Schema.define do
        self.verbose = false

        create_table :movies, :force => true do |t|
          t.string :genre
          t.string :director
          t.string :title
        end

        create_table :careers, :force => true do |t|
          t.string :name
          t.string :industry
        end
      end
    end

    context 'when both records are initialized with a valid value' do
      let(:movie) { movie_class.new(genre: 'action', director: 'anthony') }
      let(:career) { career_class.new(industry: 'tech') }

      it 'is valid' do
        expect(movie.valid?).to be(true)
        expect(movie.errors).to be_empty

        expect(career.valid?).to be(true)
        expect(career.errors).to be_empty
      end
    end

    context 'when a record is initialized with an invalid value and a valid value' do
      let(:movie) { movie_class.new(genre: 'action', director: 'john') }
      let(:career) { career_class.new(industry: 'action') }

      it 'fails validation' do
        expect(movie.valid?).to be_falsey
        expect(movie.errors[:director].first).to eq('the value john is not in the list of acceptable values')

        expect(career.valid?).to be_falsey
        expect(career.errors[:industry].first).to eq('the value action is not in the list of acceptable values')
      end
    end

    context 'when both records already exist with invalid values' do
      let!(:movie) do
        movie = movie_class.new(genre: 'blue', director: 'poodles')
        movie.save(validate: false)
        movie
      end
      let!(:career) do
        career = career_class.new(industry: 'fake')
        career.save(validate: false)
        career
      end

      before do
        movie.title = 'Title'
        career.name = 'Software Developer'
      end

      it 'passes validation and saves' do
        expect(movie.valid?).to be(true)
        expect(movie.save).to be(true)

        expect(career.valid?).to be(true)
        expect(career.save).to be(true)
      end
    end
  end

  describe 'A class with default values' do
    let!(:valid_default_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        def self.name
          'Movie'
        end
        include NxtSupport::AssignableValues

        assignable_values_for :genre, default: 'comedy' do
          %w[action adventure comedy romance]
        end
      end
    end

    let!(:invalid_default_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        def self.name
          'Movie'
        end
        include NxtSupport::AssignableValues

        assignable_values_for :genre, default: 'rap' do
          %w[action adventure comedy romance]
        end
      end
    end

    let!(:db_schema) do
      ActiveRecord::Schema.define do
        self.verbose = false

        create_table :movies, :force => true do |t|
          t.string :genre
          t.string :director
          t.string :title
        end
      end
    end

    context 'with a valid default value' do
      context 'when the record is new and no value is given' do
        let(:movie) { valid_default_class.new }
        it 'assigns the default value and saves successfully' do
          expect(movie.genre).to eq(valid_default_class.assignable_values[:genre][:default])
          expect(movie.save).to be(true)
          expect(movie.reload.genre).to eq(valid_default_class.assignable_values[:genre][:default])
        end
      end

      context 'when the record is new and a genre is given' do
        let(:movie) { valid_default_class.new(genre: 'action') }
        it 'does not assign the default value' do
          expect(movie.genre).to_not eq(valid_default_class.assignable_values[:genre][:default])
          expect(movie.save).to be(true)
          expect(movie.reload.genre).to eq('action')
        end
      end

      context 'when a saved record is initialized with a genre' do
        let(:movie) { valid_default_class.create(genre: 'action') }
        it 'does not assign the default value' do
          expect(valid_default_class.find(movie.id).genre).to_not eq(valid_default_class.assignable_values[:genre][:default])
        end
      end

      context 'when a record is created without a genre' do
        let(:movie) { valid_default_class.create() }
        it 'assigns the default value to genre' do
          expect(valid_default_class.find(movie.id).genre).to eq(valid_default_class.assignable_values[:genre][:default])
        end
      end
    end

    context 'with an invalid default value' do
      let(:movie) { invalid_default_class.new }
      it 'assigns the default value and saves unsuccessfully' do
        expect(movie.genre).to eq(invalid_default_class.assignable_values[:genre][:default])
        expect(movie.save).to be(false)
      end
    end
  end
end
