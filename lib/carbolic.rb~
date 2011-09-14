#!/usr/bin/ruby

# file: carbolic.rb

require 'rexle-builder'
require 'rexle'

class Items

  attr_reader :names
  
  def initialize()
    @names = []
  end

  def trace(name)
    @names << name
  end
end


class Carbolic

  def initialize(obj)
    carbolic(obj)
  end
  
  def self.log(log="this_daily.log")
    $carbolic_log = Logger.new(log, 'daily')
    $carbolic_log2 = File.open('trace.txt','w')

    items = Items.new
    yield items
    a = items.names
    c = "def initialize() \
      Carbolic.new(self) if #{a.inspect}.include? self.class.to_s end
      def self.empty?() end"
    Object.class_eval c
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

      require 'rexle-builder'
    
      def x_inspect(x)
        if x.respond_to? :to_s
          (x.inspect.length < 150 ? x.inspect : x.inspect[0..145] + '...')
        else
          " "
        end
      end

      def log_method(a=[], vars=[], raw_args=[])
        instance_vars = vars.map{|x| [x,x_inspect(self.instance_variable_get(x))]}
        label_vars = instance_vars.map{|x| "%s: %s" % x}
        line = "%s, in, %s, " % [self.class, (a + label_vars).flatten.join(', ')]
    
        ffsa_args = raw_args.select {|x| x.class.to_s[/Float|Fixnum|String|Array|TrueClass|FalseClass/] }            
        args = ffsa_args.map{|x| [x.class.to_s, x_inspect(x)]}
        basic_args = args.map {|x| "%s: %s" % x}

        $carbolic_log.debug line << basic_args.join(', ')
        $carbolic_log2.write ",['call','',{},"
        $carbolic_log2.write info_in(self.class, a, instance_vars, args)
        #$carbolic_log2.add Rexle.new()
        $carbolic_log2.write ", ['calls', '', {}"
        r = yield
        $carbolic_log2.write "],"
        label_vars = vars.map{|x| "%s: %s, " % [x,x_inspect(self.instance_variable_get(x))]}
        line = "%s, out, %s, " % [self.class, ([a.first] + label_vars).flatten.join(', ')]
        rval = r.class.to_s[/Float|Fixnum|String|Array|TrueClass|FalseClass/] ? [r.class.to_s, x_inspect(r)] : nil
        line << "%s: %s" % rval if rval
        $carbolic_log.debug line
        
        $carbolic_log2.write info_out(self.class, a.first, instance_vars, rval)
        $carbolic_log2.write "]"
        
        r
      end
    
      def info_in(class_name, origins=[], instance_vars=[], args=[])

        xml = RexleBuilder.new
        a = xml.in do
          xml.class_name class_name.to_s
          xml.origins do
            origins.each do |x|
              xml.origin x
            end
          end
          xml.instance_vars do
            instance_vars.each do |x|
              xml.send x[0].to_s.sub('@',''), x[1].to_s.gsub('"','')
            end
          end
          xml.args do
            args.each do |x|
              xml.send x[0].downcase.sub(/:"/,''), x[1].to_s.gsub('"','')
            end 
          end
        end

        a
      end

      def info_out(class_name, origin, instance_vars=[], r)
        xml = RexleBuilder.new
        a = xml.out do
          xml.class_name class_name.to_s
          xml.origin origin
          xml.instance_vars do
            instance_vars.each do |x|
              xml.send x[0].to_s.sub('@',''), x[1].to_s.gsub('"','')
            end
          end
          xml.send r[0].downcase.sub(':',''), r[1].to_s.gsub('"','') if r
        end

        a
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

    xml = RexleBuilder.new
    xml.class_info do
      xml.summary do
        a.each {|label, val| xml.send(label.to_s + 'x', val) }
      end
      xml.records
    end

    Rexle.new(xml.to_a).xml pretty: true
  end

end

