require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')
require 'net/http'

describe "re-loading of same data" do
  
  before(:each) do
    @log_path = File.expand_path(File.dirname(__FILE__) + '/../log/test_tweets.log')
    FakeWeb.register_uri( 'http://moviesondemand.virginmedia.com/movies/groups/newreleases/', 
                          :file => File.join(File.dirname(__FILE__), 'pages', 'new_releases.html'))
    FakeWeb.register_uri( 'http://moviesondemand.virginmedia.com/movies/tropicthunder/', 
                          :file => File.join(File.dirname(__FILE__), 'pages', 'tropic_thunder.html'))
    FakeWeb.register_uri( 'http://moviesondemand.virginmedia.com/movies/tropicthunderthedirectorscut/', 
                          :file => File.join(File.dirname(__FILE__), 'pages', 'tropic_thunder_directors.html'))
    FakeWeb.register_uri( 'http://moviesondemand.virginmedia.com/movies/taken/', 
                          :file => File.join(File.dirname(__FILE__), 'pages', 'taken.html'))
    FakeWeb.register_uri(:post, 'https://twitter.com:443/statuses/update.json',
                          :status => [ 404, "Not Found" ])
  end
  
  it "should NOT re-twitter anything if nothing's changed" do
    new_releases_page     = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/newreleases/')
    films = []
    films += new_releases_page.films
    Film.process_films(films)  
    log_file = File.new(@log_path)
    before_log_file_text = log_file.read
    log_file.close
    films = []
    films += new_releases_page.films
    Film.process_films(films)  
    log_file = File.new(@log_path)
    after_log_file_text = log_file.read
    log_file.close
    after_log_file_text.should == before_log_file_text
  end
  
  it "should pass on the tweets to Twitter::Client if logging is disabled" do
    twitter_config = YAML::load_file(File.dirname(__FILE__) + '/../config/twitter_config.yml')
    ::TWITTER = LoggingTwitter.new(twitter_config.merge('log_file' => nil))
    new_releases_page     = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/newreleases/')
    films = []
    films += new_releases_page.films
    lambda { Film.process_films(films) }.should raise_error(Twitter::RESTError)
  end
end
