require 'sys/filesystem'

class File
  def filesystem
    if !instance_variable_defined?(:@mount_point)
      dev = stat.dev

      Sys::Filesystem.mounts do |mount|
        if mount.disk? && File.stat(mount.name).rdev == dev
          @mount_point = mount.mount_point
          break
        end
      end

      if !instance_variable_defined?(:@mount_point)
        raise "cannot find disk filesystem for #{path}"
      end
    end

    Sys::Filesystem.stat(@mount_point)
  end
end
