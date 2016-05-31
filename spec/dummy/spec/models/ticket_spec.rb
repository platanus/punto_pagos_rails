require "rails_helper"

RSpec.describe Ticket, type: :model do
  describe "associations" do
    it { should have_many(:transactions) }
  end
end
