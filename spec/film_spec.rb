require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe Film, "processing films - validation" do
  
  before(:each) do
    ::TWITTER.stub!(:status)
    film_params = { :certificate    => "15", 
                    :title          => "Tropic Thunder", 
                    :special_offer  => "Available for £1.50 from 27/03/09 to 02/04/09",
                    :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunder/", 
                    :tag_line       => "Ben Stiller and Jack Black play actors in an action film.", 
                    :from           => "Now showing", 
                    :genre          => "Action & Adventure, Comedy", 
                    :year           => "2008", 
                    :price          => "£3.99" }
                        
    @no_title         = film_params.merge(:title        => "")
    @no_url           = film_params.merge(:url          => "")
    @no_price         = film_params.merge(:price        => "")
    @no_certificate   = film_params.merge(:certificate  => "")
    @no_year          = film_params.merge(:year         => "")
    @no_from          = film_params.merge(:from         => "")
    @minimum_info     = { :certificate    => "15", 
                          :title          => "Tropic Thunder", 
                          :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunder/", 
                          :from           => "Now showing", 
                          :year           => "2008", 
                          :price          => "£3.99"}
  end

  it "should NOT add a film to the database if it has no title" do
    lambda { Film.process_films([@no_title]) }.should_not change(Film, :count)
  end
  
  it "should NOT tweet a film if one is added with no title" do
    TWITTER.should_not_receive(:status)
    Film.process_films([@no_title])
  end

  it "should NOT add a film to the database if it has no url" do
    lambda { Film.process_films([@no_url]) }.should_not change(Film, :count)
  end
  
  it "should NOT tweet a film if one is added with no url" do
    TWITTER.should_not_receive(:status)
    Film.process_films([@no_url])
  end

  it "should NOT add a film to the database if it has no price" do
    lambda { Film.process_films([@no_price]) }.should_not change(Film, :count)
  end
  
  it "should NOT tweet a film if one is added with no price" do
    TWITTER.should_not_receive(:status)
    Film.process_films([@no_price])
  end

  it "should NOT add a film to the database if it has no certificate" do
    lambda { Film.process_films([@no_certificate]) }.should_not change(Film, :count)
  end
  
  it "should NOT tweet a film if one is added with no certificate" do
    TWITTER.should_not_receive(:status)
    Film.process_films([@no_certificate])
  end

  it "should NOT add a film to the database if it has no year" do
    lambda { Film.process_films([@no_year]) }.should_not change(Film, :count)
  end
  
  it "should NOT tweet a film if one is added with no year" do
    TWITTER.should_not_receive(:status)
    Film.process_films([@no_year])
  end

  it "should NOT add a film to the database if it has no from" do
    lambda { Film.process_films([@no_from]) }.should_not change(Film, :count)
  end
  
  it "should NOT tweet a film if one is added with no from" do
    TWITTER.should_not_receive(:status)
    Film.process_films([@no_from])
  end

  it "should add a film to the database if it has the minimum information" do
    lambda { Film.process_films([@minimum_info]) }.should change(Film, :count).by(1)
  end
  
  it "should tweet a film if one is added with the minimum information" do
    TWITTER.should_receive(:status)
    Film.process_films([@minimum_info])
  end
end

describe Film, "processing films - removing files that are NOT included in the update" do
  
  before(:each) do
    ::TWITTER.stub!(:status)
    film_params = { :certificate    => "15", 
                    :title          => "Tropic Thunder", 
                    :special_offer  => "Available for £1.50 from 27/03/09 to 02/04/09",
                    :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunder/", 
                    :tag_line       => "Ben Stiller and Jack Black play actors in an action film.", 
                    :from           => "Now showing", 
                    :genre          => "Action & Adventure, Comedy", 
                    :year           => "2008", 
                    :price          => "£3.99" }
    @film_1 = film_params
    @film_2 = film_params.merge(:url => "http://moviesondemand.virginmedia.com/movies/tropicthunderthedirectorscut/")
    @film_3 = film_params.merge(:url => "http://moviesondemand.virginmedia.com/movies/taken/")
  end
  
  it "should NOT remove films that are not included in the update if they were created in the last 60 days (so films aren't deleted if the scrape cocks up)" do
    Film.process_films([@film_1, @film_2, @film_3])
    film = Film.first(:title => "Tropic Thunder")
    film.update_attributes(:created_on => Date.today + 60)
    lambda { Film.process_films([@film_2, @film_3]) }.should_not change(Film, :count)
  end
  
  it "should remove films that are not included in the update if they were created more than 60 days ago" do
    Film.process_films([@film_1, @film_2, @film_3])
    film = Film.first(:title => "Tropic Thunder")
    film.update_attributes(:created_on => Date.today + 61)
    lambda { Film.process_films([@film_2, @film_3]) }.should change(Film, :count).by(-1)
  end
end


