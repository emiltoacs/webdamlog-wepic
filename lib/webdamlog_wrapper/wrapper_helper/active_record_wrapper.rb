# Use this module as a wrapper for extensional persistent relation, it provide
# support for storage in the db if included in an ActiveRecord::Base inheriting
# class
module WrapperHelper::ActiveRecordWrapper
  
  # wdl -> AR Generic method to sync ActiveRecord with webdamlog relations
  # should extend the chosen ActiveRecord (class level)
  module ClassMethods

    attr_reader :engine, :enginelogger, :wdl_table, :wdl_table_name, :bound

    # Set a callback in the webdamlog relation to update this ActiveRecord
    #
    # The webdamlog relation is supposed to be the same as the name of the class to bind
    def bind_wdl_relation
      @engine = EngineHelper::WLENGINE
      @enginelogger = EngineHelper::WLLOGGER
      # PENDING webdamlog table name is created here if not already created by a
      #   previous call to create_wdl_relation. That may happened if relation
      #   has been defined in the bootstrp program. That could also be passed as
      #   an optional parameter if nedded
      @wdl_table_name ||= "#{WLTools.sanitize!(self.name)}_at_#{EngineHelper::WLENGINE.peername}"
      if @engine.nil?
        @enginelogger.fatal("bind_wdl_relation fails @engine not initialized")
        return false
      else
        # PENDING change check already declared by declaration automatic if not
        if @engine.wl_program.wlcollections.include?(@wdl_table_name)
          cb_id = @engine.register_callback(@wdl_table_name.to_sym) do |tab|
            unless tab.delta.empty?
              # send_deltas tab # Callback sent to wdl
              # tab.each_from_sym([:delta]) do |t|
              tab.each_tick_delta do |t|
                tuple = Hash[t.each_pair.to_a]
                self.new(tuple).save_in_ar
              end
              tab.flush_deltas
            end
          end
          @wdl_table = @engine.tables[@wdl_table_name.to_sym]
          EngineHelper::WLHELPER.register_new_binding @wdl_table_name, self.name
          @enginelogger.debug("WrapperHelper::ActiveRecordWrapper: bind_wdl_relation succed to register callback #{cb_id} for #{@wdl_table_name}")
          @enginelogger.debug("WrapperHelper::ActiveRecordWrapper: #{self} has now methods from wrappers #{self.ancestors[0..2]}...")
          @bound = true
          return true
        else
          @enginelogger.fatal("bind_wdl_relation fails to bind #{@wdl_table_name} not found in webdamlog collection")
          return false
        end
      end
    end

    # Create the wdl relation @param name [String] wdl relation name
    #
    # @param schema [Hash] keys are fields name and values are their type
    #
    # @return [String, Hash, String] name of relation, Hash of the schema,
    # webamlog instruction
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
        @wdl_table_name = nm
      end
      return nm, sch, str
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
  end # ClassMethod

  def self.included(base)
    base.extend(ClassMethods)

    # proper way to do instead of alias_method to keep reference of overridden
    # function
    old_save = base.instance_method(:save)
    # Override ActiveRecord save to perform some wdl validation before calling
    # super to insert in database AR -> wdl tricks to plug some webdamlog in an
    # ActiveRecord should be include by the chosen ActiveRecord
    
    self.send :define_method, :save do |*args|

      if args.first == :skip_ar_wrapper # skip when you want to call the original save of ActiveRecord in ClassMethods::send_deltas
        # do not use argument here since save use argument only when mixed in
        # with ActiveRecord::Validations http://stackoverflow.com/questions/9649193/ruby-method-arguments-with-just-operator-def-save-end
        # .() is ruby1.9 syntax for call #old_save.bind(self).()
        return super()
      else
        if valid?
          if self.class.wdl_valid?
            # format for insert into webdamlog
            tuple = []
            wdlfact = nil
            columns = self.class.wdl_table.cols 
            columns.each_with_index do |col, i|
              if self.class.column_names.include?(col.to_s)
                tuple[i] = self.send(col)
              else
                errors.add(:invalid, "tuple #{self} impossible to insert in webdalog it lacks attribute #{col}")
                return false
              end
            end
            wdlfact = { self.class.wdl_table_name => [tuple] }
            # insert in database
            if wdlfact
              begin
                val, err = EngineHelper::WLENGINE.update_add_fact(wdlfact)
              rescue => error
                WLLogger.logger.warn "Error while adding facts to WebdamLog : #{error.message} at #{error.backtrace[0..20].join("\n")}"
              end
              #If val not added properly, add anyway              
              values = {} 
              if err and err.empty?
                columns.each_with_index do |col,i|
                  values[col] = val.values.first.first[i]
                end
                unless self.class.where(values).first #If not added, force add
                  WLLogger.logger.warn "Fact had to be forcefully inserted, although it is in webdamlog, it wasn't put into the database properly!"
                  self.save(:skip_ar_wrapper)
                end
              elsif val.nil?
                #Force the fact to be inserted. This will create 
                WLLogger.logger.warn "Fact had to be forcefully inserted because update_add_fact did not return a value!"
                self.save(:skip_ar_wrapper)
              end
              
              # useless to call super here since callback in table will do the
              # job just check return value val to see if fact has be added in
              # wdl
              if err and val and err.empty? and not val.empty?
                return true
              elsif err and val
                errors.add(:database, "fail to save the record #{self} in the database for wdl_table: #{self.class.wdl_tabname} with error #{err} but the following have succed #{val}")
                return false
              else
                return false #error message already shown
              end
            else
              errors.add(:database, "error: empty fact disallowed from record #{self} for wdl_table: #{self.class.wdl_tabname}")
              return false
            end
          else
            errors.add(:tuple, "webdamlog considered it as invalid")
            return false
          end # if wdl_valid?
        else
          errors.add(:tuple, "ActiveRecord considered it as invalid")
          return false
        end # if valid?
      end # if args.first == :skip_ar_wrapper  
    end # define_method
  end # self.included
  
  # To invoke the original call of AR @return [Boolean] AR#save return value
  def save_in_ar
    if self.valid?
      self.class.superclass.instance_method(:save).bind(self).call
    else
      self.enginelogger.fatal("wdl derived an invalid tuple for AR: #{self}")
      raise Exceptions::WrapperError, "wdl derived an invalid tuple for AR: #{self}"
    end
  end
end