require 'logger'

class LoggingTwitter < Twitter::Client
  
  def initialize(params = {})
    super
    if params['log_file']
      log_file_path = File.join(File.dirname(__FILE__), '..', '..', '..', 'log', "#{params['log_file']}.log")
      @logger       = Logger.new(log_file_path)
      @logger.level = Logger::INFO
    end
  end
  
  def status(action, value)
    return @logger.info("[#{action}]: #{value}") if @logger
    super
  end
end