describe Film, "processing films - updating with new data" do
  
  before(:each) do
    ::TWITTER.stub!(:status)
    @film = { :certificate    => "15", 
              :title          => "Tropic Thunder", 
              :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunder/", 
              :tag_line       => "Ben Stiller and Jack Black play actors in an action film.", 
              :from           => "Now showing", 
              :genre          => "Action & Adventure, Comedy", 
              :year           => "2008", 
              :price          => "£3.99"}
    @film_updated = @film.merge(:from => "5 days left")
  end

  it "should update an existing film if it is processed with new data" do
    Film.process_films([@film])
    Film.process_films([@film_updated])
    film = Film.first(:url => "http://moviesondemand.virginmedia.com/movies/tropicthunder/")
    film.from.should == "5 days left"
  end
end

describe Film, "processing films - tweeting newly added films" do
  
  before(:each) do
    ::TWITTER.stub!(:status)
    film_params = { :certificate    => "15", 
                    :title          => "Tropic Thunder", 
                    :special_offer  => "",
                    :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunder/", 
                    :tag_line       => "Ben Stiller and Jack Black play actors in an action film.", 
                    :from           => "30 March", 
                    :genre          => "Action & Adventure, Comedy", 
                    :year           => "2008", 
                    :price          => "£3.99" }
    @film_upcoming    = film_params
    @film_now_showing = film_params.merge(:from => "Now showing")
    @film_last_chance = film_params.merge(:from => "4 days left")

    @film_upcoming_special    = @film_upcoming.merge(:special_offer => "Available for £1.50 from 27/03/09 to 02/04/09")
    @film_now_showing_special = @film_now_showing.merge(:special_offer => "Available for £1.50 from 27/03/09 to 02/04/09")
    @film_last_chance_special = @film_last_chance.merge(:special_offer => "Available for £1.50 from 27/03/09 to 02/04/09")
  end
  
  it "should tweet an upcoming film if one is added" do
    TWITTER.should_receive(:status).with(:post, "[From 30 March] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an action film.")
    Film.process_films([@film_upcoming])
  end
  
  it "should tweet a now showing film if one is added" do
    TWITTER.should_receive(:status).with(:post, "[Available Now] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an action film.")
    Film.process_films([@film_now_showing])
  end
  
  it "should tweet a last chance film if one is added" do
    TWITTER.should_receive(:status).with(:post, "[Last Chance: 4 days left] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an act...")
    Film.process_films([@film_last_chance])
  end
  
  it "should tweet an upcoming film as a special offer if it is added with a special offer" do
    TWITTER.should_receive(:status).with(:post, "[Special Offer: Mar 27 - Apr 2 @ £1.50] Tropic Thunder (15, 2008) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in ...")
    Film.process_films([@film_upcoming_special])
  end
  
  it "should tweet a now showing film as a special offer if one is added with a special offer" do
    TWITTER.should_receive(:status).with(:post, "[Special Offer: Mar 27 - Apr 2 @ £1.50] Tropic Thunder (15, 2008) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in ...")
    Film.process_films([@film_now_showing_special])
  end
  
  it "should tweet a last chance film  as a special offerif one is added with a special offer" do
    TWITTER.should_receive(:status).with(:post, "[Special Offer: Mar 27 - Apr 2 @ £1.50] Tropic Thunder (15, 2008) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in ...")
    Film.process_films([@film_last_chance_special])
  end
end

