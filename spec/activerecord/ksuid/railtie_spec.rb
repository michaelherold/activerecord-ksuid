# frozen_string_literal: true

require 'rails'
require 'active_record'
require 'logger'

require 'activerecord/ksuid'
require 'active_record/ksuid/railtie'

ActiveRecord::Base.establish_connection(
  adapter: ENV.fetch('DRIVER'),
  host: ENV['DB_HOST'],
  username: ENV['DB_USERNAME'],
  database: ENV.fetch('DATABASE', 'activerecord-ksuid_test')
)
ActiveRecord::Base.logger = Logger.new(IO::NULL)
ActiveRecord::Schema.verbose = false

# Bootstrap the railtie without booting a Rails app
ActiveRecord::KSUID::Railtie.initializers.each(&:run)
ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)

ActiveRecord::Schema.define do
  create_table :events, force: true do |t|
    t.string :ksuid, index: true, unique: true
  end

  create_table :event_primary_keys, force: true, id: false do |t|
    t.ksuid :id, primary_key: true
  end

  create_table :event_binaries, force: true, id: false do |t|
    t.ksuid_binary :id, primary_key: true
  end

  create_table :event_correlations, force: true do |t|
    t.references :from, type: :string, limit: 27, foreign_key: { to_table: :event_primary_keys }
    t.references :to, type: :string, limit: 27, foreign_key: { to_table: :event_primary_keys }
  end

  create_table :event_binary_correlations, force: true do |t|
    t.references :from, type: :binary, limit: 20, foreign_key: { to_table: :event_binaries }
    t.references :to, type: :binary, limit: 20, foreign_key: { to_table: :event_binaries }
  end
end

# A demonstration model for testing ActiveRecord::KSUID
class Event < ActiveRecord::Base
  include ActiveRecord::KSUID[:ksuid, created_at: true]
end

# A demonstration of KSUIDs as the primary key on a record
class EventPrimaryKey < ActiveRecord::Base
  include ActiveRecord::KSUID[:id]
end

# A demonstration of KSUIDs persisted as binaries
class EventBinary < ActiveRecord::Base
  include ActiveRecord::KSUID[:id, binary: true]
end

# A demonstration of a relation to a string KSUID primary key
class EventCorrelation < ActiveRecord::Base
  include ActiveRecord::KSUID[:from_id]
  include ActiveRecord::KSUID[:to_id]

  belongs_to :from, class_name: 'EventPrimaryKey'
  belongs_to :to, class_name: 'EventPrimaryKey'
end

# A demonstration of a relation to a binary KSUID primary key
class EventBinaryCorrelation < ActiveRecord::Base
  include ActiveRecord::KSUID[:from_id, binary: true]
  include ActiveRecord::KSUID[:to_id, binary: true]

  belongs_to :from, class_name: 'EventBinary'
  belongs_to :to, class_name: 'EventBinary'
end

RSpec.describe 'ActiveRecord integration' do
  context 'with a non-primary field as the KSUID' do
    after { Event.delete_all }

    it 'generates a KSUID upon initialization' do
      event = Event.new

      expect(event.ksuid).to be_a(::KSUID::Type)
    end

    it 'restores a KSUID from the database' do
      ksuid = Event.create!.ksuid
      event = Event.last

      expect(event.ksuid).to eq(ksuid)
    end

    it 'can be used as a timestamp for the created_at' do
      event = Event.create!

      expect(event.created_at).not_to be_nil
    end

    it 'can be looked up via a string, byte array, or KSUID' do
      id = ::KSUID.new
      event = Event.create!(ksuid: id)

      expect(Event.find_by(ksuid: id.to_s)).to eq(event)
      expect(Event.find_by(ksuid: id.to_bytes)).to eq(event)
      expect(Event.find_by(ksuid: id)).to eq(event)
    end
  end

  context 'with a primary key field as the KSUID' do
    after { EventPrimaryKey.delete_all }

    it 'generates a KSUID upon initialization' do
      event = EventPrimaryKey.new

      expect(event.id).to be_a(::KSUID::Type)
    end
  end

  context 'with a binary KSUID field' do
    after { EventBinary.delete_all }

    it 'generates a KSUID upon initialization' do
      event = EventBinary.new

      expect(event.id).to be_a(::KSUID::Type)
    end

    it 'persists the KSUID to the database' do
      event = EventBinary.create

      expect(event.id).to be_a(::KSUID::Type)
    end
  end

  context 'with a reference to string KSUID-keyed tables' do
    after do
      EventCorrelation.delete_all
      EventPrimaryKey.delete_all
    end

    it 'can relate to the other model' do
      event1 = EventPrimaryKey.create!
      event2 = EventPrimaryKey.create!
      correlation = EventCorrelation.create!(from: event1, to: event2)

      correlation.reload

      aggregate_failures do
        expect(correlation.from).to eq event1
        expect(correlation.to).to eq event2
      end
    end
  end

  context 'with a reference to binary KSUID-keyed tables' do
    after do
      EventBinaryCorrelation.delete_all
      EventBinary.delete_all
    end

    it 'can relate to the other model' do
      event1 = EventBinary.create!
      event2 = EventBinary.create!
      correlation = EventBinaryCorrelation.create!(from: event1, to: event2)

      correlation.reload

      aggregate_failures do
        expect(correlation.from).to eq event1
        expect(correlation.to).to eq event2
      end
    end
  end
end
