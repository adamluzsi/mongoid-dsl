require_relative "../lib/mongoid-dsl"
require_relative "helper/con"

:TestA.mongoid_name #> nil

class TestA

  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :collection => self.mongoid_name

  embeds_many :TestB.mongoid_name

  field :test,
        :type     => String,
        :presence => true,
        :desc     => "description for this field",
        :accept_only  => %W[ hello world hello\ world ]

end

:TestA.mongoid_name #> "test_a"

class TestB

  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :TestA.mongoid_name
  embeds_many :TestC.mongoid_name

  field :test,
        :type         => String,
        :presence     => true,
        :desc         => "description for this field",
        :uniq         => true

end

class TestC

  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :TestB.mongoid_name
  embeds_many :TestD.mongoid_name

  field :test,
        :type         => String,
        :presence     => true,
        :desc         => "description for this field"

end

class TestD

  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :TestC.mongoid_name

  field :test,
        :type         => String,
        :presence     => true,
        :desc         => "description for this field"

end

test_a= TestA.create! test: "hello"
test_a.test_b.create(test: "world")
test_b= test_a.test_b.last
test_b.test_c.create(test: "world")
test_c= test_b.test_c.last
test_c.test_d.create(test: "world")
test_d= test_c.test_d.last

# puts TestD._find(test_d['_id']).inspect
#<TestD _id: 536a10f6241548c811000004, created_at: 2014-05-07 10:54:46 UTC, updated_at: 2014-05-07 10:54:46 UTC, test: "world">

puts TestD._all.inspect
#> return every embedded TestD obj

puts TestD._where( TestA, test: "world" ).inspect
#> return by criteria the embedded TestD objects

Mongoid.purge!
