#!/usr/bin/env ruby
#
# Things to cover:
# extracting methods
# Ruby idioms
# composition / inheritance
# randomized heating in fire
# HeatSink object

module HeatDelegator
    def add_heat_recipient(obj)
        @recipients ||= []

        @recipients << obj
    end

    def remove_heat_recipient(obj)
        @recipients.delete(obj)
    end

    def heat_me(amount)
        split = amount / @recipients.size
        @recipients.each do |r|
            puts "#{self.class} heating #{r.class} by #{split}"
            r.heat_me(split)
        end
    end
end

class Stick
    include HeatDelegator

    def initialize(*contents)
        contents.each do |c|
            add_heat_recipient(c)
        end
    end

    def insert(fire)
        fire.add_heat_recipient(self)
    end

    def remove(fire)
        fire.remove_heat_recipient(self)
    end
end

class Fire
    include HeatDelegator

    def initialize(tick_amount=0.1)
        @tick_amount = tick_amount
    end

    def burn
        mult = (Kernel.rand * 10).ceil * 0.1
        real = @tick_amount * mult
        puts "#{self.class} tick amount #{@tick_amount}, multiplier #{mult}, actual burn #{real}"
        heat_me(real)
    end
end

module Toppable
    def top_with(obj)
        @topper = obj
    end

    def print_top_chain
        if @topper
            puts "#{self.class}: My topper is a #{@topper.class}"
            @topper.print_top_chain
        else
            puts "#{self.class}: No topper"
        end
    end
end

class Heatable
    attr_accessor :heat_state

    def initialize(*args)
       @heat_state = 0
    end

    def heat_me(amount)
        @heat_state += amount
        puts "#{self.class} heat went up by #{amount} to #{@heat_state}"
    end
end

class Graham
    include Toppable
end

class Chocolate
    include Toppable
end

class Marshmallow < Heatable
    include Toppable
end

class HeatSink < Heatable
    def initialize(sink_factor)
        @sink_factor = sink_factor
        super
    end

    def heat_me(amount)
        puts "#{self.class}: reducing heat received by #{@sink_factor}"
        super(amount / @sink_factor)
    end
end

class ImprovedSmore
    NOT_QUITE_BURNED = 0.9
    attr_accessor :graham, :chocolate, :marshmallow, :fire, :desired_state

    def initialize(components)
        @graham         = components[:graham]
        @chocolate      = components[:chocolate]
        @marshmallow    = components[:marshmallow]
        @fire           = components[:fire]
        @desired_state  = components[:desired_state]
    end

    private
    def check_requirements
        @fire ||= Fire.new
        @desired_state ||= NOT_QUITE_BURNED

        raise "Need grahams to cook a Smore!" unless @graham
        raise "Need chocolate to cook a Smore!" unless @chocolate
        raise "Need marshmallow to cook a Smore!" unless @marshmallow
        raise "Need fire to cook a Smore!" unless @fire
    end

    def roast
        #s = Stick.new @marshmallow
        s = Stick.new @marshmallow, HeatSink.new(4)
        s.insert @fire
        while @marshmallow.heat_state < @desired_state do
            sleep 1
            @fire.burn
            puts ""
        end
        s.remove @fire
    end

    def build
        @chocolate.top_with @marshmallow
        @graham.top_with @chocolate

        @graham.print_top_chain
    end

    public
    def cook
        check_requirements
        roast
        build
    end
end

# usage:
# s = ImprovedSmore.new
# s.graham = g
# s.chocolate = c
# s.marshmallow = m
# s.fire = f
# s.cook
#
# OR (even better!)
#
if (__FILE__ == $0)
    s = ImprovedSmore.new :graham => Graham.new, :chocolate => Chocolate.new, :marshmallow => Marshmallow.new, :fire => Fire.new
    s.cook
end
