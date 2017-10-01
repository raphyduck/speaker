require "simple_speaker/version"

module SimpleSpeaker
  class Speaker
    def initialize(logger_path = nil, logger_error_path = nil)
      @logger = Logger.new(logger_path) unless logger_path.nil?
      @logger_error = Logger.new(logger_error_path) unless logger_error_path.nil?
    end

    def ask_if_needed(question, no_prompt = 0, default = 'y')
      ask_if_needed = default
      if no_prompt.to_i == 0
        self.speak_up(question)
        ask_if_needed = STDIN.gets.strip
      end
      ask_if_needed
    end

    def speak_up(str)
      puts str
      @logger.info(str) if @logger
      $email_msg += str + NEW_LINE if $email_msg
    end

    def log(str)
      @logger.info(str) if @logger
    end

    def tell_error(e, src)
      puts "In #{src}"
      puts e
      @logger_error.error("ERROR #{Time.now.utc.to_s} #{src}") if @logger_error
      @logger_error.error(e) if @logger_error
      $email_msg += "ERROR #{Time.now.utc.to_s} #{src}" + NEW_LINE if $email_msg
      $email_msg += e.to_s + NEW_LINE if $email_msg
    end
  end
end
