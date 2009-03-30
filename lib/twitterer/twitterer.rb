$LOAD_PATH  << File.expand_path(File.dirname(__FILE__) + '/lib')

require 'rubygems'
require 'logger'
gem     'twitter4r'
require 'twitter'

require 'twitter4r_hash_fix'
require 'logging_twitter'
