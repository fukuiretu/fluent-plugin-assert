module Fluent
  class AssertOutput < Fluent::Output
    Fluent::Plugin.register_output('assert', self)

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
      conf.elements.each do |element|
        case element.name
        when "case"
          @cases << element
        else
          raise Fluent::ConfigError, "Unsupported Elements"
        end
      end
    end

    def emit(tag, es, chain)
      es.each {|time, record|
        chain.next

        assert! record
        p record
      }
    end

    private

    def assert!(record)
      cloned_record = nil

      @cases.each.with_index(1) do |element, i|
        key = element["key"]
        val = record[key]

        is_valid = false
        element["mode"].split(",").each do |mode|
          valid_result = send("valid_#{mode}?", element, val)
          is_valid = is_valid || valid_result
        end

        unless is_valid
          if cloned_record.nil?
            cloned_record = record.clone
            record.clear
          end

          record["assert_#{i}"] = {
            "message" => "#{key}=\"#{val}\" is not valid.",
            "case" => element.to_s,
            "origin_record" => cloned_record.to_s
          }
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
        raise Fluent::ConfigError, "Unsupported Parameter for mode len. parameter = #{comparison}"
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
