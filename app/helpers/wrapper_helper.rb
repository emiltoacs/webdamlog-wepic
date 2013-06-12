module WrapperHelper

  module ActiveRecordWrapper

    # TODO should get the reference to the corresponding collection in wdl
    def bind_wdl_relation relation
      if EngineHelper::WLENGINE.nil?
        errors.add(:webdamlog, "not initialized")
        return false
      else
        if EngineHelper::WLENGINE.wl_program.wl_colletion.include?(relation)
          # TODO assign to proper variable for reuse
          return true
        else
          errros.add(:webdamlog, "no collection in webdamlog program called #{relation}")
          return false
        end
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