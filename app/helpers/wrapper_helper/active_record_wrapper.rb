# Generic method to sync ActiveRecord with webdamlog relations
module ActiveRecordWrapper

  attr_reader :engine, :enginelogger, :wdl_tabname

  # Set a callback in the webdamlog relation to update this ActiveRecord
  #
  # @param [String] relation_name
  def bind_wdl_relation
    @engine = EngineHelper::WLENGINE
    @enginelogger = EngineHelper::WLLOGGER
    # PENDING webdamlog table name is created here if not already created by a previous
    # call to create_wdl_relation. That may happened if relation has been
    # defined in the bootstrp program. That could also be passed as an optional parameter if nedded
    @wdl_tabname ||= "#{WLTools.sanitize!(self.name)}_at_#{EngineHelper::WLENGINE.peername}"
    if @engine.nil?
      @enginelogger.fatal("bind_wdl_relation fails @engine not initialized")
      return false
    else
      p ""
      p @wdl_tabname
      p @engine.wl_program.wlcollections.keys
      p ""
      if @engine.wl_program.wlcollections.include?(@wdl_tabname)
        cb_id = @engine.register_callback(@wdl_tabname.to_sym) do |tab|
          send_deltas tab
        end        
        @enginelogger.debug("bind_wdl_relation succed to register callback #{cb_id} for #{@wdl_tabname}")
        EngineHelper::WLHELPER.register_new_binding @wdl_tabname, self.name
        return true
      else
        @enginelogger.fatal("bind_wdl_relation fails to bind #{@wdl_tabname} not found in webdamlog collection")
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

  # Create the wdl relation @param name [String] wdl relation name @param schema
  # [Hash] keys are fields name and values are their type @
  def create_wdl_relation schema
    @engine = EngineHelper::WLENGINE
    @enginelogger = EngineHelper::WLLOGGER
    
    wdl_dec_coll = "#{WLTools.sanitize(self.name)}@#{EngineHelper::WLENGINE.peername}"
    str = "collection ext per "
    str << "#{wdl_dec_coll}("
    schema.keys.each { |at| str<<"#{at}*," }
    str.slice!(-1)
    str << ");"
    nm, sch = @engine.update_add_collection(str)
    
    if nm.is_a? WLBud::WLError
      @enginelogger.fatal("fail to create new relation in wdl: #{nm}")
    else
      @wdl_tabname = nm
    end
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
  