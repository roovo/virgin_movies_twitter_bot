# fix to allow twitter4r to have ampersands in the message
class Hash
   def to_http_str
    result = ''
    return result if self.empty?
    self.each do |key, val|
      result << "#{key}=#{CGI::escape(val.to_s)}&" 
    end
    result.chop 
  end
end