require 'pstore'
require 'sys/filesystem'

pstore_file, mount_point = ARGV

PStore.new(pstore_file).tap do |pstore|
  pstore.transaction do
    pstore[mount_point] = Sys::Filesystem.stat(mount_point)
  end
end
