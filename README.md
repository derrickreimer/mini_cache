# MiniCache

[![Build Status](https://travis-ci.org/djreimer/mini_cache.svg?branch=master)](https://travis-ci.org/djreimer/mini_cache)

MiniCache is a lightweight in-memory key-value store for Ruby objects.
This gem requires Ruby version 2.3.0 or higher.

## Motivation

It is common practice to cache certain values on an object that are
computationally expensive to obtain, such as a property that requires a
database query.

The simplest way to do this is by storing the value in an instance variable:

```ruby
class Account
  def calculate_balance
    # Do something expensive.
  end

  def balance
    @balance ||= self.calculate_balance
  end
end
```

While this method works in many scenarios, it fails when the value you
need to cache is:

- Either `nil` or `false`
- Dependent on a particular argument passed to the method

Here's a demonstration of how MiniCache solves this problem:

```ruby
class Account
  def lookup_role(user)
    # Execute a database query to find the user's role.
  end

  def role(user)
    # Perform the lookup once and cache the value. We can't use
    #
    #   @role ||= lookup_user(user)
    #
    # because the value depends on the user argument. Also, the
    # value could be nil if the user does not actually have a role.
    # You can probably see how the solution could get pretty ugly.
    # This is where MiniCache comes into play.
    self.cache.get_or_set("role-#{user.id}") do
      self.lookup_role(user)
    end
  end

  def cache
    @cache ||= MiniCache::Store.new
  end
end
```

The `#get_or_set` method works similarly to the `||=` operator, except it
knows how to handle `false` and `nil` values and it's keyed off of a unique string ID.
Problem solved!

## Installation

Add this line to your application's Gemfile:

    gem 'mini_cache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mini_cache

## Usage

To create a new MiniCache store object, just initialize it:

```ruby
store = MiniCache::Store.new

# Optionally pass in a Hash of data
store = MiniCache::Store.new(name: 'Derrick', occupation: 'Developer')
```

Set and retrieve data using `#get` and `#set`:

```ruby
# Pass in the value as an argument or block
store.set('age', 24)
store.set('birth_year') { 1988 }

store.get('age')
# => 24

store.get('birth_year')
# => 1988

# Sets an expiration time to cache (in seconds)
store.set('age', 24, expires_in: 60)
store.set('day', expires_in: 60) { 12 }
store.set('birth_year') { MiniCache::Data.new(1988, 60) }

store.get('age')
# => 24

store.get('day')
# => 12

store.get('birth_year')
# => 1988

sleep(60)

store.get('age')
# => nil

store.get('day')
# => nil

store.get('birth_year')
#=> nil
```

Use the `#get_or_set` method to either set the value if it hasn't already been
set, or get the value that was already set.

```ruby
store.set('birth_year') { 1988 }
#=> 1988

store.get_or_set('birth_year') { 1964 }
#=> 1988  # Did not overwrite previously set value

# You may also set an expiration time (in seconds):

store.get_or_set('age', expires_in: 60) { 24 }
#=> 24

store.get_or_set('birth_year') do
  MiniCache::Data.new(1988, expires_in: 60)
end
#=> 1988

sleep(60)

store.get_or_set('age', expires_in: 60) { 28 }
#=> 28

store.get_or_set('birth_year') do
  MiniCache::Data.new(1964, expires_in: 60)
end
#=> 1964
```

Other convenience methods:

- `#set?(key)`: Checks to see if a value has been set for a given key
- `#unset(key)`: Removes a key-value pair for a given key.
- `#reset`: Clears the cache.
- `#load(hash)`: Loads a hash of data into the cache (appended to existing data).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
