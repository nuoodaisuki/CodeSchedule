class Post < ApplicationRecord

  validates :task_id, presence: true
  validates :time_taken, presence: true, on: :update

  belongs_to :user
  belongs_to :task
  has_many :comments, dependent: :destroy

  def self.looks(word)
    joins(:task).where("tasks.name LIKE ?", "%#{word}%")
  end

end
