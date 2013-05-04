require 'sys/filesystem'

class Sys::Filesystem::Mount
  def disk?
    name.match(%r{\A/dev/.})
  end
end
