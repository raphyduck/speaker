require "simple_speaker/version"

module SimpleSpeaker
  class Speaker
    def initialize(logger_path = nil, logger_error_path = nil)
      @logger = Logger.new(logger_path) unless logger_path.nil?
      @logger_error = Logger.new(logger_error_path) unless logger_error_path.nil?
      @daemons = []
      @user_input = nil
    end

    def ask_if_needed(question, no_prompt = 0, default = 'y')
      ask_if_needed = default
      if no_prompt.to_i == 0
        self.speak_up(question, 0)
        if Daemon.is_daemon?
          wtime = 0
          while @user_input.nil?
            sleep 1
            ask_if_needed = @user_input
            break if (wtime += 1) > USER_INPUT_TIMEOUT
          end
          @user_input = nil
        else
          ask_if_needed = STDIN.gets.strip
        end
      end
      ask_if_needed
    end

    def daemon(daemon_server = nil)
      @daemons << daemon_server if daemon_server
    end

    def speak_up(str, in_mail = 1)
      puts str
      send_to_all(str)
      @logger.info(str) if @logger
      Thread.current[:email_msg] += str + NEW_LINE if Thread.current[:email_msg]
      if in_mail.to_i > 0
        Thread.current[:send_email] = in_mail.to_i if Thread.current[:send_email]
      end
      str
    end

    def send_to_all(str)
      @daemons.each { |d| d.send_data "#{str}\n" }
    end

    def log(str)
      @logger.info(str) if @logger
    end

    def tell_error(e, src, in_mail = 1)
      puts "In #{src}"
      send_to_all(src)
      puts e
      send_to_all(e)
      @logger_error.error("ERROR #{Time.now.utc.to_s} #{src}") if @logger_error
      @logger_error.error(e) if @logger_error
      Thread.current[:email_msg] += "ERROR #{Time.now.utc.to_s} #{src}" + NEW_LINE if Thread.current[:email_msg]
      Thread.current[:email_msg] += e.to_s + NEW_LINE if Thread.current[:email_msg]
      if in_mail.to_i > 0
        Thread.current[:send_email] = in_mail.to_i if Thread.current[:send_email]
      end
    end

    def user_input(input)
      @user_input = input
    end
  end
end
