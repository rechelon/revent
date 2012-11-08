module AggregateMatchers

  class HaveSameElements
    def initialize(expected)
      @expected = expected
      @expected_set = Set.new expected 
    end

    def matches?(target)
      target_set = Set.new target 
      
      @extra_targets = target_set - @expected_set
      @extra_expected = @expected_set - target_set 
      
      @extra_targets.empty? && @extra_expected.empty? 
    end

    def failure_message
      msg = ""
      if !@extra_targets.empty?      
        msg << "Expected values ["
        msg << @extra_expected.sort.map(&:to_s).join(", ")
        msg << "] not in result.\nResult contains unexpected values ["
        msg << @extra_targets.sort.map(&:to_s).join(", ") << "]"
        msg 
      end
    end

    def negative_failure_message
      "Expected results not to be " + @expected.sort.map(&:to_s).join(", ")
    end
    
  end

  def have_same_elements(something)
    HaveSameElements.new(something)
  end

end
