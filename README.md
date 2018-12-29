# Extend Validators

this is a expansion for ActiveModel basic validation, which provides a new validator to help us validate json attributes in model.
you can select other validations such as `presence` and `inclusion` to validate each value of json

## Installation

Add the following to your Gemfile

```ruby
gem 'extend-validators', git: 'https://github.com/SunOfDawn/extend-validators.git'
```
And then execute:
```
$ bundle
```
Or install it yourself as:
```
$ gem install extend_validator
```

## Usage

### HashValidator、ArrayValidator  
Two extra validator that can validate json attributes.  
And you can nest with other validators to check every member in json, just like validate root attributes.
 
##### With ActiveRecord

```ruby
class Person < ActiveRecord::Base

    # with object json
    validates :other, hash: {
      name: { presence: true },
      birthday: { format: { with: /\d{4}-\d{1,2}-\d{1,2}/ } },
      'age' => { numericality: { only_integer: true, greater_than: 0 } },
      [:cow1, :cow2] => { length: { minimum: 5, message: 'too short!!!' }, allow_nil: true }
    }
        
    # with array json
    validates :array_list, array: {
      validates_each: { inclusion: { in: [1, 2] } }, allow_nil: true
    }
end

person = Person.new(other: { name: nil, birthday: '20180101', 'age' => 24, cow1: '123', cow2: nil })
person.valid?
person.errors.messages # => [{ other: ['name can't be blank, 'birthday is invalid', 'cow1 too short!!!'] }]
```

##### With ActiveModel

```ruby
class Unicorn
    include ActiveModel::Validations

    attr_accessor :email

    # with legacy syntax (the syntax above works also)
    validates_hash_of json: {
      en_name: { presence: true },
      birthday: { format: { with: /\d{4}-\d{1,2}-\d{1,2}/ } }
    }
      
    validates_array_of json: {
      validates_each: { inclusion: { in: [1, 2] } }, allow_nil: true
    }
end
```

##### Note

before using, please check keyword Effectiveness

supported (include sub keyword)
```ruby
:absence, :acceptance, :exclusion, :format, :inclusion, :length, :presence, :hash, :array,

# example:
validates_hash_of json: { en_name: { presence: true }, allow_nil: true }
```
unsupported（these keyword will make validation complex, currently not supported them）
```ruby
:uniqueness, :if, :unless, :on, :strict

# can't used like:
validates_hash_of json: { age: { numericality: { greater_than: 0 } }, if: name.present? }
```