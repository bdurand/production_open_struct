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
      object.delete_field(:foo)
      expect(object.foo).to eq nil
      expect(object.respond_to?(:foo)).to eq false
      expect(object.respond_to?(:foo)).to eq false
      expect(object.respond_to?(:foo=)).to eq false
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
