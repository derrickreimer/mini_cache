# frozen_string_literal: true
require File.expand_path('../../test_helper.rb', __FILE__)
module MiniCache
  class StoreTest < MiniTest::Test
    def setup
      @store = MiniCache::Store.new
    end

    context 'initialize' do
      should 'default to empty data' do
        store = MiniCache::Store.new
        assert_equal({}, store.data)
      end

      should 'load seed data' do
        data = { 'name' => 'Derrick' }
        store = MiniCache::Store.new(data)
        assert_equal(
          { data.keys.first => MiniCache::Data.new(data.values.first) },
          store.data
        )
      end

      should 'load seed data using MiniCache::Data' do
        data = { 'name' => MiniCache::Data.new('Derrick', 60) }
        store = MiniCache::Store.new(data)
        assert_equal(
          data,
          store.data
        )
      end
    end

    context '#get' do
      should 'return a value if set' do
        @store.set('name', 'Derrick')
        assert_equal 'Derrick', @store.get('name')
      end

      should 'return nil if not set' do
        assert_nil @store.get('name')
      end

      should 'raise a TypeError if key is not valid' do
        assert_raises(TypeError) { @store.get([1, 2]) }
      end

      should 'return an not expired value' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          @store.set('name', 'Derrick', expires_in: 60)
          Timecop.travel(Time.now + 59) do
            assert_equal('Derrick', @store.get('name'))
          end
        end
      end

      should 'not return an expired value' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          @store.set('name', 'Derrick', expires_in: 60)
          Timecop.travel(Time.now + 60) do
            assert_nil @store.get('name')
          end
        end
      end
    end

    context '#set' do
      should 'accept the value as an argument' do
        @store.set('name', 'Derrick')
        assert_equal 'Derrick', @store.get('name')
      end

      should 'accept the value as a block' do
        @store.set('name') { 'Derrick' }
        assert_equal 'Derrick', @store.get('name')
      end

      should 'accept the value as a MiniCache::Data argument' do
        @store.set('name', MiniCache::Data.new('Derrick'))
        assert_equal 'Derrick', @store.get('name')
      end

      should 'accept the value as a block with MiniCache::Data' do
        @store.set('name') { MiniCache::Data.new('Derrick') }
        assert_equal 'Derrick', @store.get('name')
      end

      should 'raise a TypeError if key is not valid' do
        assert_raises(TypeError) { @store.set([1, 2], 'foo') }
      end

      should 'returns cached value' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          @store.set('name', 'Derrick', expires_in: 60)
          Timecop.travel(Time.now + 59) do
            assert_equal('Derrick', @store.get('name'))
          end
        end
      end

      should 'returns nil, because cache was expired' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          @store.set('name', 'Derrick', expires_in: 60)
          Timecop.travel(Time.now + 60) do
            assert_nil(@store.get('name'))
          end
        end
      end

      should 'returns cached value. Using block' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          @store.get_or_set('name', expires_in: 60) do
            'Derrick'
          end
          Timecop.travel(Time.now + 59) do
            assert_equal('Derrick', @store.get('name'))
          end
        end
      end

      should 'returns nil, because cache was expired. Using block' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          @store.get_or_set('name', expires_in: 60) do
            'Derrick'
          end
          Timecop.travel(Time.now + 60) do
            assert_nil(@store.get('name'))
          end
        end
      end
    end

    context '#set?' do
      should 'be true if key has been set' do
        @store.set('name', 'Derrick')
        assert_equal true, @store.set?('name')
      end

      should 'be false if key has not been set' do
        assert_equal false, @store.set?('foobar')
      end

      should 'raise a TypeError if key is not valid' do
        assert_raises(TypeError) { @store.set?([1, 2]) }
      end
    end

    context '#get_or_set' do
      should "set the value if it hasn't already been set" do
        @store.get_or_set('name', 'Derrick')
        assert_equal 'Derrick', @store.get('name')
      end

      should 'not set the value if it has already been set' do
        @store.set('name', 'Derrick')
        @store.get_or_set('name', 'Joe')
        assert_equal 'Derrick', @store.get('name')
      end

      should 'return the value if not already set' do
        assert_equal('Derrick',
                     @store.get_or_set('name', 'Derrick'))
      end

      should 'return the value if already set' do
        @store.set('name', 'Derrick')
        assert_equal 'Derrick', @store.get_or_set('name', 'Joe')
      end

      should 'accept the value as a block' do
        @store.get_or_set('name') { 'Joe' }
        assert_equal 'Joe', @store.get('name')
      end

      should 'raise a TypeError if key is not valid' do
        assert_raises(TypeError) { @store.get_or_set([1, 2], 'foo') }
      end

      should 'returns first set value' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          @store.set('name', 'Derrick', expires_in: 60)
          Timecop.travel(Time.now + 59) do
            @store.get_or_set('name', 'Gunter', expires_in: 60)
            assert_equal('Derrick', @store.get('name'))
          end
        end
      end

      should 'returns next set value' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          @store.set('name', 'Derrick', expires_in: 60)
          Timecop.travel(Time.now + 60) do
            @store.get_or_set('name', 'Gunter', expires_in: 60)
            assert_equal('Gunter', @store.get('name'))
          end
        end
      end

      should 'returns first set value. Using block' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          @store.get_or_set('name', expires_in: 60) do
            'Derrick'
          end
          Timecop.travel(Time.now + 59) do
            @store.get_or_set('name', expires_in: 60) do
              'Gunter'
            end
            assert_equal('Derrick', @store.get('name'))
          end
        end
      end

      should 'returns next set value. Using block' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          @store.get_or_set('name', expires_in: 60) do
            'Derrick'
          end
          Timecop.travel(Time.now + 60) do
            @store.get_or_set('name', expires_in: 60) do
              'Derrick'
            end
            assert_equal('Derrick', @store.get('name'))
          end
        end
      end
    end

    context '#unset' do
      should 'remove the key-value pair' do
        @store.set('name', 'Derrick')
        @store.unset('name')
        assert !@store.data.keys.include?('name')
      end
    end

    context '#reset' do
      should 'remove all data' do
        @store.set('name', 'Derrick')
        @store.reset
        assert_equal({}, @store.data)
      end
    end

    context '#load' do
      should 'append the data to the cache' do
        @store.set('title', 'Mr.')

        data = { 'name' => 'Derrick', 'occupation' => 'Developer' }
        @store.load(data)

        all_data = { 'title' => MiniCache::Data.new('Mr.'),
                     'name' => MiniCache::Data.new('Derrick'),
                     'occupation' => MiniCache::Data.new('Developer') }
        assert_equal all_data, @store.data
      end

      should 'stringify the keys' do
        data = { name: 'Derrick' }
        @store.load(data)
        stringified_data = { 'name' => MiniCache::Data.new('Derrick') }
        assert_equal stringified_data, @store.data
      end

      should 'raise a TypeError if an invalid key is encountered' do
        data = { [1, 2] => 'Derrick' }
        assert_raises(TypeError) { @store.load(data) }
      end
    end
  end
end
