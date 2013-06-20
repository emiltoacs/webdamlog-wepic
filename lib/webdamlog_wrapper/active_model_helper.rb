module ActiveModelHelper

  class ActiveModelHelper
    include ActiveAttr::Model
    include ActiveSupport::Inflector
    include ActiveAttr::TypecastedAttributes
  end

  # @attribute [String] name of the class to create
  # @attribute [Hash] sym, Const symobol is the key and constant the type that could be choosen among:
  # BigDecimal => BigDecimalTypecaster,
  #      Boolean    => BooleanTypecaster,
  #      Date       => DateTypecaster,
  #      DateTime   => DateTimeTypecaster,
  #      Float      => FloatTypecaster,
  #      Integer    => IntegerTypecaster,
  #      Object     => ObjectTypecaster,
  #      String     => StringTypecaster,
  # see https://github.com/cgriego/active_attr/blob/master/lib/active_attr/typecasting.rb
  def self.create_active_model_class(name, schema)
    raise Exceptions::HelperError.new "type error of name is #{name.class}" unless name.is_a? String
    raise Exceptions::HelperError.new "type error of schema is #{schema.class}" unless schema.is_a? Hash

    model_name = to_model_name(name)
    klass = ActiveModelHelperPool.create model_name, schema
    klass.send :include, WrapperHelper::ActiveModelWrapper
  end

  
  def self.to_model_name table_name
    table_name.classify
  end

  private
  class ActiveModelHelperPool
    class << self

      attr_reader :amhelpers

      # Create the new model with the given name and schema
      def create model_name, schema
        @amhelpers ||= {}
        model_klass = Class.new(ActiveModelHelper) do
          @schema = schema
          schema.each do |var, typ |
            attribute var, :type => typ
            validates_presence_of var
          end          
          def self.schema
            @schema
          end
        end
        Object.const_set model_name.to_sym, model_klass
        @amhelpers[model_klass.object_id] = [model_name, model_klass]
        return model_klass
      end

      # Remove the model from the pool
      def delete obj
        raise(Exceptions::HelperError, "try to delete from the pool the class of a model which is not a Class object type") unless obj.is_a? Class
        klass_name, klass = @amhelpers[obj.object_id]
        @amhelpers.delete(obj.object_id)
        Object.send(:remove_const, klass_name) unless klass_name.nil? or !Object.const_defined?(klass_name)
      end
      
    end # class << self
  end # class ActiveModelHelperPool

end # module ActiveModeleHelper