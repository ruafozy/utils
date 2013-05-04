#!/usr/local/bin/ruby-2 -w

require 'rubygems'
gem 'minitest', '~> 4.0'

require 'find'
require 'minitest/unit'
require 'pathname'
require 'pstore'
require 'rake'
require 'shellwords'
require 'sys/filesystem'
require 'tempfile'

require 'pp'

class AppTest < MiniTest::Unit::TestCase
  EXECUTABLE = File.join(__dir__, '..', 'bin', 'wipe-free-space').freeze

  PREFIX = '/root/mnt/test-filling'

  PROBE_EXECUTABLE = File.join(__dir__, 'probe.rb').freeze

  def initialize(*)
    super

    if Process.euid == 0
      fail "test is being executed by root"
    end

    if File.owned?(__FILE__)
      fail "test is being executed by developer"
    end
  end

  def setup
    @asserted_about = {}
  end

  def test_percentage_minima
    execute(
      %W{
        --exclude #{px '/var'} --min-free #{px '/tmp'}:50%
      } +
      TEST_MOUNT_POINTS
    )

    assert_free(px('/'), 0)
    assert_free(px('/home'), 0)
    assert_free(px('/tmp'), '50%')
    assert_free(px('/usr'), 0)

    assert_untouched(px('/var'))
    assert_untouched(px('/var/local'))
  end

  def test_absolute_minima
    minima = [15_000_000, 25_000_000]

    execute(
      %W{
        --min-free #{px '/'}:#{minima[0]}
        --min-free #{px '/var/local'}:#{minima[1]}
      } + TEST_MOUNT_POINTS
    )

    assert_free(px('/'), minima[0])
    assert_free(px('/var/local'), minima[1])
  end

  def test_defaulting_of_minima
    execute(
      %W{
        --min-free #{px '/tmp'}:70%
        --min-free :50%
      } +
      pxa(%w{/ /home /tmp /var})
    )

    assert_free(px('/'), '50%')
    assert_free(px('/home'), '50%')
    assert_free(px('/tmp'), '70%')
    assert_free(px('/var'), '50%')
    assert_other_filesystems_untouched
  end

  def test_excluding_all
    execute(
      %w{--exclude /} + TEST_MOUNT_POINTS
    )
    assert_other_filesystems_untouched
  end

  def test_exclusion_semantics
    execute(
      %W{--exclude #{px '/u'} #{px '/usr'}}
    )

    assert_free(px('/usr'), '0')
  end

  def test_deferral
    execute(
      %W{
        --defer-deletion
        #{px '/usr'}
      }
    )

    pass
  end

  def test_multiple_slashes
    execute(
      %W{
        --exclude #{px('//usr')}

        --min-free #{px('/var//local')}:80%

        #{px('/var//////local')}
        #{px('/usr//')}
      }
    )

    #require 'debugger'; debugger
    assert_free(px('/var/local'), '80%')

    assert_other_filesystems_untouched
  end

  #> "px" is short for "prefix"
  def self.px(name)
    PREFIX + (name == '/' ? '': name)
  end

  TEST_MOUNT_POINTS = %W{
    /
    /home
    /tmp
    /usr
    /var
    /var/local
    /var/tmp
  }.map { |_| px _ }.freeze

  private

  def assert_free(mount_point, amount_free)
    @asserted_about[mount_point] = true

     stat_info = @fs_stat_at_end[mount_point]
     bytes = stat_info.blocks * stat_info.block_size
     bytes_free = stat_info.blocks_free * stat_info.block_size
 
    if amount_free.to_s.end_with?('%')
      target_fraction = amount_free.to_f / 100
    else
      target_fraction = amount_free.to_f / bytes
    end

    assert_in_delta(
      target_fraction, bytes_free.to_f / bytes, 0.01,
      "Fraction of free space on #{mount_point} " +
        "is not close to #{amount_free}"
    )
  end

  def assert_other_filesystems_untouched
    @also_touched = (@fs_stat_at_end.keys - @asserted_about.keys).sort

    assert(
      @also_touched.empty?,
      "additional filesystems processed: " + @also_touched.join(', ')
    )
  end

  def assert_untouched(mount_point)
    refute(
      @fs_stat_at_end.keys.map { |_| cleanpath(_) }.
        include?(cleanpath(mount_point)),
      "#{mount_point} was touched"
    )
  end

  def cleanpath(path)
    Pathname.new(path).cleanpath.to_s
  end

  def execute(args)
    Tempfile.open('probe-results.') do |temp_file_handle|
      probe_command = [
        FileUtils::RUBY,
        '--',
        PROBE_EXECUTABLE,
        temp_file_handle.path
      ]

      command = [
        FileUtils::RUBY,
        '--',
        EXECUTABLE,
        '--probe', probe_command.shelljoin,
        *args
      ]

      assert(system(*command), "command failed: #{command.shelljoin}")

      @fs_stat_at_end = {}

      PStore.new(temp_file_handle.path).tap do |pstore|
        pstore.transaction(true) do
          pstore.roots.each do |root|
            @fs_stat_at_end[root] = pstore[root]
          end
        end
      end
    end
  end

  def px(*a)
    self.class.px(*a)
  end

  # prepend a prefix to all the members of `list'
  #
  def pxa(list)
    list.map { |_| px(_) }
  end
end
