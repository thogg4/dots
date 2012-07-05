#!/usr/bin/ruby
require 'irb/completion'
require 'rubygems'


IRB.conf[:PROMPT_MODE] = :SIMPLE

IRB.conf[:AUTO_INDENT] = true

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
  
  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    puts `ri '#{method}'`
  end
end

def r
  reload!
end


# Break out of the Bundler jail
# from https://github.com/ConradIrwin/pry-debundle/blob/master/lib/pry-debundle.rb
if defined? Bundler
  begin
    Gem.post_reset_hooks.reject! { |hook| hook.source_location.first =~ %r{/bundler/} }
    Gem::Specification.reset
    load 'rubygems/custom_require.rb'
  rescue LoadError
  end
end

if defined? Rails
  begin
    puts "loading hirb"
    require 'hirb'
    Hirb.enable
    puts "hirb loaded"
  rescue LoadError
  end
end
