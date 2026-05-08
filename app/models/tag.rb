class Tag < ApplicationRecord
  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags

  validates :name, presence: true, uniqueness: true

  before_update :prevent_system_modification
  before_destroy :prevent_system_deletion

  private

  def prevent_system_modification
    if system?
      errors.add(:base, "System tags cannot be modified")
      throw(:abort)
    end
  end

  def prevent_system_deletion
    if system?
      errors.add(:base, "System tags cannot be deleted")
      throw(:abort)
    end
  end
end
