RSpec.describe NxtSupport::AssignableValues do
  let!(:db_schema) do
    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :movies, :force => true do |t|
        t.string :genre
        t.string :director
        t.string :title
        t.integer :views
      end

      create_table :careers, :force => true do |t|
        t.string :name
        t.string :industry
      end
    end
  end

  describe 'A class with assignable_values' do
    subject do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        include NxtSupport::AssignableValues

        assignable_values_for :genre do
          %w[action adventure comedy romance]
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
        expect(movie.errors[:genre].first).to eq('the value rock is not in the list of acceptable values.')
      end
    end

    context 'when a record is initialized with no value' do
      let(:movie) { subject.new }

      it 'fails validation' do
        expect(movie.valid?).to be(false)
        expect(movie.errors[:genre].first).to eq('can\'t be blank.')
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
        expect(movie.errors[:genre].first).to eq('the value rock is not in the list of acceptable values.')
      end
    end

    context 'when a record that already contains an invalid value is saved without changes' do
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

    context 'when a record that already contains an invalid value is updated with a different invalid value' do
      let(:movie) { subject.create(genre: subject.assignable_values[:genre][:values].first) }

      before do
        movie.update_column(:genre, 'country')
        movie.genre = 'rock'
      end

      it 'fails validation' do
        expect(movie.valid_genres).not_to include(movie.genre)
        expect(movie.valid?).to be(false)
        expect(movie.errors[:genre].first).to eq('the value rock is not in the list of acceptable values.')
      end
    end

    context 'when a record that already contains a valid value is updated with an invalid value' do
      let(:movie) { subject.create(genre: subject.assignable_values[:genre][:values].first) }

      before do
        movie.genre = 'rock'
      end

      it 'fails validation' do
        expect(movie.valid?).to be(false)
        expect(movie.errors[:genre].first).to eq('the value rock is not in the list of acceptable values.')
      end
    end

    context 'when a record that already contains a valid value is updated with a blank value' do
      let(:movie) { subject.create(genre: subject.assignable_values[:genre][:values].first) }

      before do
        movie.genre = nil
      end

      it 'fails validation' do
        expect(movie.valid?).to be(false)
        expect(movie.errors[:genre].first).to eq('can\'t be blank.')
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

        assignable_values_for :director, %w[andy nils anthony scott]
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
        expect(movie.errors[:director].first).to eq('the value john is not in the list of acceptable values.')
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

    it 'has the correct configuration for each class' do
      expect(movie_class.assignable_values[:genre]).to eq(
        {
          values: %w[action adventure comedy romance],
          allow_blank: nil,
          default: nil
        }
      )
      expect(career_class.assignable_values).to eq(
        {
          industry: {
            values: %w[tech agriculture media],
            allow_blank: nil,
            default: nil
          }
        }
      )
    end

    context 'when records are initialized from both classes' do
      let(:movie) { movie_class.new(genre: 'action', director: 'anthony') }
      let(:career) { career_class.new(industry: 'tech') }

      it 'has the correct list of valid values' do
        expect(movie.valid_genres).to eq(%w[action adventure comedy romance])
        expect(career.valid_industries).to eq(%w[tech agriculture media])
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

        assignable_values_for :director, default: proc { genre == 'action' ? 'andy' : 'nils' } do
          %w[andy nils anthony scott]
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

    context 'with a proc' do
      let(:movie) { valid_default_class.new(genre: 'action') }
      it 'evaluates the proc and assigns the default value' do
        expect(movie.director).to eq('andy')
      end
    end
  end

  describe 'A class that allows blank values' do
    let!(:allow_blank_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'movies'
        def self.name
          'Movie'
        end
        include NxtSupport::AssignableValues

        assignable_values_for :genre, allow_blank: true do
          %w[action adventure comedy romance]
        end
      end
    end

    context 'when a record is initialized with no value' do
      let(:movie) { allow_blank_class.new }

      it 'passes validation' do
        expect(movie.valid?).to be(true)
        expect(movie.errors).to be_empty
      end
    end

    context 'when a record exists and the value is changed to nil' do
      let(:movie) { allow_blank_class.create(genre: 'action') }

      it 'passes validation' do
        movie.genre = nil
        expect(movie.valid?).to be(true)
      end
    end
  end
end
