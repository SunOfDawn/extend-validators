# Extend Validators

this is a expansion for ActiveModel basic validation, which provides a new validator to help us validate json attributes in model.
you can select other validations such as `presence` and `inclusion` to validate each value of json

## Installation

```    
# add this to your Gemfile
gem "extend-validators", git: 'https://github.com/SunOfDawn/extend-validators.git'
```

## Usage

there only has json-validation now
### JsonValidator  
a extra validator that can validate json attributes, support another validator to check every member in json like use in model.
 
##### With ActiveRecord

```ruby
class Person < ActiveRecord::Base

    # with json
    validates :other, json: {
      name: { presence: true },
      birthday: { format: { with: /\d{4}-\d{1,2}-\d{1,2}/ } },
      'age' => { numericality: { only_integer: true, greater_than: 0 } },
      [:cow1, :cow2] => { length: { minimum: 5, message: 'too short!!!' }, allow_nil: true }
    }
end

person = Person.new(other: { name: nil, birthday: '20180101', 'age' => 24, cow1: '123', cow2: nil })
person.valid?
person.errors # => [{ other: ['name can't be blank, 'birthday is invalid', 'cow1 too short!!!'] }]
```

##### With ActiveModel

```ruby
class Unicorn
    include ActiveModel::Validations

    attr_accessor :email

    # with legacy syntax (the syntax above works also)
    validates_json_of json: {
      en_name: { presence: true },
      birthday: { format: { with: /\d{4}-\d{1,2}-\d{1,2}/ } }
  }
end
```

##### Note

before using, please check keyword Effectiveness

supported (include sub keyword)
```
:absence, :acceptance, :exclusion, :format, :inclusion, :length, :presence, :json,
:allow_blank, :allow_nil
```
unsupported
```
:uniqueness, :if, :unless, :on, :strict
```
callback options will make json attribute's validation complex and difficult to read, more a loss than gain.