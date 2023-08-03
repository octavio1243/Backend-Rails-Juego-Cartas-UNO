class MyCard < ApplicationRecord
  include CardEnum
  belongs_to :user
  belongs_to :game
end
