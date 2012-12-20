module Pwait
  class LinuxProcess
    PROC_DIR = '/proc/'

    def initialize(pid)
      @pid = pid
      @file = File.join(PROC_DIR, pid.to_s, 'stat')
      @saved_start_time = start_time
    end

    def exists?
      !@saved_start_time.nil? && start_time == @saved_start_time
    end

    def id
      @pid
    end

    private

    def start_time
      begin
        content = File.open(@file, &:read)
      rescue Errno::ENOENT
        nil
      else
        content.scan(/\S+/)[21]
      end
    end
  end
end
