module Fluent
  class AssertOutput < Fluent::Output
    Fluent::Plugin.register_output("assert", self)

    config_param :assert_pass_remove_tag_prefix, :string, :default => nil
    config_param :assert_fail_tag_prefix, :string, :default => nil

    # Define `log` method for v0.10.42 or earlier
    unless method_defined?(:log)
      define_method("log") { $log }
    end

    def initialize
      super
    end

    def configure(conf)
      super

      if @assert_fail_tag_prefix
        @assert_fail_tag_prefix_string = @assert_fail_tag_prefix + '.'
      end

      if @assert_pass_remove_tag_prefix
        assert_pass_remove_tag_prefix_string = @assert_pass_remove_tag_prefix + '.'
        @removed_length = assert_pass_remove_tag_prefix_string.length
      end

      @tests = conf.elements.select { |element|
        element.name == "test"
      }.each do |element|
        element.keys.each do |k|
          element[k]
        end
      end

      if @tests.empty?
        raise Fluent::ConfigError, "test elements is empty."
      end
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        chain.next

        tag =
          if assert!(record)
            tag[@removed_length..-1]
          else
            @assert_fail_tag_prefix_string + tag
          end

        Fluent::Engine.emit(tag, time, record)
      end
    end

    private

    def assert!(record)
      origin_record_str = nil

      @tests.each.with_index(1) do |element, i|
        key = element["key"]
        val = record[key].to_s

        fail_condition =
          if element["fail_condition"].nil?
            "false"
          else
            element["fail_condition"]
          end

        is_success = true
        element["mode"].split(",").each do |mode|
          valid_result = send("valid_#{mode}?", element, val)
          is_success = is_success && valid_result
        end

        if is_success.to_s == fail_condition
          log.debug "#{key} is assert fail. value=#{val}"

          if origin_record_str.nil?
            origin_record_str = record.to_s
            record.clear
          end

          record["assert_#{i}"] = {
            "message" => "#{key}=\"#{val}\" is assert fail.",
            "test" => element.to_s,
            "origin_record" => origin_record_str
          }
        end
      end

      origin_record_str.nil?
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
        raise Fluent::ConfigError, "Unsupported Parameter for mode len. parameter = \"#{comparison}\""
      end
    end

    def valid_type?(element, val)
      data_type = element["data_type"]
      case data_type
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
        time_format =
          if element["time_format"].nil?
            "%Y-%m-%d %H:%M:%S"
          else
            element["time_format"]
          end

        begin
          d = DateTime.strptime(val, time_format)
          true
        rescue ArgumentError
          false
        end
      else
        raise Fluent::ConfigError, "Unsupported Parameter for mode type. parameter = #{data_type}"
      end
    end

    def valid_regexp?(element, val)
      regexp_format = element["regexp_format"]
      !/#{regexp_format}/.match(val).nil?
    end
  end
end
