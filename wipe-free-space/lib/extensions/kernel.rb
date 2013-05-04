require 'pathname'

module Kernel
  private

  def cleanpath(path)
    Pathname.new(path).cleanpath.to_s
  end
end