describe Film, "processing films - tweeting updated films" do
  
  before(:each) do
    ::TWITTER.stub!(:status)
    ::TWITTER.stub!(:status)
    film_params = { :certificate    => "15", 
                    :title          => "Tropic Thunder", 
                    :special_offer  => "",
                    :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunder/", 
                    :tag_line       => "Ben Stiller and Jack Black play actors in an action film.", 
                    :from           => "30 March", 
                    :genre          => "Action & Adventure, Comedy", 
                    :year           => "2008", 
                    :price          => "£3.99" }
    @film_upcoming              = film_params
    @film_now_showing           = film_params.merge(:from => "Now showing")
    @film_last_chance           = film_params.merge(:from => "4 days left")
    @film_last_chance_next_day  = film_params.merge(:from => "3 days left")
    @film_last_chance_no_days   = film_params.merge(:from => "0 days left")

    @film_upcoming_special    = @film_upcoming.merge(:special_offer => "Available for £1.50 from 27/03/09 to 02/04/09")
    @film_now_showing_special = @film_now_showing.merge(:special_offer => "Available for £1.50 from 27/03/09 to 02/04/09")
    @film_last_chance_special = @film_last_chance.merge(:special_offer => "Available for £1.50 from 27/03/09 to 02/04/09")

    @film_upcoming_new_year    = @film_upcoming.merge(:year => "2009")
    @film_now_showing_new_year = @film_now_showing.merge(:year => "2009")
    @film_last_chance_new_year = @film_last_chance.merge(:year => "2009")
  end
  
  it "should re-tweet an upcoming film if it is updated to be now showing" do
    Film.process_films([@film_upcoming])
    TWITTER.should_receive(:status).with(:post, "[Available Now] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an action film.")
    Film.process_films([@film_now_showing])
  end
  
  it "should re-tweet an upcoming film if it is updated to be last chance" do
    Film.process_films([@film_upcoming])
    TWITTER.should_receive(:status).with(:post, "[Last Chance: 4 days left] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an act...")
    Film.process_films([@film_last_chance])
  end
  
  it "should re-tweet an upcoming film if it is updated to be special offer" do
    Film.process_films([@film_upcoming])
    TWITTER.should_receive(:status).with(:post, "[Special Offer: Mar 27 - Apr 2 @ £1.50] Tropic Thunder (15, 2008) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in ...")
    Film.process_films([@film_upcoming_special])
  end
  
  it "should re-tweet an upcoming film if it is updated with a new year" do
    Film.process_films([@film_upcoming])
    TWITTER.should_receive(:status).with(:post, "[From 30 March] Tropic Thunder (15, 2009, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an action film.")
    Film.process_films([@film_upcoming_new_year])
  end
  
  it "should re-tweet a showing now film if it is updated to be upcoming" do
    Film.process_films([@film_now_showing])
    TWITTER.should_receive(:status).with(:post, "[From 30 March] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an action film.")
    Film.process_films([@film_upcoming])
  end
  
  it "should re-tweet a showing now film if it is updated to be last chance" do
    Film.process_films([@film_now_showing])
    TWITTER.should_receive(:status).with(:post, "[Last Chance: 4 days left] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an act...")
    Film.process_films([@film_last_chance])
  end
  
  it "should re-tweet a showing now film if it is updated to be special offer" do
    Film.process_films([@film_now_showing])
    TWITTER.should_receive(:status).with(:post, "[Special Offer: Mar 27 - Apr 2 @ £1.50] Tropic Thunder (15, 2008) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in ...")
    Film.process_films([@film_now_showing_special])
  end
  
  it "should re-tweet a showing now film if it is updated with a new year" do
    Film.process_films([@film_now_showing])
    TWITTER.should_receive(:status).with(:post, "[Available Now] Tropic Thunder (15, 2009, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an action film.")
    Film.process_films([@film_now_showing_new_year])
  end
  
  it "should re-tweet a last chance film if it is updated to be now upcoming" do
    Film.process_films([@film_last_chance])
    TWITTER.should_receive(:status).with(:post, "[From 30 March] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an action film.")
    Film.process_films([@film_upcoming])
  end
  
  it "should re-tweet a last chance film if it is updated to be showing now" do
    Film.process_films([@film_last_chance])
    TWITTER.should_receive(:status).with(:post, "[Available Now] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an action film.")
    Film.process_films([@film_now_showing])
  end
  
  it "should re-tweet a last chance film if it is updated to be special offer" do
    Film.process_films([@film_last_chance])
    TWITTER.should_receive(:status).with(:post, "[Special Offer: Mar 27 - Apr 2 @ £1.50] Tropic Thunder (15, 2008) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in ...")
    Film.process_films([@film_last_chance_special])
  end
  
  it "should re-tweet a last chance film if it is updated with a new year" do
    Film.process_films([@film_last_chance])
    TWITTER.should_receive(:status).with(:post, "[Last Chance: 4 days left] Tropic Thunder (15, 2009, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an act...")
    Film.process_films([@film_last_chance_new_year])
  end
  
  it "should NOT re-tweet a last chance film if it is updated with different days left" do
    Film.process_films([@film_last_chance])
    TWITTER.should_not_receive(:status)
    Film.process_films([@film_last_chance_next_day])
  end
  
  it "should re-tweet a special offer upcoming film if it is no longer special offer" do
    Film.process_films([@film_upcoming_special])
    TWITTER.should_receive(:status).with(:post, "[From 30 March] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an action film.")
    Film.process_films([@film_upcoming])
  end
  
  it "should re-tweet a special offer now showing film if it is no longer special offer" do
    Film.process_films([@film_now_showing_special])
    TWITTER.should_receive(:status).with(:post, "[Available Now] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an action film.")
    Film.process_films([@film_now_showing])
  end
  
  it "should re-tweet a special offer last chance film if it is no longer special offer" do
    Film.process_films([@film_last_chance_special])
    TWITTER.should_receive(:status).with(:post, "[Last Chance: 4 days left] Tropic Thunder (15, 2008, £3.99) Action & Adventure, Comedy. Ben Stiller and Jack Black play actors in an act...")
    Film.process_films([@film_last_chance])
  end
  
  it "should NOT re-tweet a special offer last chance film if it is no longer special offer but it has 0 days left" do
    Film.process_films([@film_last_chance_special])
    TWITTER.should_not_receive(:status)
    Film.process_films([@film_last_chance_no_days])
  end
end
