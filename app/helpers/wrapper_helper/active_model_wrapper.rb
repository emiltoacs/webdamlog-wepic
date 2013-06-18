# Use this module as a wrapper for intentional relation
module WrapperHelper::ActiveModelWrapper

  module ClassMethods

    attr_reader :engine, :enginelogger, :wdl_tabname, :wdl_tabname, :bound
    
    # Sync with the webdamlog relation supposed to be the same as the name of
    # the class to bind
    def bind_wdl_relation
      @engine = EngineHelper::WLENGINE
      @enginelogger = EngineHelper::WLLOGGER
      # PENDING webdamlog table name is created here if not already created by a
      #   previous call to create_wdl_relation. That may happened if relation
      #   has been defined in the bootstrp program. That could also be passed as
      #   an optional parameter if nedded
      @wdl_tabname ||= "#{WLTools.sanitize!(self.name)}_at_#{EngineHelper::WLENGINE.peername}"
      if @engine.nil?
        @enginelogger.fatal("bind_wdl_relation fails @engine not initialized")
        return false
      else
        # PENDING change check already declared by declaration automatic if not
        if @engine.wl_program.wlcollections.include?(@wdl_tabname)
          @wdl_table = @engine.tables[@wdl_tabname.to_sym]
          EngineHelper::WLHELPER.register_new_binding @wdl_tabname, self.name
          @enginelogger.debug("WrapperHelper::ActiveModelWrapper bind_wdl_relation succed to sync #{@wdl_tabname} with #{@self}")
          @bound = true
          return true
        else
          @enginelogger.fatal("bind_wdl_relation fails to bind #{@wdl_tabname} not found in webdamlog collection")
          return false
        end
      end
    end

    # TODO add here some wdl guards
    def wdl_valid?
      if @bound
        true
      else
        false
      end
      return true
    end

    def find(*args)
      # PENDING not useful for now
    end
    def all
      ar = []
      @engine.sync_do { ar = @wdl_table.map{ |t| self.new(Hash[t.each_pair.to_a]) } }
      ar
    end
    def inspect
      @wdl_table.inspect
    end
  end

  def self.included(base)
    base.extend(ClassMethods)    
  end
  
end # WrapperHelper::ActiveModelWrapper