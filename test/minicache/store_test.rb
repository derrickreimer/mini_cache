require File.dirname(__FILE__) + '/../test_helper.rb'

class MiniCache::StoreTest < Test::Unit::TestCase
  def setup
    @store = MiniCache::Store.new
  end
  
  context "initialize" do
    should "default to empty data" do
      store = MiniCache::Store.new
      assert_equal Hash.new, store.data
    end
    
    should "load seed data" do
      data = { "name" => "Derrick" }
      store = MiniCache::Store.new(data)
      assert_equal data, store.data
    end
  end
  
  context "#get" do
    should "return a value if set" do
      @store.set("name", "Derrick")
      assert_equal "Derrick", @store.get("name")
    end
    
    should "return nil if not set" do
      assert_nil @store.get("name")
    end
  end
  
  context "#set" do
    should "accept the value as an argument" do
      @store.set("name", "Derrick")
      assert_equal "Derrick", @store.get("name")
    end
    
    should "accept the value as a block" do
      @store.set("name") { "Derrick" }
      assert_equal "Derrick", @store.get("name")
    end
  end
  
  context "#set?" do
    should "be true if key has been set" do
      @store.set("name", "Derrick")
      assert_equal true, @store.set?("name")
    end
    
    should "be false if key has not been set" do
      assert_equal false, @store.set?("foobar")
    end
  end
  
  context "#get_or_set" do
    should "set the value if it hasn't already been set" do
      @store.get_or_set("name", "Derrick")
      assert_equal "Derrick", @store.get("name")
    end
    
    should "not set the value if it has already been set" do
      @store.set("name", "Derrick")
      @store.get_or_set("name", "Joe")
      assert_equal "Derrick", @store.get("name")
    end
    
    should "return the value if not already set" do
      assert_equal "Derrick", @store.get_or_set("name", "Derrick")
    end
    
    should "return the value if already set" do
      @store.set("name", "Derrick")
      assert_equal "Derrick", @store.get_or_set("name", "Joe")
    end
    
    should "accept the value as a block" do
      @store.get_or_set("name") { "Joe" }
      assert_equal "Joe", @store.get("name")
    end
  end
  
  context "#unset" do
    should "remove the key-value pair" do
      @store.set("name", "Derrick")
      @store.unset("name")
      assert !@store.data.keys.include?("name")
    end
  end
  
  context "#reset" do
    should "remove all data" do
      @store.set("name", "Derrick")
      @store.reset
      assert_equal Hash.new, @store.data
    end
  end
  
  context "#load" do
    should "append the data to the cache" do
      @store.set("title", "Mr.")
      
      data = { "name" => "Derrick", "occupation" => "Developer" }
      @store.load(data)
      
      all_data = { "title" => "Mr.", "name" => "Derrick", "occupation" => "Developer" }
      assert_equal all_data, @store.data
    end
    
    should "stringify the keys" do
      data = { :name => "Derrick" }
      @store.load(data)
      stringified_data = { "name" => "Derrick" }
      assert_equal stringified_data, @store.data
    end
  end
end