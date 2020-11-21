# KSUID for ActiveRecord

[![Build Status](https://github.com/michaelherold/activerecord-ksuid/workflows/Continuous%20integration/badge.svg)][actions]
[![Test Coverage](https://api.codeclimate.com/v1/badges/672e331f6006d1a00ec8/test_coverage)][test-coverage]
[![Maintainability](https://api.codeclimate.com/v1/badges/672e331f6006d1a00ec8/maintainability)][maintainability]
[![Inline docs](http://inch-ci.org/github/michaelherold/activerecord-ksuid.svg?branch=main)][inch]

[inch]: http://inch-ci.org/github/michaelherold/activerecord-ksuid
[maintainability]: https://codeclimate.com/github/michaelherold/activerecord-ksuid/maintainability
[test-coverage]: https://codeclimate.com/github/michaelherold/activerecord-ksuid/test_coverage
[actions]: https://github.com/michaelherold/activerecord-ksuid/actions

Using K-Sortable Unique IDentifiers in ActiveRecord and wish there was an easier way to do it? Look no further! `activerecord-ksuid` adds support for the data type to your application with zero friction.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-ksuid'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activerecord-ksuid

## Usage

Whether you are using ActiveRecord inside an existing project or in a new project, usage is simple. Additionally, you can use it with or without Rails.

### Adding to an existing model

Within a Rails project, it is very easy to get started using KSUIDs within your models. You can use the `ksuid` column type in a Rails migration to add a column to an existing model:

    rails generate migration add_ksuid_to_events ksuid:ksuid

This will generate a migration like the following:

```ruby
class AddKsuidToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :unique_id, :ksuid
  end
end
```

Then, to add proper handling to the field, you will want to mix a module into the model:

```ruby
class Event < ApplicationRecord
  include KSUID::ActiveRecord[:unique_id]
end
```

### Creating a new model

To create a new model with a `ksuid` field that is stored as a KSUID, use the `ksuid` column type. Using the Rails generators, this looks like:

    rails generate model Event my_field_name:ksuid

If you would like to add a KSUID to an existing model, you can do so with the following:

```ruby
class AddKsuidToEvents < ActiveRecord::Migration[5.2]
  change_table :events do |table|
    table.ksuid :my_field_name
  end
end
```

Once you have generated the table that you will use for your model, you will need to include a module into the model class, as follows:

```ruby
class Event < ApplicationRecord
  include KSUID::ActiveRecord[:my_field_name]
end
```

#### With a KSUID primary key

You can also use a KSUID as the primary key on a table, much like you can use a UUID in vanilla Rails. To do so requires a little more finagling than you can manage through the generators. When hand-writing the migration, it will look like this:

```ruby
class CreateEvents < ActiveRecord::Migration[5.2]
  create_table :events, id: false do |table|
    table.ksuid :id, primary_key: true
  end
end
```

You will need to mix in the module into your model as well:

```ruby
class Event < ApplicationRecord
  include KSUID::ActiveRecord[:id]
end
```

### Outside of Rails

Outside of Rails, you cannot rely on the Railtie to load the appropriate files for you automatically. Toward the start of your application's boot process, you will want to require the following:

```ruby
require 'ksuid/activerecord'

# If you will be using the ksuid column type in a migration
require 'ksuid/activerecord/table_definition'
```

Once you have required the file(s) that you need, everything else will work as it does above.

### Binary vs. String KSUIDs

These examples all store your identifier as a string-based KSUID. If you would like to use binary KSUIDs instead, use the `ksuid_binary` column type. Unless you need to be super-efficient with your database, we recommend using string-based KSUIDs because it makes looking at the data while in the database a little easier to understand.

When you include the KSUID module into your model, you will want to pass the `:binary` option as well:

```ruby
class Event < ApplicationRecord
  include KSUID::ActiveRecord[:my_field_name, binary: true]
end
```

### Use the KSUID as your `created_at` timestamp

Since KSUIDs include a timestamp as well, you can infer the `#created_at` timestamp from the KSUID when it is being used as your primary key. The module builder enables that option automatically with the `:created_at` option, like so:

```ruby
class Event < ApplicationRecord
  include KSUID::ActiveRecord[:my_field_name, created_at: true]
end
```

This allows you to be efficient in your database design if that is a constraint you need to satisfy.

## Contributing

So you’re interested in contributing to KSUID for ActiveRecord? Check out our [contributing guidelines](CONTRIBUTING.md) for more information on how to do that.

## Supported Ruby Versions

This library aims to support and is [tested against][actions] the following Ruby versions:

* Ruby 2.5
* Ruby 2.6
* Ruby 2.7
* JRuby 9.2

If something doesn't work on one of these versions, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby versions, however support will only be provided for the versions listed above.

If you would like this library to support another Ruby version or implementation, you may volunteer to be a maintainer. Being a maintainer entails making sure all tests run and pass on that implementation. When something breaks on your implementation, you will be responsible for providing patches in a timely fashion. If critical issues for a particular implementation exist at the time of a major release, support for that Ruby version may be dropped.

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations of this scheme should be reported as bugs. Specifically, if a minor or patch version is released that breaks backward compatibility, that version should be immediately yanked and/or a new version should be immediately released that restores compatibility. Breaking changes to the public API will only be introduced with new major versions. As a result of this policy, you can (and should) specify a dependency on this gem using the [Pessimistic Version Constraint][pessimistic] with two digits of precision. For example:

    spec.add_dependency "ksuid", "~> 0.1"

[pessimistic]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[semver]: http://semver.org/spec/v2.0.0.html

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
