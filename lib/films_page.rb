require 'cgi'

class FilmsPage
  
  FROM_XPATH        = "//div[@class='view-movie']/p/descendant::*[contains(.,'Showing from')]/following::text()"
  GENRE_XPATH       = "//div[@class='view-movie']/p/descendant::*[contains(.,'Genre')]/following-sibling::a/text()"
  PRICE_XPATH       = "//div[@class='view-movie']/p/descendant::*[contains(.,'Price')]/following::text()"
  CERTIFICATE_XPATH = "//div[@class='view-movie']/p/descendant::*[contains(.,'Certificate')]/following::text()"
  YEAR_XPATH        = "//div[@class='view-movie']/p/descendant::*[contains(.,'Year')]/following::text()"

  def initialize(url)
    @host = URI.parse(url).host
    @page = Nokogiri::HTML(open(url))
  end
  
  def films
    films = []
    @page.xpath("//div[@class='movie-snippet']").each do |film_block|
      begin
        details_url = "http://#{@host}" + film_block.xpath("h4/a").attr('href')
        
        films << { :title         => tidy(film_block.xpath("h4/a").text),
                   :tag_line      => tidy(film_block.xpath("p[1]").text),
                   :special_offer => tidy(film_block.xpath("p[2]").text),
                   :url           => details_url                            }.merge(film_details(details_url))
      rescue
        # do nothing
      end
    end
    films
  end
  
private
  
  def film_details(url)
    page = Nokogiri::HTML(open(url))
    {
      :from         => tidy(page.xpath(FROM_XPATH)[0]),
      :genre        => page.xpath(GENRE_XPATH).map { |t| tidy(t) }.join(', '),
      :price        => tidy(page.xpath(PRICE_XPATH)[0]),
      :certificate  => tidy(page.xpath(CERTIFICATE_XPATH)[0]),
      :year         => tidy(page.xpath(YEAR_XPATH)[0])
    }
  end
  
  def tidy(text)
    CGI.unescapeHTML(text.to_s.strip)
  end
end