# Wrapper to synchronize pictures added in this model with rules in the wdl
# engine This model rely on the {WrapperHelper::ActiveRecordWrapper} wrapper
# that should have been included previously
module WrapperHelper::PictureWrapper

  module ClassMethods
    def bind_wdl_relation
      super
      enginelogger.debug("WrapperHelper::PictureWrapper #{self} has now methods from wrappers #{self.ancestors[0..2]}...")
    end
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
    self.send :define_method, :save do |*args|
      super() # ARWrapper invoke
      self.class.enginelogger.debug("WrapperHelper::PictureWrapper has created a new picture in webdamlog #{self} to be linked with record in #{self.class}")
      tuple = Picture.where( title: self.title, _id: self._id, owner: self.owner )
      if tuple.empty? or tuple.nil? # ARInvoke via ARWRapper bypass        
        super(:skip_ar_wrapper)
        self.class.enginelogger.debug("WrapperHelper::PictureWrapper has added #{self} in #{self.class}")
      end
    end # self.send :define_method, :save
        
  end # def self.included(base)

end # module WrapperHelper::PictureWrapper
