module Fluent
  class AssertOutput < Fluent::Output
    Fluent::Plugin.register_output('assert', self)

    MODE_LEN = 'len'
    MODE_TYPE = 'type'
    MODE_REG = 'reg'

    config_param :add_prefix, :string, :default => nil
    config_param :remove_prefix, :string, :default => nil


    # Define `log` method for v0.10.42 or earlier
    unless method_defined?(:log)
      define_method("log") { $log }
    end

    def initialize
      super
    end

    def configure(conf)
      super

      if @remove_prefix
        @removed_prefix_string = @remove_prefix + '.'
      end

      if @add_prefix
        @added_prefix_string = @add_prefix + '.'
      end

      @cases = []
      conf.elements.each do | element |
        case element.name
        when "case"
          @cases << element
        else
          raise Fluent::ConfigError, "Unsupported Elements"
        end
      end
    end

    def emit(tag, es, chain)
      es.each { |time, record|
        chain.next

        assert record
      }
    end

    private

    def assert(record)
      @cases.each do |element|
        check_val = record[element["key"]]

        modes = element["mode"].split(",")
        modes.each do |mode|
          case mode
          when MODE_LEN
            result = valid_len? element, check_val
            # ゴニョゴニョとレコードに詰める文字列を生成する
          when MODE_TYPE
            result = valid_type? element, check_val
            # ゴニョゴニョとレコードに詰める文字列を生成する
          when MODE_REG
            result = valid_reg? element, check_val
            # ゴニョゴニョとレコードに詰める文字列を生成する
          else
            # TODO エラー処理
          end

          p result
        end
      end
    end

    def valid_len?(element, val)
      len = element["len"].split(" ").first.to_i
      comparison = element["len"].split(" ").last

      case comparison
      when "up"
        val.length >= len
      when "down"
        val.length <= len
      when "eq"
        val.length == len
      else
        raise Fluent::ConfigError, "Unsupported Parameter for mode len. parameter = #{element['len']}"
      end
    end

    def valid_type?(element, val)
      case element["data_type"]
      when "integer"
        begin
          Integer(val)
          true
        rescue ArgumentError
          false
        end
      when "float"
        begin
          Float(val)
          true
        rescue ArgumentError
          false
        end
      when "date"
        time_format = element["time_format"]
        begin
          d = DateTime.strptime(val, time_format)
          true
        rescue ArgumentError
          false
        end
      else
        raise Fluent::ConfigError, "Unsupported Parameter for mode len. parameter = #{element['len']}"
      end
    end

    def valid_reg?(element, val)
    end
  end
end
