require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe Film, "processing films" do
  
  before(:each) do
    ::TWITTER.stub!(:status)
    @film_0 = { :certificate    => "15", 
                :title          => "", 
                :special_offer  => "",
                :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunder/", 
                :tag_line       => "Ben Stiller and Jack Black play actors in an action film.", 
                :from           => "Now showing", 
                :genre          => "Action & Adventure, Comedy", 
                :year           => "2008", 
                :price          => "£3.99"}
    @film_1 = { :certificate    => "15", 
                :title          => "Tropic Thunder", 
                :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunder/", 
                :tag_line       => "Ben Stiller and Jack Black play actors in an action film.", 
                :from           => "Now showing", 
                :genre          => "Action & Adventure, Comedy", 
                :year           => "2008", 
                :price          => "£3.99"}
    @film_1_updated = { :certificate    => "15", 
                        :title          => "Tropic Thunder", 
                        :special_offer  => "",
                        :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunder/", 
                        :tag_line       => "Ben Stiller and Jack Black play actors in an action film.", 
                        :from           => "5 days left", 
                        :genre          => "Action & Adventure, Comedy", 
                        :year           => "2008", 
                        :price          => "£3.99"}
    @film_2 = { :certificate    => "15", 
                :title          => "Tropic Thunder: The Director's Cut", 
                :special_offer  => "",
                :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunderthedirectorscut/", 
                :tag_line       => "Director’s cut of Ben Stiller’s crazy comedy.", 
                :from           => "4 days left", 
                :genre          => "Action & Adventure, Comedy", 
                :year           => "2008", 
                :price          => "£3.99"}
    @film_2_updated = { :certificate    => "15", 
                        :title          => "Tropic Thunder: The Director's Cut", 
                        :special_offer  => "Available for £1.50 from 27/03/09 to 02/04/09",
                        :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunderthedirectorscut/", 
                        :tag_line       => "Director’s cut of Ben Stiller’s crazy comedy.", 
                        :from           => "4 days left", 
                        :genre          => "Action & Adventure, Comedy", 
                        :year           => "2008", 
                        :price          => "£1.50"}
    @film_3 = { :certificate    => "18", 
                :title          => "Taken", 
                :special_offer  => "",
                :url            => "http://moviesondemand.virginmedia.com/movies/taken/", 
                :tag_line       => "An ex-soldier (Liam Neeson) must save his kidnapped daughter", 
                :from           => "30 March", 
                :genre          => "Action & Adventure, Thriller & Crime", 
                :year           => "2008", 
                :price          => "£3.50"}
    @film_3_updated = { :certificate    => "18", 
                        :title          => "Taken", 
                        :special_offer  => "",
                        :url            => "http://moviesondemand.virginmedia.com/movies/taken/", 
                        :tag_line       => "An ex-soldier (Liam Neeson) must save his kidnapped daughter", 
                        :from           => "30 March", 
                        :genre          => "Action & Adventure, Thriller & Crime", 
                        :year           => "2028", 
                        :price          => "£3.50"}
  end

  it "should NOT add a film to the database if it has no title" do
    lambda { Film.process_films([@film_0]) }.should_not change(Film, :count)
  end

  it "should add 3 films to the database if three are processed that are new" do
    lambda { Film.process_films([@film_1, @film_2, @film_3]) }.should change(Film, :count).by(3)
  end

  it "should update a film if it is processed with new data" do
    Film.process_films([@film_1])
    Film.process_films([@film_1_updated])
    film = Film.first(:url => "http://moviesondemand.virginmedia.com/movies/tropicthunder/")
    film.from.should == "5 days left"
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
  
  it "should NOT tweet an upcoming film if one is added with no title" do
    TWITTER.should_not_receive(:status)
    Film.process_films([@film_0])
  end
  
  it "should tweet an upcoming film if one is added" do
    TWITTER.should_receive(:status).with(:post, "[Due 30 March] Taken (18, 2008, £3.50) - Action & Adventure, Thriller & Crime - An ex-soldier (Liam Neeson) must save his kidnapped daug...")
    Film.process_films([@film_3])
  end
  
  it "should tweet a now showing film if one is added" do
    TWITTER.should_receive(:status).with(:post, "[New] Tropic Thunder (15, 2008, £3.99) - Action & Adventure, Comedy - Ben Stiller and Jack Black play actors in an action film.")
    Film.process_films([@film_1])
  end
  
  it "should tweet a last chance film if one is added" do
    TWITTER.should_receive(:status).with(:post, "[Last Chance: 4 days left] Tropic Thunder: The Director's Cut (15, 2008, £3.99) - Action & Adventure, Comedy - Director’s cut of Ben S...")
    Film.process_films([@film_2])
  end
  
  it "should re-tweet an upcoming film if it is updated and the from is left the same but it is made a special offer" do
    Film.process_films([@film_1])
    TWITTER.should_receive(:status).once
    Film.process_films([@film_1_updated])
  end
  
  it "should re-tweet an upcoming film if it is updated and the special offer is changed and isn't blank" do
    Film.process_films([@film_2])
    TWITTER.should_receive(:status).with(:post, "[Special Offer: Mar 27 - Apr 2 @ £1.50] Tropic Thunder: The Director's Cut (15, 2008) - Action & Adventure, Comedy - Director’s cut of...")
    Film.process_films([@film_2_updated])
  end
  
  it "should NOT re-tweet an upcoming film if it is updated and the special offer is changed to being blank" do
    Film.process_films([@film_2_updated])
    TWITTER.should_not_receive(:status)
    Film.process_films([@film_2])
  end
  
  it "should NOT re-tweet an upcoming film if it is updated but the from and special offer isn't changed" do
    Film.process_films([@film_3])
    TWITTER.should_not_receive(:status)
    Film.process_films([@film_3_updated])
  end
end