module WrapperHelper

  module ActiveRecordWrapper
    
    def bind_wdl_relation relation_name

      @engine = EngineHelper::WLENGINE
      @enginelogger = EngineHelper::WLLOGGER
      
      if @engine.nil?
        @enginelogger.fatal("bind_wdl_relation fails @engine not initialized")
        return false
      else
        if @engine.wl_program.wlcollections.include?(relation_name)
          cb_id = @engine.register_callback(relation_name.to_sym) do |tab|
            send_deltas tab
          end
          @enginelogger.debug("bind_wdl_relation succed to register callback #{cb_id} for #{relation_name}")
          return true
        else
          @enginelogger.fatal("bind_wdl_relation fails to bind #{relation_name} not found in webdamlog collection")
          return false
        end
      end
    end
    
    def send_deltas tab
      tab.each_from_sym([:delta]) do |t|   
        tuple = Hash[t.each_pair.to_a]
        ar = self.new(tuple)
        ar.save
      end
    end

    # TODO check list of attribute and insertion
    def save(*args)
      if some_condition
        if valid?
          # TODO add_fact in wdl
          super(*args)   # do the original
        else
          errors.add(:database, "wrong")
          return false
        end
      else
        errors.add(:relation, "wrong")
        return false
      end
    end

  end
  
end