class User < ActiveRecord::Base
  belongs_to :group
end

class Group < ActiveRecord::Base
  has_many :users
end
