# Wrapper to synchronize pictures added in this model with rules in the wdl
# engine This model rely on the {WrapperHelper::ActiveRecordWrapper} wrapper
# that should have been included previously
module WrapperHelper::PictureWrapper

  module ClassMethods
    def bind_wdl_relation      
      super
      enginelogger.debug("WrapperHelper::PictureWrapper #{self} has now methods from wrappers #{self.ancestors[0..2]}...")
      end # 
  end

  def self.included(base)
    base.extend(ClassMethods)

    # Check that WrapperHelper::ActiveRecordWrapper has been added before
    # inclusion of this module
    unless base.ancestors.include? WrapperHelper::ActiveRecordWrapper
      error.add(:wrapper, "wrong inclusion of WrapperHelper::PictureWrapper it should have been inserted after inclusion of WrapperHelper::ActiveRecordWrapper")
    end
    unless base.respond_to? :engine
      error.add(:wrapper, "base class should have an engine linked before inclusion of WrapperHelper::RuleWrapper")
    end

    # Override save method of previous wrapper usually active_record_wrapper to
    # add picture into the wdl engine if the callback in save has not done it properly
    # Order of operations :
    # XXX 
    # 1. Picture is saved in active_record (bypass wrapper).
    # 2. Url is generated (requires previously)
    # 3. Picture is saved for webdamlog only.(needs url)
    # IMPORTANT : The above behavior has been switched to the Picture Model
    self.send :define_method, :save do |*args|
      if args.first==:no_skip
        super()
      else
        super(:skip_ar_wrapper)
      end
    end # self.send :define_method, :save
        
  end # def self.included(base)

  #XXX Changed here
  def save_in_ar
    if self.valid?
      self.class.superclass.instance_method(:save).bind(self).call
    else
      self.enginelogger.fatal("wdl derived an invalid tuple for AR: #{self}")
      raise Exceptions::WrapperError, "wdl derived an invalid tuple for AR: #{self}"
    end
  end 
end # module WrapperHelper::PictureWrapper
