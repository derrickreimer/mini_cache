# frozen_string_literal: true
module MiniCache
  class Data
    attr_reader :value
    attr_reader :expires_in

    def initialize(value, expires_in: nil)
      @value = value
      @expires_in = expires_in.nil? ? nil : Time.now + expires_in
    end

    def expired?
      !@expires_in.nil? && Time.now > @expires_in
    end

    def ==(other)
      other.is_a?(MiniCache::Data) && @value == other.value
    end
  end
end
