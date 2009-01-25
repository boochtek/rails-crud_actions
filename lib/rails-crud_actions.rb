$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module BoochTek
  module Rails
    module CrudActions
      VERSION = '0.0.1'
    end
  end
end
