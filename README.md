# MiniCache

MiniCache is a lightweight in-memory key-value store for Ruby objects.

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
store = MiniCache::Store.new(:name => "Derrick", :occupation => "Developer")
```

Set and retrieve data using `#get` and `#set`:

```ruby
# Pass in the value as an argument or block
store.set("age", 24)
store.set("birth_year") { 1988 }

store.get("birth_year")
=> 1988
```

Use the `#get_or_set` method to either set the value if it hasn't already been
set, or get the value that was already set.

```ruby
store.set("birth_year") { 1988 }
=> 1988

store.get_or_set("birth_year") { 1964 }
=> 1988  # Did not overwrite previously set value
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

## MIT License

Copyright &copy; 2012 Derrick Reimer

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
