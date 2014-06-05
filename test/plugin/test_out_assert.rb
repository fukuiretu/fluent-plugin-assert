require 'helper'

class AssertOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
add_prefix hoge
<case>
  mode len,type
  key hoge
  len 5 up
  data_type integer
  time_format yyyy-mm-dd
</case>
  ]

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::AssertOutput, tag).configure(conf)
  end

  def test_configure
    d = create_driver
  end

  def test_emit
    d = create_driver
    time = Time.parse("2012-01-02 13:14:15").to_i
    d.emit({'hoge' => "abcdefg"}, time)
  end
end
