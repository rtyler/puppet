require 'erb'
require 'rexml/document'

class Puppet::Parser::Xml
  NODE_TEMPLATE = ERB.new("""node <%= node_name %> {
                                <%= node_includes %>
                                <%= node_resources %>
                              }
                          """)
  CLASS_TEMPLATE = ERB.new("""class <%= klass_name %> {
                                <%= klass_includes %>
                                <%= klass_resources %>
                              }
                          """)

  def self.to_puppet(xml)
    doc = REXML::Document.new(xml)
    output = ''
    doc.elements.each('puppet/nodes/node') do |element|
      node_name = element.attributes['name']
      node_includes = self.parse_includes(element)
      node_resources = self.parse_resources(element)
      output += NODE_TEMPLATE.result(binding)
    end


    doc.elements.each('puppet/classes/class') do |element|
      klass_name = element.attributes['name']
      klass_resources = self.parse_resources(element)
      klass_includes = self.parse_includes(element)
      output += CLASS_TEMPLATE.result(binding)
    end
    return output
  end

  def self.parse_includes(parent)
    output = ''
    parent.elements.each('includes/include') do |element|
      output += "include #{element.text}\n"
    end
    output
  end

  RESOURCES_TEMPLATE = ERB.new("""<%= resource_type %> {
                                    \"<%= resource_name %>\" :
                                    <%= resources %>
                                  }""")

  def self.parse_resources(parent)
    output = ''
    parent.elements.each('resources') do |element|
      element.elements.each do |child|
        resource_type = child.name
        resource_name = child.attributes['name']
        resources = self.parse_resource(child)
        output += RESOURCES_TEMPLATE.result(binding)
      end
    end
    output
  end

  NOT_QUOTABLE = ['ensure']

  def self.parse_resource(parent)
    output = ''
    count = parent.elements.size
    parent.elements.each_with_index do |child, index|
      if child.name == 'requires'
        # Special case handling for setting multiple require statements since
        # they'll be placed under a <requires/> parent node for optimal XML
        # groovyness
        requires = []
        child.elements.each('require') do |requires_child|
          requires << requires_child.text
        end
        output += "require => [#{requires.join(', ')}]"
      else
        text = "\"#{child.text}\""
        if NOT_QUOTABLE.include? child.name
          text = child.text
        end
        output += "#{child.name} => #{text}"
      end
      if (index + 1) == count
        output += ";"
      else
        output += ","
      end
      output += "\n"
    end
    output
  end
end
