class Film
  include DataMapper::Resource
  
  FILMS_EXPIRE_AFTER_DAYS = 60

  property  :id,            Serial
  property  :title,         String,       :length => 255,       :nullable => false
  property  :tag_line,      String,       :length => 255
  property  :url,           String,       :length => 255,       :nullable => false
  property  :special_offer, String,       :length => 255,       :default => ""
  property  :genre,         String
  property  :price,         String,       :nullable => false
  property  :certificate,   String,       :nullable => false
  property  :year,          String,       :nullable => false
  property  :from,          String,       :nullable => false
  property  :to,            String
  property  :created_on,    Date
  
  def self.process_films(attributes_of_films)
    processed_films = create_or_update_films(attributes_of_films)
    remove_expired_films(processed_films)
  end
  
  def self.create_or_update_films(attributes_of_films)
    processed_films = []
    attributes_of_films.each do |film_attributes|
      processed_films << Film.create_or_update(film_attributes)
    end
    processed_films
  end
  
  def self.create_or_update(film_attributes)
    existing = Film.first(:url => film_attributes[:url])
    if existing
      existing.update_attributes(film_attributes)
      existing
    else
      Film.create(film_attributes)
    end
  end
  
  def self.remove_expired_films(processed_films)
    processed_ids = processed_films.map { |f| f.id }
    Film.all(:id.not => processed_ids, :created_on.lt => Date.today - FILMS_EXPIRE_AFTER_DAYS).destroy!
  end

  def should_tweet?
    dirty_attributes.size > 0 && !(only_a_days_left_update? || zero_days_left?)
  end
  
  def tweet
    truncate(text_for_tweet, :length => 140)
  end

private

  def only_a_days_left_update?
    dirty_attributes.size == 1 && attribute_dirty?(:from) && /days left$/.match(original_values[:from]) && /days left$/.match(from)
  end
  
  def zero_days_left?
    /^(\d) days left$/.match(from) && $1.to_i == 0
  end

  def text_for_tweet
    special_offer_tweet? ? special_offer_text : regular_movie_text
  end

  def special_offer_tweet?
    attribute_dirty?(:special_offer) && !special_offer.blank?
  end
  
  def regular_movie_text
    case from
    when "Now showing"
      "[Available Now]"
    when /^.*left$/
      "[Last Chance: #{from}]"
    else
      "[From #{from}]"
    end << " #{title} (#{certificate}, #{year}, #{price}) #{genre}. #{tag_line}"
  end
  
  def special_offer_text
    /^.*Available for (.*) from (.*) to (.*)/.match(special_offer)
    "[Special Offer: #{special_offer_date_span($2, $3)} @ #{$1}] #{title} (#{certificate}, #{year}) #{genre}. #{tag_line}"
  end
  
  def special_offer_date_span(from, to)
    first = Date.parse(to_parseable_date(from))
    last  = Date.parse(to_parseable_date(to))
    
    arr   = [first.strftime('%b %d')]
    arr   << ' - '
    arr   << last.strftime('%b') << ' ' unless first.month == last.month
    arr   << last.day.to_s
    arr.to_s
  end
  
  def to_parseable_date(date)
    date_parts = date.split('/')
    "20#{date_parts[2]}-#{date_parts[1]}-#{date_parts[0]}"
  end

  def truncate(text, options)
    if text
      l = options[:length] - 3
      (text.size > options[:length] ? text[0...l] + "..." : text).to_s
    end
  end
end
