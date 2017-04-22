# frozen_string_literal: true
require File.expand_path('../../test_helper.rb', __FILE__)
module MiniCache
  class DataTest < MiniTest::Test
    context 'initialize' do
      should 'return initialized value' do
        data = MiniCache::Data.new('Gunter')
        assert_equal('Gunter', data.value)
      end

      should 'return a nil expires_in as default' do
        data = MiniCache::Data.new('Gunter')
        assert_nil(data.expires_in)
      end

      should 'return initialized expires_in' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          data = MiniCache::Data.new('Gunter', 60)
          assert_equal(Time.now + 60, data.expires_in)
        end
      end
    end

    context '#equals' do
      should 'be compared only by value and be the same' do
        data1 = MiniCache::Data.new('Finn', 10)
        data2 = MiniCache::Data.new('Finn', 30)
        assert_equal(data1, data2)
      end

      should 'be compared only by value and not be the same' do
        data1 = MiniCache::Data.new('Finn', 10)
        data2 = MiniCache::Data.new('Grass Finn', 10)
        refute_equal(data1, data2)
      end
    end

    context '#expired?' do
      should 'be expired' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          data = MiniCache::Data.new('Gunter', 60)
          Timecop.travel(data.expires_in) do
            assert_equal(true, data.expired?)
          end
        end
      end

      should 'not be expired' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          data = MiniCache::Data.new('Gunter', 60)
          Timecop.travel(data.expires_in - 1) do
            assert_equal(false, data.expired?)
          end
        end
      end

      should 'not be expired because expires_in is nil' do
        Timecop.freeze(Time.local(2010, 4, 5, 12, 0, 0)) do
          data = MiniCache::Data.new('Gunter')
          assert_equal(false, data.expired?)
        end
      end
    end
  end
end
