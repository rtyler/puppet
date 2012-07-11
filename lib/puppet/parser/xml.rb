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

  def self.to_catalog(xml)
    catalog = Puppet::Resource::Catalog.new
    doc = REXML::Document.new(xml)

    # Lots of duplication 
    doc.elements.each('puppet/node') do |element|
      node = Puppet::Node.new(element.attributes['name'])
      catalog.add_class(node)
    end

    doc.elements.each('puppet/class') do |element|
      resource = Puppet::Resource.new(:class, element.attributes['name'])
      catalog.add_resource(resource)
      element.children.each  do |child|
        next if child.instance_of? REXML::Text
        child_resource = Puppet::Resource.new(child.name.to_sym,
                                 child.attributes['name'])
        properties_as_hash(child).each do |key, value|
          child_resource[key] = value
        end
        catalog.add_resource(child_resource)
        catalog.add_edge(resource, child_resource)
      end
    end
    catalog
  end

  def self.properties_as_hash(resourceNode)
    result = {}
    resourceNode.children.each do |child|
      next if child.instance_of? REXML::Text
      next if child.name == 'name'
      result[child.name.to_sym] = child.text.strip
    end
    result
  end

  def self.to_puppet(xml)
    doc = REXML::Document.new(xml)
    output = ''
    doc.elements.each('puppet/node') do |element|
      node_name = element.attributes['name']
      node_includes = self.parse_includes(element)
      node_resources = self.parse_resources(element)
      output += NODE_TEMPLATE.result(binding)
    end


    doc.elements.each('puppet/class') do |element|
      klass_name = element.attributes['name']
      klass_resources = self.parse_resources(element)
      klass_includes = self.parse_includes(element)
      output += CLASS_TEMPLATE.result(binding)
    end
    return output
  end

  def self.parse_includes(parent)
    output = ''
    parent.elements.each('include') do |element|
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
    parent.children.each do |element|
      next if element.instance_of? REXML::Text
      resource_type = element.name
      next if resource_type == 'include'

      resource_name = element.attributes['name']
      resources = []

      element.each do |child|
        resources << self.parse_resource(child)
      end

      resources = resources.compact.join(",\n")
      resources += ';'

      output += RESOURCES_TEMPLATE.result(binding)
    end
    output
  end

  NOT_QUOTABLE = ['present']

  def self.parse_resource(element)
    # will get called for each child, [whitespace, <ensure>, whitespace ]
    if element.instance_of? REXML::Text
      text = element.to_s
      unless text.strip.empty?
        return text
      else
        return nil
      end
    end

    name = element.attributes['name']
    text = element.text

    unless (NOT_QUOTABLE.include? text) || (element.name == 'require')
      text = "\"#{text}\""
    end

    return "#{element.name} => #{text}"
  end
end
