class MinimumSpaceCalculator
  def initialize(spec)
    if spec.match(/\A\d+\z/)
      @min = $~[0].to_i
    elsif spec.match(/\A(\d+)e(\d+)\z/)
      @min = $~[1].to_i * 10**$~[2].to_i
    elsif spec.match(/\A(\d+|\d*\.\d+)%\z/)
      percentage = Rational($~[1])
      raise "invalid percentage: #{spec}" if percentage >= 100
      @fraction = percentage / 100
    end
  end

  def [](filesystem)
    if instance_variable_defined?(:@min)
      @min
    else
      (@fraction * filesystem.bytes).ceil
    end
  end

  def to_s
    contents = %w{min fraction}.each do |name|
      var_name = "@#{name}"
      if instance_variable_defined?(var_name)
        break "#{name}=#{instance_variable_get(var_name)}"
      end
    end

    "<#{self.class.name}: #{contents}>"
  end
end
