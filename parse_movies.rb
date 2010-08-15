#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'

Bundler.setup

require File.expand_path(File.dirname(__FILE__) + '/lib/virgin_movies/virgin_movies.rb')
require File.expand_path(File.dirname(__FILE__) + '/lib/twitterer/twitterer.rb')

# setup database
database_path = File.expand_path(File.join(File.dirname(__FILE__), 'db', 'virgin_movies.db'))
DataMapper.setup(:default, "sqlite3://#{database_path}")
begin
  response = repository(:default).adapter.query("SELECT id FROM films LIMIT 1")
rescue Exception => e
  Film.auto_migrate!
end

# setup twitter
config = ConfigStore.new(File.dirname(__FILE__) + '/config/twitter_config.yml')

oauth = Twitter::OAuth.new(config['consumer_token'], config['consumer_secret'])
oauth.authorize_from_access(config['access_token'], config['access_secret'])

::TWITTER = Twitter::Base.new(oauth)

# do ya thing ya robo-scraping-tweeter-doode
#coming_soon_page      = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/comingsoon/')
new_releases_page     = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/new_releases/')
last_chance_page      = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/last_chance_to_see/')
special_offers_page   = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/special_offers/')

films = []
#films += coming_soon_page.films
films += new_releases_page.films
films += last_chance_page.films
films += special_offers_page.films

#films.each { |f| puts f.inspect }

Film.process_films(films)
