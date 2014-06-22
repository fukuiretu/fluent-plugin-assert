require 'helper'

class AssertOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    assert_pass_remove_tag_prefix assert
    assert_fail_tag_prefix pre.false
    <test>
      mode type
      key hoge
      len 5 up
      data_type date
      time_format %Y-%m-%d
    </test>
  ]

  def create_driver(conf = CONFIG, tag='assert.test')
    Fluent::Test::OutputTestDriver.new(Fluent::AssertOutput, tag).configure(conf)
  end

  def test_configure_1
    d = create_driver
  end

  def test_emit_valid_len_1
    config = %[
      assert_pass_remove_tag_prefix assert
      assert_fail_tag_prefix false
      <test>
        mode len
        key hoge
        len 5 up
      </test>
    ]

    d = create_driver(config)
    time = Time.parse("2012-01-02 13:14:15").to_i
    d.run do
      d.emit({'hoge' => "12345"}, time)
      d.emit({'hoge' => "123456"}, time)
      d.emit({'hoge' => "1234"}, time)
    end

    emits = d.emits

    assert_equal("test", emits[0][0])
    assert_equal(time, emits[0][1])
    assert_equal("12345", emits[0][2]["hoge"])

    assert_equal("test", emits[1][0])
    assert_equal(time, emits[1][1])
    assert_equal("123456", emits[1][2]["hoge"])

    assert_equal("false.assert.test", emits[2][0])
    assert_equal(time, emits[2][1])
    assert_equal("hoge=\"1234\" is assert fail.", emits[2][2]["fail_1"]["message"])
  end

  def test_emit_valid_len_2
    config = %[
      assert_pass_remove_tag_prefix assert
      assert_fail_tag_prefix false
      <test>
        mode len
        key hoge
        len 5 down
      </test>
    ]

    d = create_driver(config)
    time = Time.parse("2012-01-02 13:14:15").to_i
    d.run do
      d.emit({'hoge' => "12345"}, time)
      d.emit({'hoge' => "123456"}, time)
      d.emit({'hoge' => "1234"}, time)
    end

    emits = d.emits

    assert_equal("test", emits[0][0])
    assert_equal(time, emits[0][1])
    assert_equal("12345", emits[0][2]["hoge"])

    assert_equal("false.assert.test", emits[1][0])
    assert_equal(time, emits[1][1])
    assert_equal("hoge=\"123456\" is assert fail.", emits[1][2]["fail_1"]["message"])

    assert_equal("test", emits[2][0])
    assert_equal(time, emits[2][1])
    assert_equal("1234", emits[2][2]["hoge"])
  end

  def test_emit_valid_len_3
    config = %[
      assert_pass_remove_tag_prefix assert
      assert_fail_tag_prefix false
      <test>
        mode len
        key hoge
        len 5 eq
      </test>
    ]

    d = create_driver(config)
    time = Time.parse("2012-01-02 13:14:15").to_i
    d.run do
      d.emit({'hoge' => "12345"}, time)
      d.emit({'hoge' => "123456"}, time)
      d.emit({'hoge' => "1234"}, time)
    end

    emits = d.emits

    assert_equal("test", emits[0][0])
    assert_equal(time, emits[0][1])
    assert_equal("12345", emits[0][2]["hoge"])

    assert_equal("false.assert.test", emits[1][0])
    assert_equal(time, emits[1][1])
    assert_equal("hoge=\"123456\" is assert fail.", emits[1][2]["fail_1"]["message"])

    assert_equal("false.assert.test", emits[2][0])
    assert_equal(time, emits[2][1])
    assert_equal("hoge=\"1234\" is assert fail.", emits[2][2]["fail_1"]["message"])
  end

  def test_emit_valid_type_1()
    config = %[
      assert_pass_remove_tag_prefix assert
      assert_fail_tag_prefix false
      <test>
        mode type
        key hoge
        data_type integer
      </test>
    ]

    d = create_driver(config)
    time = Time.parse("2012-01-02 13:14:15").to_i
    d.run do
      d.emit({'hoge' => "12345"}, time)
      d.emit({'hoge' => "123.45"}, time)
      d.emit({'hoge' => "foo"}, time)
    end

    emits = d.emits

    assert_equal("test", emits[0][0])
    assert_equal(time, emits[0][1])
    assert_equal("12345", emits[0][2]["hoge"])

    assert_equal("false.assert.test", emits[1][0])
    assert_equal(time, emits[1][1])
    assert_equal("hoge=\"123.45\" is assert fail.", emits[1][2]["fail_1"]["message"])

    assert_equal("false.assert.test", emits[2][0])
    assert_equal(time, emits[2][1])
    assert_equal("hoge=\"foo\" is assert fail.", emits[2][2]["fail_1"]["message"])
  end

  def test_emit_valid_type_2()
    config = %[
      assert_pass_remove_tag_prefix assert
      assert_fail_tag_prefix false
      <test>
        mode type
        key hoge
        data_type float
      </test>
    ]

    d = create_driver(config)
    time = Time.parse("2012-01-02 13:14:15").to_i
    d.run do
      d.emit({'hoge' => "12345"}, time)
      d.emit({'hoge' => "123.45"}, time)
      d.emit({'hoge' => "foo"}, time)
    end

    emits = d.emits

    assert_equal("test", emits[0][0])
    assert_equal(time, emits[0][1])
    assert_equal("12345", emits[0][2]["hoge"])

    assert_equal("test", emits[1][0])
    assert_equal(time, emits[1][1])
    assert_equal("123.45", emits[1][2]["hoge"])

    assert_equal("false.assert.test", emits[2][0])
    assert_equal(time, emits[2][1])
    assert_equal("hoge=\"foo\" is assert fail.", emits[2][2]["fail_1"]["message"])
  end

  def test_emit_valid_type_3()
    config = %[
      assert_pass_remove_tag_prefix assert
      assert_fail_tag_prefix false
      <test>
        mode type
        key hoge
        data_type date
      </test>
    ]

    d = create_driver(config)
    time = Time.parse("2012-01-02 13:14:15").to_i
    d.run do
      d.emit({'hoge' => "2013-01-01 00:00:00"}, time)
      d.emit({'hoge' => "2013/01/01"}, time)
    end

    emits = d.emits

    assert_equal("test", emits[0][0])
    assert_equal(time, emits[0][1])
    assert_equal("2013-01-01 00:00:00", emits[0][2]["hoge"])

    assert_equal("false.assert.test", emits[1][0])
    assert_equal(time, emits[1][1])
    assert_equal("hoge=\"2013/01/01\" is assert fail.", emits[1][2]["fail_1"]["message"])
  end

  def test_emit_valid_regexp_1()
    config = %[
      assert_pass_remove_tag_prefix assert
      assert_fail_tag_prefix false
      <test>
        mode regexp
        key hoge
        regexp_format ^ABCDEFG
      </test>
    ]

    d = create_driver(config)
    time = Time.parse("2012-01-02 13:14:15").to_i
    d.run do
      d.emit({'hoge' => "ABCDEFGhogefoo"}, time)
      d.emit({'hoge' => "hogeABCDEFGfoo"}, time)
    end

    emits = d.emits

    assert_equal("test", emits[0][0])
    assert_equal(time, emits[0][1])
    assert_equal("ABCDEFGhogefoo", emits[0][2]["hoge"])

    assert_equal("false.assert.test", emits[1][0])
    assert_equal(time, emits[1][1])
    assert_equal("hoge=\"hogeABCDEFGfoo\" is assert fail.", emits[1][2]["fail_1"]["message"])
  end

  def test_emit_mixing_1()
    config = %[
      assert_pass_remove_tag_prefix assert
      assert_fail_tag_prefix false
      <test>
        mode len,type
        key hoge
        len 5 eq
        data_type integer
      </test>
    ]

    d = create_driver(config)
    time = Time.parse("2012-01-02 13:14:15").to_i
    d.run do
      d.emit({'hoge' => "12345"}, time)
      d.emit({'hoge' => "1234"}, time)
    end

    emits = d.emits

    assert_equal("test", emits[0][0])
    assert_equal(time, emits[0][1])
    assert_equal("12345", emits[0][2]["hoge"])

    assert_equal("test", emits[0][0])
    assert_equal(time, emits[0][1])
    assert_equal("hoge=\"1234\" is assert fail.", emits[1][2]["fail_1"]["message"])
  end

  def test_emit_mixing_2()
    config = %[
      assert_pass_remove_tag_prefix assert
      assert_fail_tag_prefix false
      <test>
        mode len,type
        key hoge
        len 5 eq
        data_type integer
        fail_condition true
      </test>
    ]

    d = create_driver(config)
    time = Time.parse("2012-01-02 13:14:15").to_i
    d.run do
      d.emit({'hoge' => "12345"}, time)
      d.emit({'hoge' => "1234"}, time)
    end

    emits = d.emits

    assert_equal("false.assert.test", emits[0][0])
    assert_equal(time, emits[0][1])
    assert_equal("hoge=\"12345\" is assert fail.", emits[0][2]["fail_1"]["message"])

    assert_equal("test", emits[1][0])
    assert_equal(time, emits[1][1])
    assert_equal("1234", emits[1][2]["hoge"])
  end
end
