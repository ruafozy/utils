require 'sys/filesystem'

class Sys::Filesystem::Stat
  def bytes
    blocks * block_size
  end

  def bytes_free
    blocks_free * block_size
  end

  def fraction_free
    Rational(blocks_free, blocks)
  end
end
