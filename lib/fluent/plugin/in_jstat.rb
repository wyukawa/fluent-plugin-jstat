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
    config_param :pid_path, :string
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
      pid = File.read(@pid_path)
      command = "#{@jstat_path} #{@option} #{pid}"
      now = Engine.now
      io = IO.popen(command, "r")
      lines = io.readlines()
      io.close
      headers = lines[0].split()
      datas = lines[1].split()
 
      record = Hash.new
      headers.each_with_index{|header, i|
        record[header] = datas[i].to_f * @scale
      }
      Engine.emit(@tag, now, record)
    end
  end
end