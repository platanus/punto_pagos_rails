require "rails_helper"

describe TransactionsController do
  describe "#create" do
    context "with valid transaction creation" do
      let(:fake_proccess_url) { "http://puntopagos.cl/process" }

      before do
        expect_any_instance_of(PuntoPagosRails::TransactionService).to(
          receive(:create).and_return(true))
        expect_any_instance_of(PuntoPagosRails::TransactionService).to(
          receive(:process_url).and_return(fake_proccess_url))
      end

      subject { post :create, ticket: { amount: 5000 } }

      it "redirects to process url" do
        expect(subject).to redirect_to(fake_proccess_url)
      end
    end

    context "with invalid transaction creation" do
      render_views

      before do
        expect_any_instance_of(PuntoPagosRails::TransactionService).to(
          receive(:create).and_return(false))
      end

      subject { post :create, ticket: { amount: 5000 } }

      it "renders error template" do
        expect(subject).to render_template(:error)
      end

      it "shows error in view" do
        post :create, ticket: { amount: 5000 }
        expect(response.body).to match /Error view/
      end
    end
  end

  describe "#notification" do
    before do
      expect(PuntoPagosRails::TransactionService).to(
        receive(:notificate).and_return(some: "json"))
    end

    it "renders json response" do
      post :notification
      expect(JSON.parse(response.body)).to eq("some" => "json")
    end
  end

  describe "#success" do
    let!(:transaction) { create(:transaction) }
    subject { get :success, token: transaction.token }

    it "renders success template" do
      expect(subject).to render_template(:success)
    end

    it "shows success view" do
      get :success, token: transaction.token
      expect(response.body).to match /Ticket/
      expect(response.body).to match /Success view/
    end
  end

  describe "#error" do
    let!(:transaction) { create(:transaction) }
    subject { get :error, token: transaction.token }

    it "renders error template" do
      expect(subject).to render_template(:error)
    end

    it "shows error view" do
      get :error, token: transaction.token
      expect(response.body).to match /Error view/
    end
  end
end
