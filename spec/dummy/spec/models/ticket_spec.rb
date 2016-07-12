require "rails_helper"

RSpec.describe Ticket, type: :model do
  describe "associations" do
    it { should have_many(:transactions) }
  end

  describe "validations" do
    it { should enumerize(:payment_state).in(Ticket::PAYMENT_STATES) }
  end
end
