module Fluent
  class JstatInput < Input
    Plugin.register_input('jstat', self)

    def initialize
      super
    end

    config_param :emit_interval, :time, :default => 60
    config_param :tag, :string
    config_param :jstat_path, :string, :default => "jstat"
    config_param :option, :string
    config_param :pid_path, :string, :default => nil
    config_param :process_name, :string, :default => nil
    config_param :scale, :integer, :default => 1

    class TimerWatcher < Coolio::TimerWatcher
      def initialize(interval, repeat, &callback)
        @callback = callback
        super(interval, repeat)
      end

      def on_timer
        @callback.call
      rescue
        # TODO log?
        $log.error $!.to_s
        $log.error_backtrace
      end
    end

    def configure(conf)
      super
      if @pid_path.nil? && @process_name.nil?
        raise Fluent::ConfigError, "'pid_path' or 'process_name' option is required on jstat input"
      end
    end

    def start
      @loop = Coolio::Loop.new
      @timer = TimerWatcher.new(@emit_interval, true, &method(:on_timer))
      @loop.attach(@timer)
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      @loop.watchers.each {|w| w.detach }
      @loop.stop
      @thread.join
    end

    def run
      @loop.run
    rescue
      $log.error "unexpected error", :error=>$!.to_s
      $log.error_backtrace
    end

    def on_timer
      pid = retrieve_pid()
      command = "#{@jstat_path} #{@option} #{pid}"
      now = Engine.now
      lines = exec_command(command)
      headers = lines[0].split()
      datas = lines[1].split()
 
      record = Hash.new
      headers.each_with_index{|header, i|
        record[header] = datas[i].to_f * @scale
      }
      Engine.emit(@tag, now, record)
    end

    private
    def exec_command(command)
      io = IO.popen(command, "r")
      lines = io.readlines()
      io.close
      lines
    end

    def retrieve_pid
      unless @pid_path.nil?
        File.read(@pid_path)
      else
        exec_command("pgrep -f \"#{@process_name}\"")[0]
      end
    end
  end
end