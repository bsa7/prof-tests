class Question < ActiveRecord::Base
  belongs_to :test_name, dependent: :destroy
end
