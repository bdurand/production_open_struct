# frozen_string_literal: true

require_relative "spec_helper"

# Run the specs both before and after overriding OpenStruct behavior.
%w[without with].each do |behavior|
  describe "OpenStruct #{behavior} ProductionOpenStruct" do
    after(:all) do
      OpenStruct.prepend(ProductionOpenStruct)
    end

    it "should be testing the correct behavior" do
      expect(behavior).to eq(OpenStruct.include?(ProductionOpenStruct) ? "with" : "without")
    end

    it "should have getters and setters for the hash keys" do
      object = OpenStruct.new(foo: "bar")

      expect(object.foo).to eq "bar"
      expect(object.respond_to?(:foo)).to eq true
      expect(object.respond_to?(:foo)).to eq true
      expect(object.respond_to?(:foo=)).to eq true

      object.foo = "bap"
      expect(object.foo).to eq "bap"
    end

    it "should dynamicaly add getters and setters" do
      object = OpenStruct.new(foo: "bar")

      expect(object.biz).to eq nil
      expect(object.respond_to?(:biz)).to eq false
      expect(object.respond_to?(:biz)).to eq false
      expect(object.respond_to?(:biz=)).to eq false

      object["biz"] = "buz"
      expect(object.biz).to eq "buz"
      expect(object.respond_to?(:biz)).to eq true
      expect(object.respond_to?(:biz)).to eq true
      expect(object.respond_to?(:biz=)).to eq true
    end

    it "should remove getters and setters" do
      object = OpenStruct.new(foo: "bar")
      expect(object.delete_field(:foo)).to eq "bar"
      expect(object.foo).to eq nil
      expect(object.respond_to?(:foo)).to eq false
      expect(object.respond_to?(:foo)).to eq false
      expect(object.respond_to?(:foo=)).to eq false
    end

    it "should raise a NameError when deleting a field that does not exist" do
      object = OpenStruct.new(foo: "bar")
      expect { object.delete_field(:nope) }.to raise_error(NameError, /nope/)
    end

    it "should return the result of the block when deleting a field that does not exist" do
      # The block form of delete_field was added to the standard library in ostruct 0.5.0.
      stock_supports_block = defined?(OpenStruct::VERSION) && Gem::Version.new(OpenStruct::VERSION) >= Gem::Version.new("0.5.0")
      unless OpenStruct.include?(ProductionOpenStruct) || stock_supports_block
        skip "delete_field does not accept a block in this version of ostruct"
      end

      object = OpenStruct.new(foo: "bar")
      expect(object.delete_field(:nope) { 42 }).to eq 42
    end

    it "should remove singleton accessors left over from before the module was prepended" do
      object = OpenStruct.new(legacy: "value")
      object.singleton_class.send(:define_method, :legacy) { @table[:legacy] }
      object.singleton_class.send(:define_method, :legacy=) { |x| @table[:legacy] = x }

      object.delete_field(:legacy)
      expect(object.legacy).to eq nil
      expect(object.respond_to?(:legacy)).to eq false
      expect(object.respond_to?(:legacy=)).to eq false
    end

    it "should raise an ArgumentError when calling a setter with the wrong number of arguments" do
      object = OpenStruct.new(foo: "bar")
      expect { object.send(:foo=, 1, 2) }.to raise_error(ArgumentError)
      expect(object.foo).to eq "bar"
    end

    it "should raise a NoMethodError when calling an undefined method with arguments" do
      object = OpenStruct.new(foo: "bar")
      expect { object.undefined_thing(1) }.to raise_error(NoMethodError, /undefined_thing/)
    end

    it "should not allow modifying a frozen object" do
      object = OpenStruct.new(foo: "bar").freeze
      expect(object.foo).to eq "bar"
      # The ostruct bundled with Ruby 2.5 raises RuntimeError rather than FrozenError
      # on writes; FrozenError is a subclass of RuntimeError so this matches both.
      expect { object.foo = "baz" }.to raise_error(RuntimeError)
      expect { object.other = "baz" }.to raise_error(RuntimeError)
      expect { object.delete_field(:foo) }.to raise_error(FrozenError)
      expect(object.foo).to eq "bar"
    end

    it "should not respond to fields on an allocated but uninitialized object" do
      expect(OpenStruct.allocate.respond_to?(:foo)).to eq false
    end

    it "should require removal of attributes for obects to be equal" do
      first_pet = OpenStruct.new(name: "Rowdy", owner: "John Smith")
      second_pet = OpenStruct.new(name: "Rowdy")

      first_pet.owner = nil
      expect(first_pet == second_pet).to eq false

      first_pet.delete_field(:owner)
      expect(first_pet == second_pet).to eq true
    end

    it "should allow keys with spaces" do
      object = OpenStruct.new("my key" => "my value")
      expect(object.send("my key")).to eq "my value"
      expect(object["my key"]).to eq "my value"
    end

    it "should respond to defined methods" do
      object = OpenStruct.new(foo: "bar")
      expect(object.respond_to?(:delete_field)).to eq true
    end
  end
end
