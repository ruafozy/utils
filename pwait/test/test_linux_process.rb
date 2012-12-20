require 'test/unit'

require_relative '../lib/pwait/linux_process'

class TestLinuxProcess < Test::Unit::TestCase
  def test1
    pid1 = Process.pid
    lp = Pwait::LinuxProcess.new(pid1)
    assert_equal(pid1, lp.id)
    assert(lp.exists?)

    pid2 = ('1' * 100).to_i
    refute(Pwait::LinuxProcess.new(pid2).exists?)
  end
end
