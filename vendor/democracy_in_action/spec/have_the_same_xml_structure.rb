require 'nokogiri'
module XmlStructureMatcher
  class SameXmlStructure
    def initialize(expected)  
      @expected = expected  
    end  

    def matches?(target)  
      @target = target  
      xml = Nokogiri.XML(@target)
      @missing = []
      Nokogiri.XML(@expected).traverse do |node|
        next unless node.is_a?(Nokogiri::XML::Element)
        @missing << node.name if xml.search(node.path).empty?
      end
      @missing.empty?
    end  

    def failure_message  
      "expected \n#{@target[0..160]}...\n to " +  
      "have the sames structure as \n#{@expected[0..160]}..." +
      "missing tags: #{@missing.join(' ,')}"
    end  

    def negative_failure_message  
      "expected \n#{@target[0..80]}...\n not to " +  
      "have the same structure as \n#{@expected[0..80]}..."  
    end  
  end  

  # Actual matcher that is exposed.  
  def have_the_same_xml_structure_as(expected)  
    SameXmlStructure.new(expected)
  end  
end  
