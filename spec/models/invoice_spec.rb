# == Schema Information
#
# Table name: invoices
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  customer_id     :integer          not null
#  starts_at       :date
#  ends_at         :date             not null
#  currency        :string           default("USD"), not null
#  amount_cents    :integer          default(0), not null
#  sent_at         :datetime
#  paid_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe Invoice do
  context 'association' do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to have_many(:invoice_items).dependent(:destroy) }
  end

  context 'validation' do
    it { is_expected.to validate_presence_of(:organization) }
    it { is_expected.to validate_presence_of(:ends_at) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:customer_name) }
    it { is_expected.to validate_numericality_of(:amount).
      is_greater_than(0).is_less_than_or_equal_to(Dictionaries.money_max) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(Dictionaries.currencies) }

    context 'check customer date range overlaping' do
      let!(:org)      { create :organization }
      let!(:customer) { create :customer }
      let!(:invoice)  { create :invoice, customer_name: customer.name,
        organization: org, starts_at: Date.today - 10.days, ends_at: Date.today }
      let(:invoice1) { build :invoice, customer_name: customer.name,
        organization: org, starts_at: Date.today - 9.days, ends_at: Date.today + 1.days }
      let(:invoice2) { build :invoice, customer_name: customer.name,
        organization: org, starts_at: Date.today - 11.days, ends_at: Date.today }
      let(:invoice3) { build :invoice, customer_name: customer.name,
        organization: org, starts_at: Date.today - 9.days, ends_at: Date.today }
      let(:invoice4) { build :invoice, customer_name: customer.name,
        organization: org, starts_at: Date.today - 11.days, ends_at: Date.today + 1.days }
      let(:invoice5) { build :invoice, customer_name: customer.name,
        organization: org, starts_at: Date.today + 2.days, ends_at: Date.today + 10.days }

      it 'Show error on starts_at' do
        invoice1.valid?
        expect(invoice1.errors[:starts_at]).to include('overlaps with another Invoice')
      end
      it 'Show error on ends_at' do
        invoice2.valid?
        expect(invoice2.errors[:starts_at]).to include('overlaps with another Invoice')
      end
      it 'Show errors on starts_at and ends_at' do
        invoice3.valid?
        expect(invoice3.errors[:starts_at]).to include('overlaps with another Invoice')
      end
      it 'Show errors on starts_at and ends_at' do
        invoice4.valid?
        expect(invoice4.errors[:starts_at]).to include('overlaps with another Invoice')
      end
      it 'Dont show errors on starts_at and ends_at' do
        invoice5.valid?
        expect(invoice5.errors[:starts_at]).to_not include('overlaps with another Invoice')
      end
    end
  end
end