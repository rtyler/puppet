
dir = File.expand_path(File.join(File.dirname(__FILE__), '/../../'))
puts dir
$LOAD_PATH.unshift File.join(dir, 'lib')

require 'puppet'
