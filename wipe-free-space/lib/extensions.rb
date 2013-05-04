require 'find'

Find.find(__dir__) do |path|
  require path if path =~ /.\.rb\z/
end
