require 'stringio'
require 'test/unit'

require_relative '../lib/pwait/runner'

class TestRunner < Test::Unit::TestCase
  def test1
    [3, 6, 9, 20].each do |n|
      Process.waitall
      pids = n.times.map { fork { exit } }
      collected_output = ''
      sio = StringIO.new(collected_output, 'w')
      runner = Pwait::Runner.new(pids.map(&:to_s), sio)
      Process.waitall
      runner.run
      sio.close
      assert_equal(n, collected_output.count("\n"))
    end
  end
end
