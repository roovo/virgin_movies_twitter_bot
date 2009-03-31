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
twitter_config = YAML::load_file(File.dirname(__FILE__) + '/config/twitter_config.yml')
::TWITTER = LoggingTwitter.new(twitter_config)

# do ya thing ya robo-scraping-tweeter-doode
coming_soon_page      = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/comingsoon/')
new_releases_page     = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/newreleases/')
last_chance_page      = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/lastchancetosee/')
special_offers_page   = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/specialoffers/')

films = []
films += coming_soon_page.films
films += new_releases_page.films
films += last_chance_page.films
films += special_offers_page.films

Film.process_films(films)