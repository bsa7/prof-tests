class AnswerVariant < ActiveRecord::Base
  belongs_to :question, dependent: :destroy
end
