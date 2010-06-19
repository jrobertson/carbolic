#!/usr/bin/ruby

# file: carbolic.rb

require 'builder'

class Carbolic

  def initialize(obj)
    carbolic(obj)
  end

  private

  def carbolic(obj)

    a = [[:public_methods, (obj.public_methods - Object.public_methods)],
    [:private_methods, ((obj.private_methods - Object.private_methods) - [:autoload, :autoload?])],
    [:protected_methods, (obj.protected_methods - Object.protected_methods)],
    [:singleton_methods, obj.singleton_methods],
    [:class, obj.class],
    [:object_id, obj.object_id],
    [:instance_variables, obj.instance_variables]]

    h = Hash[*a.flatten(1)]
    File.open("class_#{h[:class]}.xml",'w'){|f| f.write store(a)}    

    obj.instance_eval(){

      def x_inspect(x)
        if x.respond_to? :to_s
          (x.inspect.length < 150 ? x.inspect : x.inspect[0..145] + '...')
        else
          " "
        end
      end

      def log_method(a=[], vars=[], args=[]) 
        label_vars = vars.map{|x| "%s: %s" % [x,x_inspect(self.instance_variable_get(x))]}
        line = "in, %s, " % (a + label_vars).flatten.join(', ')
        basic_args = args.map do |x| 
          x.class.to_s[/Float|Fixnum|String|Array/] ? ("%s: %s" % [x.class, x_inspect(x)]) : nil
        end
        basic_args.compact!
        $carbolic_log.debug line << basic_args.join(', ')
        r = yield
        label_vars = vars.map{|x| "%s: %s, " % [x,x_inspect(self.instance_variable_get(x))]}
        line = "out, %s, " % ([a.first] + label_vars).flatten.join(', ')
        line << "%s: %s" % [r.class, x_inspect(r)] if r.class.to_s[/Float|Fixnum|String|Array/] 
        $carbolic_log.debug line
        r
      end
    }
    
    methodx = []    
    method_names = %w(public_methods private_methods protected_methods singleton_methods)
    methodx << method_names.map do |method_name|
      h[method_name.to_sym].map do |x| 
        %Q(alias basic_#{x} #{x}
        def #{x}(*args, &block)
          a = caller(0)[0..1].map {|x| x[/[a-zA-Z\?\_\!0-9\+\-\=\*\\/]+(?=.$)/]}
          vars = self.instance_variables          
          log_method(a,vars,args){basic_#{x}(*args,&block)}
        end)
      end
    end
    obj.instance_eval(methodx.join("\n"))

  end

  def store(a)

    a.map!{|label, value| [label, value.is_a?(Array) ? value.sort.join(', ') : value.to_s]}

    xml = Builder::XmlMarkup.new( :target => buffer='', :indent => 2 )
    xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"

    xml.class_info do
      xml.summary do
        a.each {|label, val| xml.send(label.to_s + 'x', val) }
      end
      xml.records
    end

    buffer.gsub('x>','>')  
  end

end

