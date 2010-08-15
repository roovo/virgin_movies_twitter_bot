class FilmObserver
  include DataMapper::Observer

  observe Film

  after :create do
    return unless should_tweet?
    #puts "CREATE: " + tweet
    ::TWITTER.update(tweet)
  end

  after :update do
    return unless should_tweet?
    #puts "UPDATE: " + tweet
    ::TWITTER.update(tweet)
  end
end
