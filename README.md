# Introducing the Carbolic gem v0.3

The Carbolic gem is used for tracing the instruction path of your gem after it is exectuted.  It's intended to make debugging easier especially when your code raises an error and it's location in the code isn't convenient to track down.

    require 'carbolic'

    class Welcome
      def initialize()
        super()
        @user = 'guest'
      end

      def fun(name)
        puts 'hello ' + name
        authorised? ? true : false
      end

      def authorised?()
        @user == 'admin'
      end
    end

    Carbolic.log('/home/james/learning/ruby/temp/rexle.log') do |x| 
      x.trace('Welcome')
    end

    welcome = Welcome.new
    welcome.fun 'JR'  

## Output

There are 3 files created, which are:

* class_Welcome.xml
* rexle.log
* trace.txt

We are only interested in the rexle.log which is shown below:

    # Logfile created on 2011-09-14 16:09:13 +0100 by logger.rb/25413
    D, [2011-09-14T16:09:14.585694 #5245] DEBUG -- : Welcome, in, fun, irb_binding, @user: "guest", String: "JR"
    D, [2011-09-14T16:09:14.587226 #5245] DEBUG -- : Welcome, in, authorised?, fun, @user: "guest", 
    D, [2011-09-14T16:09:14.588861 #5245] DEBUG -- : Welcome, out, authorised?, @user: "guest", , FalseClass: false
    D, [2011-09-14T16:09:14.590041 #5245] DEBUG -- : Welcome, out, fun, @user: "guest", , FalseClass: false

Here's the output from class_Welcome.xml

    <?xml version='1.0' encoding='UTF-8'?>
    <class_info>
      <summary>
        <public_methodsx>authorised?, fun</public_methodsx>
        <private_methodsx></private_methodsx>
        <protected_methodsx></protected_methodsx>
        <singleton_methodsx></singleton_methodsx>
        <classx>Welcome</classx>
        <object_idx>81071970</object_idx>
        <instance_variablesx></instance_variablesx>
      </summary>
      <records></records>
    </class_info>

Trace.txt is part of the experimental output in raw Rexle format which is still under development.

