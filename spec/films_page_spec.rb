require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe FilmsPage, "parsing films pages" do
  
  before(:each) do
    FakeWeb.register_uri( 'http://moviesondemand.virginmedia.com/movies/groups/newreleases/', 
                          :file => File.join(File.dirname(__FILE__), 'pages', 'new_releases.html'))
    FakeWeb.register_uri( 'http://moviesondemand.virginmedia.com/movies/tropicthunder/', 
                          :file => File.join(File.dirname(__FILE__), 'pages', 'tropic_thunder.html'))
    FakeWeb.register_uri( 'http://moviesondemand.virginmedia.com/movies/tropicthunderthedirectorscut/', 
                          :file => File.join(File.dirname(__FILE__), 'pages', 'tropic_thunder_directors.html'))
    FakeWeb.register_uri( 'http://moviesondemand.virginmedia.com/movies/taken/', 
                          :file => File.join(File.dirname(__FILE__), 'pages', 'taken.html'))
    @new_releases_page = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/newreleases/')

    FakeWeb.register_uri( 'http://moviesondemand.virginmedia.com/movies/groups/specialoffers/', 
                          :file => File.join(File.dirname(__FILE__), 'pages', 'special_offers.html'))
    FakeWeb.register_uri( 'http://moviesondemand.virginmedia.com/movies/priceless/', 
                          :file => File.join(File.dirname(__FILE__), 'pages', 'priceless.html'))
    FakeWeb.register_uri( 'http://moviesondemand.virginmedia.com/movies/shootonsight/', 
                          :file => File.join(File.dirname(__FILE__), 'pages', 'shoot_on_site.html'))
    @special_offers_page = FilmsPage.new('http://moviesondemand.virginmedia.com/movies/groups/specialoffers/')
  end
  
  it "should extract the film details from the normal film pages" do
    @new_releases_page.films.should == [{ :certificate    => "15", 
                                          :title          => "Tropic Thunder", 
                                          :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunder/", 
                                          :tag_line       => "Ben Stiller and Jack Black play actors in an action film.", 
                                          :from           => "Now showing", 
                                          :genre          => "Action & Adventure, Comedy", 
                                          :year           => "2008", 
                                          :special_offer  => "", 
                                          :price          => "£3.99"}, 
                                        { :certificate    => "15", 
                                          :title          => "Tropic Thunder: The Director's Cut", 
                                          :url            => "http://moviesondemand.virginmedia.com/movies/tropicthunderthedirectorscut/", 
                                          :tag_line       => "Director's cut of Ben Stiller's crazy comedy.", 
                                          :from           => "Now showing", 
                                          :genre          => "Action & Adventure, Comedy", 
                                          :year           => "2008", 
                                          :special_offer  => "", 
                                          :price          => "£3.99"}, 
                                        { :certificate    => "18", 
                                          :title          => "Taken", 
                                          :url            => "http://moviesondemand.virginmedia.com/movies/taken/", 
                                          :tag_line       => "An ex-soldier (Liam Neeson) must save his kidnapped daughter", 
                                          :from           => "Now showing", 
                                          :genre          => "Action & Adventure, Thriller & Crime", 
                                          :year           => "2008", 
                                          :special_offer  => "", 
                                          :price          => "£3.50"}]
  end
  
  it "should extract the film details from the special offer films page" do
    @special_offers_page.films.should == [{ :url            => "http://moviesondemand.virginmedia.com/movies/priceless/", 
                                            :tag_line       => "A lowly barman is mistaken for a millionaire. Subtitled.", 
                                            :genre          => "Comedy, Romance, Independent Cinema", 
                                            :from           => "Now showing", 
                                            :price          => "£1.50", 
                                            :certificate    => "12", 
                                            :year           => "2007", 
                                            :special_offer  => "Available for £1.50 from 23/03/09 to 29/03/09", 
                                            :title          => "Priceless"}, 
                                          { :special_offer  => "Available for 99p from 23/03/09 to 29/03/09", 
                                            :url            => "http://moviesondemand.virginmedia.com/movies/shootonsight/", 
                                            :tag_line       => "A Muslim police officer faces turmoil at Scotland Yard.", 
                                            :genre          => "Thriller & Crime, Independent Cinema", 
                                            :from           => "Now showing", 
                                            :price          => "£0.99", 
                                            :certificate    => "15", 
                                            :year           => "2007", 
                                            :title          => "Shoot On Sight"}]
  end
end
  
