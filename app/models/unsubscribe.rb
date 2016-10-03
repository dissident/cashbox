# == Schema Information
#
# Table name: unsubscribes
#
#  id         :integer          not null, primary key
#  email      :string
#  active     :boolean          default(FALSE)
#  token      :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Unsubscribe < ApplicationRecord
  has_secure_token :token

  belongs_to :user, inverse_of: :unsubscribe

  validates :email, presence: true
  validates :email, uniqueness: true

  scope :active, -> { where(active: true) }

  def activate
    update_attributes(active: true)
  end
end
