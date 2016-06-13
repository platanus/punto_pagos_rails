require "rails_helper"

describe PaymentsController do
  describe "#notification" do
    let!(:transaction) { create(:transaction) }

    before do
      expect(PuntoPagosRails::TransactionService).to(
        receive(:complete).and_return(true))
    end

    it "renders json response" do
      get :notification, token: transaction.token
      expect(response.status).to eq(200)
    end
  end
end
