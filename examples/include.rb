require_relative "../lib/mongoid-dsl"
require_relative "helper/connection"

class TestD

  include Mongoid::Document
  include Mongoid::Timestamps

  # for manual include but by default after require the module it will happen on the fly!
  include Mongoid::DSL

  store_in :collection => self.mongoid_name

  field :test,
        :type => String,
        :desc => "description for this field"

end
