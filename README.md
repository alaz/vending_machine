# What

A famous "vending machine" coding task implemented as

* [Ruby Ractor](https://docs.ruby-lang.org/en/master/ractor_md.html), because
  * a state is securely locked and hidden inside Ractor;
  * "timeout on waiting" can be easily implemented;
* state pattern, i.e. every state accepts only actions applicable in that state.

# Install

```
brew install rbenv
rbenv install
bundle
```

# Test

```
bundle exec rake test
```

# How to play

```
$ bundle exec rake console
```

Initialize the vending machine:

```
irb(main):001:0> vm = VendingMachine.new({coke: 53}, [1, 5, 10, 25, 50, 100]).create
<internal:ractor>:267: warning: Ractor is experimental, and the behavior may change in future versions of Ruby! Also there are many implementation issues.                                                                  
The vending machine is ready                                                                                  
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>                     
irb(main):002:0> vm << :dump
{:inventory=>{:coke=>0}, :till=>{100=>0, 50=>0, 25=>0, 10=>0, 5=>0, 1=>0}, :config=>#<struct VendingMachine prices={:coke=>53}, denominations=[100, 50, 25, 10, 5, 1]>, :state=>:ready}                                     
The vending machine is ready                                                                                  
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>                      
```

## Load inventory

```
irb(main):003:0> vm << :maintenance
The vending machine is disabled
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>                     
irb(main):004:0> vm << [:replace_inventory, {coke: 2}]
The vending machine is disabled
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>                      
irb(main):005:0> vm << :operate
The vending machine is ready
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>    
```

## Wrong product

```
irb(main):006:0> vm << [:pick, :pepsi]
Incorrect product pepsi
The vending machine is ready                                                                
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>    
```

## Purchase and get some change

```
irb(main):007:0> vm << [:pick, :coke]
The vending machine is selling
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>    
irb(main):008:0> vm << [:put, 50]
Awaiting 3
The vending machine is selling                                                              
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>    
irb(main):009:0> vm << [:put, 5]
{:message=>"Sorry, we could not find enough change, returning your coins", :return=>{50=>1, 5=>1}}
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>    
The vending machine is ready                                                                
irb(main):010:0> vm << :dump
{:inventory=>{:coke=>2}, :till=>{100=>0, 50=>0, 25=>0, 10=>0, 5=>0, 1=>0}, :config=>#<struct VendingMachine prices={:coke=>53}, denominations=[100, 50, 25, 10, 5, 1]>, :state=>:ready}                   
The vending machine is ready                                                      
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>
irb(main):016:0> vm << [:pick, :coke]
The vending machine is selling
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>
irb(main):017:0> vm << [:put, 5]
Awaiting 48
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>
The vending machine is selling   
irb(main):018:0> vm << [:put, 25]
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>
Awaiting 23
The vending machine is selling
irb(main):019:0> vm << [:put, 10]
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>
Awaiting 13
The vending machine is selling
irb(main):020:0> vm << [:put, 10]
Awaiting 3
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>
The vending machine is selling
irb(main):021:0> vm << [:put, 1]
Awaiting 2
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>
The vending machine is selling
irb(main):022:0> vm << [:put, 1]
Awaiting 1
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>
The vending machine is selling
irb(main):023:0> vm << [:put, 1]
{:message=>"Enjoy your purchase! Please do not forget your change", :return=>{100=>0, 50=>0, 25=>0, 10=>0, 5=>0, 1=>0}}
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>
The vending machine is ready
irb(main):024:0> vm << :dump
{:inventory=>{:coke=>1}, :till=>{100=>0, 50=>0, 25=>1, 10=>2, 5=>1, 1=>3}, :config=>#<struct VendingMachine prices={:coke=>53}, denominations=[100, 50, 25, 10, 5, 1]>, :state=>:ready}
The vending machine is ready     
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>
irb(main):025:0> vm << [:pick, :coke]
The vending machine is selling
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>
irb(main):026:0> vm << [:put, 50]
Awaiting 3
The vending machine is selling   
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>
irb(main):027:0> vm << [:put, 25]
{:message=>"Enjoy your purchase! Please do not forget your change", :return=>{100=>0, 50=>0, 25=>0, 10=>2, 5=>0, 1=>2}}
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>
The vending machine is ready
```

## Out of stock

```
irb(main):030:0> vm << [:pick, :coke]
Out of stock
The vending machine is ready     
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>
```

## Reload inventory

```
irb(main):033:0> vm << :dump
{:inventory=>{:coke=>0}, :till=>{100=>0, 50=>1, 25=>2, 10=>0, 5=>1, 1=>1}, :config=>#<struct VendingMachine prices={:coke=>53}, denominations=[100, 50, 25, 10, 5, 1]>, :state=>:ready}
The vending machine is ready     
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>
irb(main):034:0> vm << :maintenance
The vending machine is disabled
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>
irb(main):035:0> vm << [:replace_inventory, {coke: 2}]
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>
The vending machine is disabled                                                   
irb(main):036:0> vm << :operate
The vending machine is ready
```

## Cannot find change

```
irb(main):039:0> vm << [:pick, :coke]
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>
The vending machine is selling                                                    
irb(main):040:0> vm << [:put, 100]
{:message=>"Sorry, we could not find enough change, returning your coins", :return=>{100=>1}}
The vending machine is ready                                                      
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>
```

## Timeout waiting for coins

```
irb(main):041:0> vm << [:pick, :coke]
The vending machine is selling
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 running>
irb(main):042:0> vm << [:put, 50]
Awaiting 3
The vending machine is selling
=> #<Ractor:#3 /Users/alaz/Downloads/vending_machine/lib/vending_machine.rb:144 blocking>
irb(main):043:0> {:message=>"We have waited for too long, aborting now. Do not forget your money!", :return=>{50=>1}}
The vending machine is ready
```
