module Fluent
  class AssertOutput < Fluent::Output
    Fluent::Plugin.register_output("assert", self)

    config_param :assert_true_remove_tag_prefix, :string, :default => nil
    config_param :assert_false_tag_prefix, :string, :default => nil


    # Define `log` method for v0.10.42 or earlier
    unless method_defined?(:log)
      define_method("log") { $log }
    end

    def initialize
      super
    end

    def configure(conf)
      super

      if @assert_false_tag_prefix
        @assert_false_tag_prefix_string = @assert_false_tag_prefix + '.'
      end

      if @assert_true_remove_tag_prefix
        @assert_true_remove_tag_prefix_string = @assert_true_remove_tag_prefix + '.'
        @removed_length = @assert_true_remove_tag_prefix_string.length
      end

      @cases = []
      conf.elements.each do |element|
        if element.name == "case"
          @cases << element
        else
          raise Fluent::ConfigError, "Unsupported Elements"
        end
      end
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        chain.next

        tag =
          if assert!(record)
            tag[@removed_length..-1]
          else
            @assert_false_tag_prefix_string + tag
          end

        Fluent::Engine.emit(tag, time, record)
      end
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
          log.debug "#{key} is assert false. value=#{val}"

          if cloned_record.nil?
            cloned_record = record.clone
            record.clear
          end

          record[:"assert_#{i}"] = {
            message: "#{key}=\"#{val}\" is assert false.",
            case: element.to_s,
            origin_record: cloned_record.to_s
          }
        end
      end

      cloned_record.nil?
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
        time_format = element["time_format"]
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
