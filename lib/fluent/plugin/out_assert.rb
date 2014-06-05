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
        when 'case'
          @cases << element
        else
          raise Fluent::ConfigError, 'Unsupported Elements'
        end
      end
    end

    def emit(tag, es, chain)
      es.each { |time, record|
        chain.next

        check record
      }
    end

    private

    def check(record)
      @cases.each do |element|
        check_val = record[element['key']]

        modes = element['mode'].split(',')
        modes.each do |mode|
          case mode
          when MODE_LEN
            result = check_len element, check_val
            p result
          when MODE_TYPE
            check_type element, check_val
          when MODE_REG
            check_reg element, check_val
          else
            # TODO エラー処理
          end
        end
      end
    end

    def check_len(element, val)
      p val

      len = element['len'].split(' ').first
      comparison = element['len'].split(' ').last

      # case comparison
      # when 'up'
      #   if val.length >= len
      # when 'down'
      #   if val.length <= len
      # end
    end

    def check_type(element, val)
      p val
    end

    def check_reg(element, val)
      p val
    end
  end
end
