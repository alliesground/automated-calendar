class GoogleCalendarConfig < ApplicationRecord
  belongs_to :user

  def self.authorized_by?(user_id)
    where(user_id: user_id).
    where.not(authorization: nil).exists?
  end
end
