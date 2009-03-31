require 'rubygems'
require 'spec'
require 'fakeweb'

require File.expand_path(File.dirname(__FILE__) + '/../lib/virgin_movies/virgin_movies.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/twitterer/twitterer.rb')

FakeWeb.allow_net_connect = false

twitter_config = YAML::load_file(File.dirname(__FILE__) + '/../config/twitter_config.yml')
::TWITTER = LoggingTwitter.new(twitter_config.merge('log_file' => 'test_tweets'))

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
