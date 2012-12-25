require_relative 'linux_process'

module Pwait
  class Runner
    SLEEP_TIME = 0.05

    def initialize(args, stream)
      @stream = stream

      @processes = args.map do |arg|
        LinuxProcess.new(arg[/\d+\z/].to_i)
      end
      @processes.select!(&:exists?)
    end

    def run
      Signal.trap('INT', 'EXIT')
      #< eliminates an ugly stack trace from Ruby

      loop do
        extant, gone = @processes.partition(&:exists?)
        gone.map(&:id).sort.each { |p| @stream.puts p }
        @processes = extant
        break if @processes.empty?
        sleep(SLEEP_TIME)
      end
    end
  end
end
