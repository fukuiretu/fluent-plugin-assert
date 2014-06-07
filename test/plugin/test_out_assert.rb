require 'helper'

class AssertOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    add_prefix hoge
    <case>
      mode type
      key hoge
      data_type date
      time_format %Y-%m-%d
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
    d.emit({'hoge' => "2014-01-01"}, time)
  end
end
