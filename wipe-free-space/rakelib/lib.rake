require 'pathname'

def mount_info
  require_relative '../test/app_test'

  AppTest::TEST_MOUNT_POINTS.sort.each_with_object({}) \
  do |mount_point, result|
    unprefixed =
      mount_point[AppTest::PREFIX.chomp('/').length..-1]
    lvm_name =
      (LVM_PREFIX + unprefixed).tr('/', ' ').split.join('-')
    device = "/dev/#{VOLUME_GROUP}/#{lvm_name}"

    result[device] = mount_point
  end
end
