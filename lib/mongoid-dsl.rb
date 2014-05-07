
require 'mpatch'
require 'mongoid'
require 'procemon'

Dir.glob( File.join( File.dirname(__FILE__),'**','*.{ru,rb}') ).each{|p|require(p)}
