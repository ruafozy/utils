require 'pathname'

class Pathname
  def contains(other)
    self_clean = cleanpath

    other.cleanpath.ascend do |path|
      return true if path == self_clean
    end

    false
  end
end
