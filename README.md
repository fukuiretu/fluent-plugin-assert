# fluent-plugin-assert, a plugin for [Fluentd](http://fluentd.org)
[![Build Status](https://travis-ci.org/fukuiretu/fluent-plugin-assert.svg?branch=master)](https://travis-ci.org/fukuiretu/fluent-plugin-assert)


# Overview
Output Filter Plugin for assertion the data.By the result of the assertion, and rewrites the record and tag.

# Configuration

## Ex1. length test
```
<match assert.**>
  assert_pass_remove_tag_prefix assert
  assert_fail_tag_prefix fail
  <test>
    mode len
    key txt
    len 4 up
  </test>
</match>
```

### In.
```
assert.data: {"id":1,"txt":"hoge","created_at":"2014-01-01 00:00:00"}
assert.data: {"id":2,"txt":"foo","created_at":"2014-01-01 00:00:00"}
```

### Out.
```
data: {"id":1,"txt":"hoge,"created_at":"2014-01-01 00:00:00"}
fail.assert.data: {"fail_1":{"message":"txt=\"foo\" is assert fail.","test":"<test>\n  mode len\n  key txt\n  len 4 up\n</test>\n","origin_record":"{\"id\"=>1, \"txt\"=>\"foo\", \"created_at\"=>\"2014-01-01 00:00:00\"}"}}
```

## Ex2. type test
```
<match assert.**>
  assert_pass_remove_tag_prefix assert
  assert_fail_tag_prefix fail
  <test>
    mode type
    key txt
    data_type integer
  </test>
</match>
```

### In.
```
assert.data: {"id":1,"txt":"12345","created_at":"2014-01-01 00:00:00"}
assert.data: {"id":2,"txt":"hoge","created_at":"2014-01-01 00:00:00"}
```

### Out.
```
data: {"id":1,"txt":"12345","created_at":"2014-01-01 00:00:00"}
fail.assert.data: {"fail_1":{"message":"txt=\"hoge\" is assert fail.","test":"<test>\n  mode type\n  key txt\n  data_type integer\n</test>\n","origin_record":"{\"id\"=>1, \"txt\"=>\"hoge\", \"created_at\"=>\"2014-01-01 00:00:00\"}"}}
```

## Ex3. type test
```
<match assert.**>
  assert_pass_remove_tag_prefix assert
  assert_fail_tag_prefix fail
  <test>
    mode regexp
    key txt
    regexp_format \Ahoge
  </test>
</match>
```

### In.
```
assert.data: {"id":1,"txt":"hogefoobar","created_at":"2014-01-01 00:00:00"}
assert.data: {"id":2,"txt":"barhogefoo","created_at":"2014-01-01 00:00:00"}
```

### Out.
```
data: {"id":1,"txt":"12345","created_at":"2014-01-01 00:00:00"}
fail.assert.data: {"fail_1":{"message":"txt=\"barhogefoo\" is assert fail.","test":"<test>\n  mode regexp\n  key txt\n  regexp_format \\Ahoge\n</test>\n","origin_record":"{\"id\"=>1, \"txt\"=>\"barhogefoo\", \"created_at\"=>\"2014-01-01 00:00:00\"}"}}
```

## Ex4. mix test
```
<match assert.**>
  assert_pass_remove_tag_prefix assert
  assert_fail_tag_prefix fail
  <test>
    mode type
    key id
    data_type integer
  </test>
  <test>
    mode len,type
    key txt
    len 5 eq
    data_type float
  </test>
  <test>
    mode type
    key created_at
    data_type date
  </test>
</match>
```

### In.
```
assert.data: {"id":1,"txt":"123.4","created_at":"2014-01-01 00:00:00"}
assert.data: {"id":2,"txt":"1234","created_at":"2014-01-01 00:00:00"}
```

### Out.
```
data: {"id":1,"txt":"123.4","created_at":"2014-01-01 00:00:00"}
fail.assert.data: {"fail_1":{"message":"txt=\"1234\" is assert fail.","test":"<test>\n  mode len,type\n  key txt\n  len 5 eq\n  data_type float\n</test>\n","origin_record":"{\"id\"=>1, \"txt\"=>\"1234\", \"created_at\"=>\"2014-01-01 00:00:00\"}"}}
```

# Parameters
### Global
* **assert_pass_remove_tag_prefix** (required)

  Specifies the prefix of the tag to clear the test when passing through

* **assert_fail_tag_prefix** (required)

  Specifies the prefix of the tag to be applied to the test failure

### Test Directive
##### Common Parameters
* **mode** (required)

  Specifies the mode in which to test. It is possible to choose from the following modes. (Multiple selections are allowed, separated by commas)

     1. len : check the length of the value

     2. type : check the type of value

     3. regexp : check in a regular expression value

* **key** (required)

  Specify the value of the key to be checked

* **fail_condition** (optional)

  It specifies the (true or false) condition to be a fail. The default is false.

##### Each Mode Parameters
###### mode: len

* **len**　(required)

  Specify the up or down or eq numbers and separated by spaces.

  Ex: len 5 up

###### mode: type

* **data_type** (required)

  The type is specified to be checked. The following types can be selected.

  1. integer

  2. float

  3. date

* **time_format** (optional)

  It is possible that you specify if you have selected a date. The default is "% Y-% m-% d% H:% S: M%".

###### mode: regexp

* **regexp_format** (required)

  Specify the regular expression

### other

And Logging of Fluentd Parameters...(>=v0.10.43)

 * [Logging of Fluentd](http://docs.fluentd.org/articles/logging#per-plugin-log-fluentd-v01043-and-above)


# ChangeLog

See [CHANGELOG.md](https://github.com/fukuiretu/fluent-plugin-assert/blob/master/CHANGELOG.md) for details.

# Copyright
Copyright:: Copyright (c) 2014- Fukui ReTu License:: Apache License, Version 2.0
