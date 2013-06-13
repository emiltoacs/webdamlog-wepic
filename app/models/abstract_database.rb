# Super class of all my model used to specify generic properties
#
class AbstractDatabase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection ::Conf.db
  
  def self.insert(values)
    tuple = self.new(values)
    WLLogger.logger.warn "Tuple could not be inserted properly into #{self.table_name} : #{tuple.errors.inspect}" unless tuple.save     
  end

  # Override ActiveRecord save to perform some wdl validation before calling
  # super to insert in database
  def save(*args)
    if valid?
      if wdl_valid?
        # format for insert into webdamlog
        tuple = []
        wdlfact = nil
        @wdl_table.cols.each_with_index do |col, i|
          if self.class.column_names.include?(col.to_s)
            tuple[i] = self.send(col)
          else
            errros.add(:invalid, "tuple #{self} impossible to insert in webdalog it lacks attribute #{col}")
            return false
          end
          wdlfact = { wdl_tabname => [tuple] }
        end
        # insert in database
        unless wdlfact
          val, err = EngineHelper.WLENGINE.update_add_fact(wdlfact)
          if super(*args)
            return true
          else
            errors.add(:databasa, "fail to save record in the database")
            return false
          end
        end
      else
        errors.add(:tuple, "webdamlog considered it as invalid")
        return false
      end
    else
      errors.add(:tuple, "ActiveRecord considered it as invalid")
      return false
    end
  end

  # TODO add here some wdl guards
  def wdl_valid?
    #    if self.bound
    #      true
    #    else
    #      false
    #    end
    return true
  end
end
