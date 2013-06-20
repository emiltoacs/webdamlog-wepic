# Use this module as a wrapper for extensional non-persistent relation
# TODO test it in active_model_helper_test !!!
module WrapperHelper::ActiveModelSaveWrapper

  def self.included(base)
    # Check that WrapperHelper::ActiveRecordWrapper has been added before
    # inclusion of this module
    unless base.ancestors.include? WrapperHelper::ActiveModelWrapper
      error.add(:wrapper, "wrong inclusion of WrapperHelper::RuleWrapper it should have been inserted after inclusion of WrapperHelper::ActiveRecordWrapper")
    end
    unless base.respond_to? :engine
      error.add(:wrapper, "base class should have an engine linked before inclusion of WrapperHelper::RuleWrapper")
    end
    unless base.respond_to? :enginelogger
      error.add(:wrapper, "base class should have an engine linked before inclusion of WrapperHelper::RuleWrapper")
    end
    @enginelogger.debug("WrapperHelper::ActiveModelSaveWrapper #{self} has now methods from wrappers #{self.ancestors[0..2]}...")
  end
  
  def save
    if valid?
      if self.class.wdl_valid?
        # format for insert into webdamlog
        tuple = []
        wdlfact = nil
        self.class.wdl_table.cols.each_with_index do |col, i|
          if self.class.column_names.include?(col.to_s)
            tuple[i] = self.send(col)
          else
            errors.add(:invalid, "tuple #{self} impossible to insert in webdalog it lacks attribute #{col}")
            return false
          end
          wdlfact = { self.class.wdl_tabname => [tuple] }
        end
        # insert in database
        if wdlfact
          val, err = EngineHelper::WLENGINE.update_add_fact(wdlfact)
          if err.empty? and not val.empty?
            return true
          else
            errors.add(:database, "fail to save the record #{self} in the database for wdl_table: #{self.class.wdl_tabname} with error #{err} but the following have succed #{val}")
            return false
          end
        else
          errors.add(:model, "error: empty fact disallowed from record #{self} for wdl_table: #{self.class.wdl_tabname}")
          return false
        end
      else
        errors.add(:tuple, "webdamlog considered it as invalid")
        return false
      end # if wdl_valid?
    else
      errors.add(:tuple, "ActiveModel considered it as invalid")
      return false
    end # if valid?
  end # save

  def self.delete (id)
    # PENDING not useful for now
  end 
  
end # WrapperHelper::ActiveModelSaveWrapper