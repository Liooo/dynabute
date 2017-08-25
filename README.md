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
User.dynabutes << Dynabute::Field.new( name: 'personality', value_type: 'string', has_many: true )
```

now set value
```ruby
user = User.create

user.build_dynabute_value( name: 'age' )
# => <Dynabute::Values::IntegerValue:0x007faba5279540 id: nil, field_id: 1, dynabutable_id: 1, dynabutable_type: "User", value: nil>

user.build_dynabute_value( name: 'age' ).update( value: 35 )
user.dynabute_value( name: 'age' ).value
#=> 35
```

values can also be referenced by `dynabute_<field name>_value(s)`
```ruby
user.dynabute_age_value
# => <Dynabute::Values::IntegerValue:0x007faba5279540 id: 1, field_id: 1, dynabutable_id: 1, dynabutable_type: "User", value: 35>
```

nested attributes of glory
```ruby
personality_field_id = User.dynabutes.find_by( name: 'personality' ).id
user.update(
  dynabute_values_attributes: [
    { name: 'age', value: 36 }, #=> tell us which field to update by `name:`
    { name: 'skinny', value: false },
    { field_id: personality_field_id, value: 'introverted' }, # or by `field_id:`
    { field_id: personality_field_id, value: 'stingy' }
  ]
)
```

check all dynabute values
```ruby
user.dynabute_values
#=> [#<Dynabute::Values::IntegerValue:0x007ff4230e90d8 id: 1, field_id: 1, dynabutable_id: 1, dynabutable_type: "User", value: 36>,
     #<Dynabute::Values::BooleanValue:0x007fd03ecb84f8 id: 1, field_id: 2, dynabutable_id: 1, dynabutable_type: "User", value: false>,
     #<Dynabute::Values::StringValue:0x007fd03b347ef8 id: 1, field_id: 3, dynabutable_id: 1, dynabutable_type: "User", value: "introverted">,
     #<Dynabute::Values::StringValue:0x007fd03e992080 id: 1, field_id: 3, dynabutable_id: 1, dynabutable_type: "User", value: "stingy">]
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
