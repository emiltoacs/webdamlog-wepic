# Wrapper to synchronize rules added in this model with rules in the wdl engine
# This model rely on the {WrapperHelper::ActiveRecordWrapper} wrapper that
# should have been included previously
module WrapperHelper::ContactWrapper

  module ClassMethods
    def bind_wdl_relation      
      super
      # Automatically add self in the list of contact TODO add into
      # wl_program.wlfacts
      str = "fact contact@local( #{engine.peername}, \"#{engine.ip}\", \"#{engine.port}\", true, \"none\" );"
      # add to program via parse for latter loading in load_bootstrap_fact since
      # wlengine is not started yet
      begin
        engine.wl_program.parse(str,true)
        enginelogger.debug("WrapperHelper::ContactWrapper #{self} has now methods from wrappers #{self.ancestors[0..2]}...")
      rescue WLBud::WLError => err
        enginelogger.fatal("WrapperHelper::ContactWrapper #{self} failed to add itself as a new peer while parsing #{str} because #{err}")
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
    
    attr_reader :inst

    # Check that WrapperHelper::ContactWrapper has been added before inclusion
    # of this module
    unless base.ancestors.include? WrapperHelper::ActiveRecordWrapper
      error.add(:wrapper, "wrong inclusion of WrapperHelper::ContactWrapper it should have been inserted after inclusion of WrapperHelper::ActiveRecordWrapper")
    end
    unless base.respond_to? :engine
      error.add(:wrapper, "base class should have an engine linked before inclusion of WrapperHelper::ContactWrapper")
    end
    unless base.respond_to? :enginelogger
      error.add(:wrapper, "base class should have an enginelogger linked before inclusion of WrapperHelper::ContactWrapper")
    end

    # Override save method of previous wrapper usually active_record_wrapper to
    # add rule into the wdl engine before chaining to active_record_wrapper save
    self.send :define_method, :save do |*args|

      if args.first == :skip_ar_wrapper # skip when you want to call the original save of ActiveRecord in ClassMethods::send_deltas
        super()
      else
        engine = self.class.engine

        # PENDING add some guards here to check if a peer is override

        if(self.username and self.ip and self.port)
          if engine.update_add_peer(self.username, self.ip, self.port)
            super()
          else
            errors.add(:contactwrapper, "update_add_peer failed to declare new contact peername#{self.username} ip#{self.ip} #{self.port}")
            return false
          end
        else
          errors.add(:contactwrapper, "some required fact to declare a new peer are missing peername#{self.username} ip#{self.ip} #{self.port}")
          return false
        end

      end # if args.first == :skip_ar_wrapper
    end # base.send :define_method, :save    
  end # self.included(base)

end # module WrapperHelper::ContactWrapper