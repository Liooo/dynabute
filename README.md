# Dynabute
Dynamically add attributes on Relational Database backed ActiveRecord, without hash serialization and bullshits

## Usage

First, enable dynabute
```ruby
class User < ActiveRecord::Base
  has_dynabutes
end
````

then add some field definitions
```ruby
User.dynabutes << Dynabute::Field.new( name: 'age', value_type: 'integer' )
User.dynabutes << Dynabute::Field.new( name: 'skinny', value_type: 'boolean' )
User.dynabutes << Dynabute::Field.new( name: 'personalities', value_type: 'string', has_many: true )
```

now set value
```ruby
user = User.create

user.build_dynabute_value( name: 'age', value: 35 ).save
# => <Dynabute::Values::IntegerValue:0x007faba5279540 id: 1, field_id: 1, dynabutable_id: 1, dynabutable_type: "User", value: 35>
```

check the value
```ruby
user.dynabute_value( name: 'age' ).value
# => 35
```

values can also be referenced by `dynabute_<field name>_value(s)`
```ruby
user.dynabute_age_value.value
# => 35
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
User.dynabutes << Dynabute::Field.new( name: 'gender', value_type: 'select', options_attributes: [ { label: 'male' }, { label: 'female' } ] )
User.dynabutes << Dynabute::Field.new( name: 'hobbies', has_many: true, value_type: 'select',  options_attributes: [ { label: 'running' }, { label: 'swimming' }, { label: 'hiking' } ] )
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
yea?

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
