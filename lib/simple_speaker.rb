require "simple_speaker/version"

module SimpleSpeaker
  class Speaker
    def initialize(logger_path = nil, logger_error_path = nil)
      @logger = Logger.new(logger_path) unless logger_path.nil?
      @logger_error = Logger.new(logger_error_path) unless logger_error_path.nil?
      @daemon = nil
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
      @daemon = daemon_server if daemon_server
      @daemon
    end

    def speak_up(str, in_mail = 1)
      puts str
      @daemon.send_data "#{str}\n" unless @daemon.nil?
      @logger.info(str) if @logger
      Thread.current[:email_msg] += str + NEW_LINE if Thread.current[:email_msg] && in_mail.to_i > 0
      str
    end

    def log(str)
      @logger.info(str) if @logger
    end

    def tell_error(e, src)
      puts "In #{src}"
      @daemon.send_data "In #{src}\n" unless @daemon.nil?
      puts e
      @daemon.send_data "#{e}\n" unless @daemon.nil?
      @logger_error.error("ERROR #{Time.now.utc.to_s} #{src}") if @logger_error
      @logger_error.error(e) if @logger_error
      Thread.current[:email_msg] += "ERROR #{Time.now.utc.to_s} #{src}" + NEW_LINE if Thread.current[:email_msg]
      Thread.current[:email_msg] += e.to_s + NEW_LINE if Thread.current[:email_msg]
    end

    def user_input(input)
      @user_input = input
    end
  end
end
