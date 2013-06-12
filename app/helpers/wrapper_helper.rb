module WrapperHelper

  module ActiveRecordWrapper

    # Set a callback in the webdamlog relation to update this ActiveRecord
    # 
    # @param [String] relation_name
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

    # Callback sent to wdl
    def send_deltas tab
      tab.each_from_sym([:delta]) do |t|   
        tuple = Hash[t.each_pair.to_a]
        ar = self.new(tuple)
        ar.save
      end
    end

    # Create the wdl relation
    # @param name [String] wdl relation name
    # @param schema [Hash] keys are fields name and values are their type
    # @
    def create_wdl_relation name, schema
      
      @engine = EngineHelper::WLENGINE
      @enginelogger = EngineHelper::WLLOGGER

      str = "collection ext per "
      str << "#{name}("
      schema.each{ |at| str<<"#{at}*," }
      str.slice!(-1)
      str << ");"
      nm, sch = @engine.update_add_collection(str)
      @enginelogger.fatal("fail to create new relation in wdl: #{nm}") if nm.is_a? WLBud::WLError
      return nm, sch
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