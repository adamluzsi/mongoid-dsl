
class TestA

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::CRUD

  store_in :collection => self.mongoid_name

  embeds_many :TestB.mongoid_name

  # field :test,
  #       :type     => String,
  #       :presence => true,
  #       :desc     => "description for this field",
  #       :accept_only  => %W[ hello world hello\ world ]

end

class TestB

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::CRUD

  embedded_in :TestA.mongoid_name
  embeds_many :TestC.mongoid_name

  # field :test,
  #       :type         => String,
  #       :presence     => true,
  #       :desc         => "description for this field",
  #       :uniq         => true

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