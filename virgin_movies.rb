$LOAD_PATH  << File.expand_path(File.dirname(__FILE__) + '/lib')

require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-observer'
require 'dm-aggregates'
require 'open-uri'
require 'nokogiri'
gem     'twitter4r'
require 'twitter'
# require 'ruby-debug'

require 'twitter4r_hash_fix'
require 'film'
require 'film_observer'
require 'films_page'


