# fluent-plugin-assert, a plugin for [Fluentd](http://fluentd.org)


# Overview
Output Filter Plugin for assertion the data.By the result of the assertion, and rewrites the record and tag.

# Configuration

## Ex1. length test
```
<match assert.**>
  assert_pass_remove_tag_prefix assert
  assert_fail_tag_prefix false
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
false.assert.data: {"assert_1":{"message":"txt=\"foo\" is assert fail.","test":"<test>\n  mode len\n  key txt\n  len 4 up\n</test>\n","origin_record":"{\"id\"=>1, \"txt\"=>\"foo\", \"created_at\"=>\"2014-01-01 00:00:00\"}"}}
```

## Ex2. type test
```
<match assert.**>
  assert_pass_remove_tag_prefix assert
  assert_fail_tag_prefix false
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
false.assert.data: {"assert_1":{"message":"txt=\"hoge\" is assert fail.","test":"<test>\n  mode type\n  key txt\n  data_type integer\n</test>\n","origin_record":"{\"id\"=>1, \"txt\"=>\"hoge\", \"created_at\"=>\"2014-01-01 00:00:00\"}"}}
```

## Ex3. type test
```
<match assert.**>
  assert_pass_remove_tag_prefix assert
  assert_fail_tag_prefix false
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
false.assert.data: {"assert_1":{"message":"txt=\"barhogefoo\" is assert fail.","test":"<test>\n  mode regexp\n  key txt\n  regexp_format \\Ahoge\n</test>\n","origin_record":"{\"id\"=>1, \"txt\"=>\"barhogefoo\", \"created_at\"=>\"2014-01-01 00:00:00\"}"}}
```

## Ex4. mix test
```
<match assert.**>
  assert_pass_remove_tag_prefix assert
  assert_fail_tag_prefix false
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
false.assert.data: {"assert_1":{"message":"txt=\"1234\" is assert fail.","test":"<test>\n  mode len,type\n  key txt\n  len 5 eq\n  data_type float\n</test>\n","origin_record":"{\"id\"=>1, \"txt\"=>\"1234\", \"created_at\"=>\"2014-01-01 00:00:00\"}"}}
```

# Parameters
### global
* **assert_pass_remove_tag_prefix** (required)

  Specifies the prefix of the tag to clear the test when passing through

* **assert_fail_tag_prefix** (required)

  Specifies the prefix of the tag to be applied to the test failure

### test directive
##### common parameters
* **mode** (required)

  testするモードを指定します。以下のモードから選ぶことが可能です。(カンマ区切りで複数選択可)

     1. len : 値の長さをチェックします

     2. type : 値の型をチェックします

     3. regexp : 値を正規表現でチェックします

* **key** (required)

  チェック対象となる値のキーを指定します

* **fail_condition** (optional)

  failとする条件(true or false)を指定します。デフォルトはfalseです。

##### each mode parameters
###### mode: len

* **len**　(required)

  数値と、up or down or eqを指定します。
  Ex: len 5 up

###### mode: type

* **data_type** (required)

  チェックする型を指定します。以下の型が選択可能です。

  1. integer

  2. float

  3. date

* **time_format** (optional)

  dateを選択した場合に指定することが可能です。デフォルトは"%Y-%m-%d %H:%M:%S"です。

###### mode: regexp

* **regexp_format** (required)

  正規表現を指定します

### other

And Logging of Fluentd Parameters...(>=v0.10.43)

 * [Logging of Fluentd](http://docs.fluentd.org/articles/logging#per-plugin-log-fluentd-v01043-and-above)


# ChangeLog

See [CHANGELOG.md](https://github.com/fukuiretu/fluent-plugin-assert/blob/master/CHANGELOG.md) for details.

# Copyright
Copyright:: Copyright (c) 2014- Fukui ReTu License:: Apache License, Version 2.0
