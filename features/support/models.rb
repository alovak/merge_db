class User < ActiveRecord::Base
  belongs_to :group
  belongs_to :studio
end

class Studio < ActiveRecord::Base
end

class Group < ActiveRecord::Base
  has_many :users
end
