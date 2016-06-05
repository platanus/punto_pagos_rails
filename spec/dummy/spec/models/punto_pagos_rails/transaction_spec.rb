require "rails_helper"

RSpec.describe PuntoPagosRails::Transaction, type: :model do
  describe "associations" do
    it { should belong_to(:payable) }
  end
end
