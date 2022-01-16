# Dynabute
Dynamically add attributes on Relational Database backed ActiveRecord, without hash serialization and bullshits.

Try messing with a [working demo](https://dynabute-demo.herokuapp.com).

## Usage

First, enable dynabute
```ruby
class User < ActiveRecord::Base
  has_dynabutes
end
````

then add some field definitions
```ruby
User.dynabutes.create( name: 'age', value_type: 'integer' )
User.dynabutes.create( name: 'skinny', value_type: 'boolean' )
User.dynabutes.create( name: 'personalities', value_type: 'string', has_many: true )
```

now set value
```ruby
user = User.create

user.set_dynabute_value( name: 'age', value: 40 )
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: 40>
user.set_dynabute_value( name: 'skinny', value: true )
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: true>
user.save
# => true

# or update single value
user.set_dynabute_value( name: 'age', value: 35 ).save
# => true
```

check the value
```ruby
user.get_dynabute_value(name: 'age')
# => 35
```

or check entire value object
```ruby
value_obj = user.dynabute_value( name: 'age' )
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: 35>
value_obj.value
# => 35
```

values can also be referenced by `dynabute_<field name>_value(s)`
```ruby
user.dynabute_age_value.value
# => 35
```

set values for fields which can contain more than one value
```ruby
user = User.create

user.set_dynabute_value( name: 'personalities', value: 'good' )
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "good">
user.set_dynabute_value( name: 'personalities', value: 'bad' )
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "bad">
user.set_dynabute_value( name: 'personalities', value: 'ugly' )
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "ugly">
user.save
# => true
```

get values for fields which can contain more than one value
```ruby
user = User.first

user.get_dynabute_value( name: 'personalities' )
# => ["good", "bad", "ugly"]

user.dynabute_value( name: 'personalities' )
# => [#<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "good">,
#     #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "bad">,
#     #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "ugly">]
```

update specific value for field with `has_many` option
```ruby
user = User.first

values_obj = user.dynabute_value( name: 'personalities' )
# => [#<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "good">,
#     #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "bad">,
#     #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "ugly">]
good_value_obj = values_obj.first
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "good">
bad_value_obj = values_obj.last
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "ugly">
user.set_dynabute_value( name: 'personalities', value: 'very good', value_id: good_value_obj.id )
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "very good">
user.set_dynabute_value( name: 'personalities', value: 'very ugly', value_id: bad_value_obj.id )
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "very ugly">
user.save
# => true

# in case all changes are not required to be saved within db transaction,
# each value can be saved separately.
good_value_obj.value = 'very very good'
# => "very very good"
good_value_obj.save
```

remove value
```ruby
user = User.first

user.remove_dynabute_value( name: 'age' )
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: 35>

value_obj = user.dynabute_value( name: 'personalities' ).first
user.remove_dynabute_value( name: 'personalities', value_id: value_obj.id )
# => #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "good">

user.remove_dynabute_value( name: 'personalities' )
# => [#<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "bad">,
#     #<Dynabute::Values::StringValue:0x0000 ... dynabutable_type: "User", value: "ugly">]
```

nested attributes of glory
```ruby
personality_field_id = User.dynabutes.find_by( name: 'personalities' ).id
user.update(
  dynabute_values_attributes: [
    { name: 'age', value: 36 }, #=> tell us which field to update by `name:`
    { name: 'skinny', value: false },
    { field_id: personality_field_id, value: 'introverted' }, # or by `field_id:`
    { field_id: personality_field_id, value: 'stingy' }
  ]
)
```

`select` value_type is also available
```ruby
User.dynabutes.create( name: 'gender', value_type: 'select', options_attributes: [ { label: 'male' }, { label: 'female' } ] )
User.dynabutes.create( name: 'hobbies', has_many: true, value_type: 'select',  options_attributes: [ { label: 'running' }, { label: 'swimming' }, { label: 'hiking' } ] )
```

list the available options for a field
```ruby
User.dynabutes.find_by(name: gender).options
# => [#<Dynabute::Option:0x007ff53e2e1f90 id: 1, field_id: 4, label: "male">,
#     #<Dynabute::Option:0x007ff53e2e1568 id: 2, field_id: 4, label: "female">]
```

set value
```ruby
male = User.dynabutes.find_by(name: 'gender').options.find_by(label: 'male')
hobbies = User.dynabutes.find_by(name: 'hobbies').options

user.update(dynabute_values_attributes: [
 { name: 'gender', value: male.id },
 { name: 'hobbies', value: hobbies[0].id },
 { name: 'hobbies', value: hobbies[1].id }
])
```

check out the selected options
```ruby
user.dynabute_value(name: 'gender').option
# => <Dynabute::Option:0x007ff53e2e1f90 id: 1, field_id: 4, label: "male">,

user.dynabute_value(name: 'hobbies').map(&:option)
# => [#<Dynabute::Option:0x007fb26c4467d8 id: 5, field_id: 5, label: "running">,
#     #<Dynabute::Option:0x007fb26c446238 id: 6, field_id: 5, label: "swimming">]
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'dynabute'
```

And then execute:
```bash
$ bundle install
$ rails generate dynabute:install
$ rake db:migrate
```

## Contributing

#### Rspec: set test environment
```bash
$ bundle install
$ cd spec/dummy/
$ RAILS_ENV=test bundle exec rake db:create
$ RAILS_ENV=test bundle exec rake db:migrate
$ cd ../../
$ bundle exec rspec
```

yea?

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
