require 'rexml/document'

class Puppet::Parser::Xml
  def self.to_puppet(xml)
    doc = REXML::Document.new(xml)
    output = ''
    doc.elements.each('puppet/nodes/node') do |element|
      node_name = element.attributes['name']

      output += """node #{node_name} {\n"""
      output += self.parse_includes(element)
      output += self.parse_resources(element)
      output += """}"""
    end

    doc.elements.each('puppet/classes/class') do |element|
      class_name = element.attributes['name']

      output += """class #{class_name} {\n"""
      output += self.parse_includes(element)
      output += self.parse_resources(element)
      output += """}"""
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

  def self.parse_resources(parent)
    output = ''
    parent.elements.each('resources') do |element|
      element.elements.each do |child|
        output += "#{child.name} {\n"
        output += "\"#{child.attributes['name']}\" :\n"
        output += self.parse_resource(child)
        output += "}"
      end
    end
    output
  end

  def self.parse_resource(parent)
    output = ''
    count = parent.elements.size
    parent.elements.each_with_index do |child, index|
      output += "#{child.name} => #{child.text}"
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
