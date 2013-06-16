# Wrapper to synchronize rules added in this model with rules in the wdl engine
# This model rely on the {WrapperHelper::ActiveRecordWrapper} wrapper that
# should have been included previously
module WrapperHelper::RuleWrapper

  def self.included(base)

    attr_reader :inst

    # Check that WrapperHelper::ActiveRecordWrapper has been added before
    # inclusion of this module
    unless base.ancestors.include? WrapperHelper::ActiveRecordWrapper
      error.add(:wrapper, "wrong inclusion of WrapperHelper::RuleWrapper it should have been inserted after inclusion of WrapperHelper::ActiveRecordWrapper")
    end
    unless base.respond_to? :engine
      error.add(:wrapper, "base class should have an engine linked before inclusion of WrapperHelper::RuleWrapper")
    end

    # Override save method of previous wrapper usually active_record_wrapper to
    # add rule into the wdl engine before chaining to active_record_wrapper save
    self.send :define_method, :save do |*args|
      engine = self.class.engine
      ret = engine.parse(self.wdlrule)
      if ret.is_a? WLBud::WLError
        errors.add(:wdlparser, "wrapper fail to parse the rule: #{ret}")
      else
        ret.each do |inst|
          if inst.is_a? WLBud::WLRule
            begin
              require 'debugger' ; debugger unless inst.show_wdl_format.include?("_at_")
              inst.show_wdl_format.gsub!("_at_", "@")
              rule_id, rule_string = engine.update_add_rule(inst)
              self.wdl_rule_id = rule_id
              self.wdlrule = rule_string
              super()
            rescue WLBud::WLError => err
              errors.add(:wdlengine, "wrapper fail to insert the rule in the webdamlog engine: #{err}")
            end
            # FIXME some temporary code to makes rules with relation works
            # ideally the rulewrapper should not do that king of stuff but
            # delegate to a proper wrapper (maybe a relation classes wrapper) HACKY
          elsif inst.is_a? WLBud::WLCollection
            # TODO add collection into the right model for wepic to see them
            # FIXME should be only one database but still
            schema = {}
            budschema = inst.schema
            list = budschema.keys.map { |it| it.first.to_s } + budschema.values.map { |it| it.first.to_s }
            list.reject! { |item| item.empty? }
            list.each { |key| schema[key]="text" }
            klass, relname, sch, instruction = WLDatabase.databases.values.first.create_model(inst.relname, schema, {wdl: true})
            if klass
              # FIXME id is the object_id it should be some kind of id generated in WLCollection in the fashion of wrlrule_id in WLRule
              self.wdl_rule_id = klass.object_id
              self.wdlrule = instruction
              self.role = "collection"
              super()
            else
              errors.add(:wrapper, "impossible to create model for #{inst.relname} via rule wrapper")
            end
          else
            errors.add(:typing, "wrapper tried to insert a #{inst.class} into described rules is a very bad idea")
          end
        end # ret.each do |inst|
        
      end # if ret.is_a? WLError

    end # base.send :define_method, :save
    
  end # self.included(base)
  
end # module WrapperHelper::RuleWrapper
