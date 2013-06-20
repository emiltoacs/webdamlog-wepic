# Wrapper to synchronize pictures added in this model with rules in the wdl
# engine This model rely on the {WrapperHelper::ActiveRecordWrapper} wrapper
# that should have been included previously
module WrapperHelper::PictureWrapper

  module ClassMethods
    def bind_wdl_relation      
      super
      # @engine = EngineHelper::WLENGINE
      # @enginelogger = EngineHelper::WLLOGGER
      # # PENDING webdamlog table name is created here if not already created by a
      # #   previous call to create_wdl_relation. That may happened if relation
      # #   has been defined in the bootstrp program. That could also be passed as
      # #   an optional parameter if nedded
      # @wdl_table_name ||= "#{WLTools.sanitize!(self.name)}_at_#{EngineHelper::WLENGINE.peername}"
      # if @engine.nil?
        # @enginelogger.fatal("bind_wdl_relation fails @engine not initialized")
        # return false
      # else
        # # PENDING change check already declared by declaration automatic if not
        # if @engine.wl_program.wlcollections.include?(@wdl_table_name)
          # cb_id = @engine.register_callback(@wdl_table_name.to_sym) do |tab|
            # unless tab.delta.empty?              
              # # send_deltas tab # Callback sent to wdl
              # require 'debugger';debugger
              # tab.each_from_sym([:delta]) do |t|
                # tuple = Hash[t.each_pair.to_a]
                # self.new(tuple).save(:skip_ar_wrapper)
              # end
              # tab.flush_deltas
            # end
          # end
          # @wdl_table = @engine.tables[@wdl_table_name.to_sym]
          # EngineHelper::WLHELPER.register_new_binding @wdl_table_name, self.name
          # @enginelogger.debug("WrapperHelper::ActiveRecordWrapper: bind_wdl_relation succed to register callback #{cb_id} for #{@wdl_table_name}")
          # @enginelogger.debug("WrapperHelper::ActiveRecordWrapper: #{self} has now methods from wrappers #{self.ancestors[0..2]}...")
          # @bound = true
          # return true
        # else
          # @enginelogger.fatal("bind_wdl_relation fails to bind #{@wdl_table_name} not found in webdamlog collection")
          # return false
        # end
      # end
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
    self.send :define_method, :save do |*args|
      #Integrate with webdamlog
      require 'debugger';debugger
      image = self.image
      image_url = self.image_url
      super(:skip_ar_wrapper)
      config = Conf.peer['peer']
      self.update_attribute(url,"#{config['protocol']}://#{config['ip']}:#{config['web_port']}#{self.image.url}")
      super()
      # super() # ARWrapper invoke
      # self.class.enginelogger.debug("WrapperHelper::PictureWrapper has created a new picture in webdamlog #{self} to be linked with record in #{self.class}")
      # tuple = Picture.where( title: self.title, _id: self._id, owner: self.owner )
      # if tuple.empty? or tuple.nil? # ARInvoke via ARWRapper bypass        
        # super(:skip_ar_wrapper)
        # self.class.enginelogger.debug("WrapperHelper::PictureWrapper has added #{self} in #{self.class}")
      # end
    end # self.send :define_method, :save
        
  end # def self.included(base)

  #XXX Changed here
  def save_in_ar
    if self.valid?
      self.image_url = self.url unless self.image_url
      self.class.superclass.instance_method(:save).bind(self).call
    else
      self.enginelogger.fatal("wdl derived an invalid tuple for AR: #{self}")
      raise Exceptions::WrapperError, "wdl derived an invalid tuple for AR: #{self}"
    end
  end 
end # module WrapperHelper::PictureWrapper
