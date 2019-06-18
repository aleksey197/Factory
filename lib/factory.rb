# frozen_string_literal: true

# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

# class Factory
class Factory
  class << self
    def new(*parameters, &block)
      if parameters.first.is_a? String
        const_set(parameters.shift.capitalize, class_new(*parameters, &block))
      end
      class_new(*parameters, &block)
    end

    def class_new(*parameters, &block)
      Class.new do
        attr_accessor(*parameters)

        define_method :initialize do |*arg|
          raise ArgumentError, 'invalid argument size' if parameters.size < arg.size

          parameters.each_index do |index|
            instance_variable_set("@#{parameters[index]}", arg[index])
          end
        end

        define_method :[] do |argum|
          if argum.is_a? Integer
            return instance_variable_get instance_variables[argum]
          end

          instance_variable_get "@#{argum}"
        end

        define_method :[]= do |argum, value|
          if argum.is_a? Integer
            return instance_variable_set instance_variables[argum], value
          end

          instance_variable_set "@#{argum}", value
        end

        def each(&block)
          to_a.each(&block)
        end

        define_method :members do
          parameters
        end

        def each_pair(&block)
          members.zip(to_a).each(&block)
        end

        def ==(other)
          self.class == other.class && self.to_a == other.to_a
        end

        alias_method :eql?, :==

        def dig(*keys)
          keys.inject(self) { |values, key| values[key] if values }
        end

        def length
          instance_variables.length
        end

        alias_method :size, :length

        def select(&block)
          to_a.select(&block)
        end

        def to_a
          instance_variables.map { |item| instance_variable_get item }
        end

        def values_at(*itm)
          to_a.select { |val| itm.include?(to_a.index(val)) }
        end

        class_eval(&block) if block_given?
      end
    end
  end
end
