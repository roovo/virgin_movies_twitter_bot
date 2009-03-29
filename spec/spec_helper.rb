require 'rubygems'
require 'spec'
require 'fakeweb'

require File.expand_path(File.dirname(__FILE__) + '/../virgin_movies.rb')

FakeWeb.allow_net_connect = false

::TWITTER = "dummy_twitter"

database_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'db', 'test.db'))
DataMapper.setup(:default, "sqlite3://#{database_path}")

Film.auto_migrate!

Spec::Runner.configure do |config|
  config.after(:each) do
    repository(:default) do
      while repository.adapter.current_transaction
        repository.adapter.current_transaction.rollback
        repository.adapter.pop_transaction
      end
    end
  end
  config.before(:each) do
    repository(:default) do
      transaction = DataMapper::Transaction.new(repository)
      transaction.begin
      repository.adapter.push_transaction(transaction)
    end
  end
end