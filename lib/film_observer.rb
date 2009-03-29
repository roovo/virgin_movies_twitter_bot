class FilmObserver
  include DataMapper::Observer

  observe Film

  after :create do
    return unless should_tweet?
    TWITTER.status(:post, tweet)
  end

  after :update do
    return unless should_tweet?
    TWITTER.status(:post, tweet)
  end
end