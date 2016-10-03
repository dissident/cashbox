# == Schema Information
#
# Table name: invitations
#
#  id            :integer          not null, primary key
#  token         :string(255)      not null
#  email         :string(255)      not null
#  role          :string
#  accepted      :boolean          default(FALSE)
#  invited_by_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  type          :string
#

class InvitationBase < ApplicationRecord
  extend Enumerize

  self.table_name = 'invitations'

  has_secure_token :token

  belongs_to :user, primary_key: :email, foreign_key: :email, inverse_of: :invitations

  validates :email, presence: true
  validates :email, format: { with: Devise.email_regexp, message: "invalid format" }
  validates :email, length: { maximum: 255, message: "too long" }

  scope :ordered, -> { order('created_at DESC') }
  scope :active,  -> { where(accepted: false) }

  private

  def notification(kind, date)
    options = {
      email: email,
      kind: kind,
      date: date,
      notificator: self
    }
    Notification.create_if_allowed(options)
  end
end
