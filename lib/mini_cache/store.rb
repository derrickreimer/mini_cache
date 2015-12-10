module MiniCache
  class Store
    include Enumerable

    # Public: Returns the hash of key-value pairs.
    attr_reader :data

    # Public: Initializes a new MiniCache object.
    #
    # data - A Hash of key-value pairs (optional).
    #
    # Returns nothing.
    def initialize(data = {})
      @data = {}
      self.load(data)
    end

    # Public: Retrieves the value for a given key.
    #
    # key - A String or Symbol representing the key.
    #
    # Returns the value set for the key; if nothing is
    #   set, returns nil.
    def get(key)
      check_key!(key)
      @data[key.to_s]
    end

    # Public: Sets a value for a given key either as
    # an argument or block.
    #
    # key   - A String or Symbol representing the key.
    # value - Any object that represents the value (optional).
    #         Not used if a block is given.
    # block - A block of code that returns the value to set
    #         (optional).
    #
    # Examples
    #
    #   cache.set("name", "Derrick")
    #   => "Derrick"
    #
    #   cache.set("name") { "Joe" }
    #   => "Joe"
    #
    # Returns the value given.
    def set(key, value = nil)
      check_key!(key)
      @data[key.to_s] = block_given? ? yield : value
    end

    # Public: Determines whether a value has been set for
    # a given key.
    #
    # key - A String or Symbol representing the key.
    #
    # Returns a Boolean.
    def set?(key)
      check_key!(key)
      @data.keys.include?(key.to_s)
    end

    # Public: Retrieves the value for a given key if it
    # has already been set; otherwise, sets the value
    # either as an argument or block.
    #
    # key   - A String or Symbol representing the key.
    # value - Any object that represents the value (optional).
    #         Not used if a block is given.
    # block - A block of code that returns the value to set
    #         (optional).
    #
    # Examples
    #
    #   cache.set("name", "Derrick")
    #   => "Derrick"
    #
    #   cache.get_or_set("name", "Joe")
    #   => "Derrick"
    #
    #   cache.get_or_set("occupation") { "Engineer" }
    #   => "Engineer"
    #
    #   cache.get_or_set("occupation") { "Pilot" }
    #   => "Engineer"
    #
    # Returns the value.
    def get_or_set(key, value = nil)
      return get(key) if set?(key)
      set(key, block_given? ? yield : value)
    end

    # Public: Removes the key-value pair from the cache
    # for a given key.
    #
    # key - A String or Symbol representing the key.
    #
    # Returns the value.
    def unset(key)
      check_key!(key)
      @data.delete(key.to_s)
    end

    # Public: Clears all key-value pairs.
    #
    # Returns nothing.
    def reset
      @data = {}
    end

    # Public: Iterates over all key-value pairs.
    #
    # block - A block of code that will be send the key
    #         and value of each pair.
    #
    # Yields the String key and value.
    def each(&block)
      @data.each { |k, v| yield(k, v) }
    end

    # Public: Loads a hash of data into the cache.
    #
    # data - A Hash of data with either String or Symbol keys.
    #
    # Returns nothing.
    def load(data)
      data.each do |key, value|
        check_key!(key)
        @data[key.to_s] = value
      end
    end

    private

      # Internal: Raises an error if the key is not a String
      # or a Symbol.
      #
      # key - A key provided by the user.
      def check_key!(key)
        unless key.is_a?(String) || key.is_a?(Symbol)
          raise TypeError, "key must be a String or Symbol"
        end
      end
  end
end
