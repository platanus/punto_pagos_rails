require 'rails_helper'

RSpec.describe PuntoPagosRails::TransactionService do
  let(:ticket) { Ticket.create amount: 22 }
  let(:service) { PuntoPagosRails::TransactionService.new(ticket.id) }
  let(:request) { double }
  let(:response) { double }
  let(:token) { 'XXXXX' }
  let(:payment_process_url) { double }

  before do
    allow(PuntoPagos::Request).to receive(:new).and_return(request)
    allow(request).to receive(:create).and_return(response)
    allow(response).to receive(:success?).and_return(false)
  end

  describe "#create" do
    it "creates transaction" do
      expect { service.create }.to change { ticket.reload.transactions.size }.by(1)
    end

    context "success" do
      before do
        allow(response).to receive(:success?).and_return(true)
      end

      context "with succesful initialization" do
        before do
          allow(response).to receive(:get_token).and_return(token)
          allow(response).to receive(:payment_process_url).and_return(payment_process_url)
        end

        it "returns true" do
          expect(service.create).to eq(true)
        end

        it "has the correct token" do
          service.create
          expect(ticket.transactions.last.token).to eq(token)
        end

        it "returns payment process url" do
          service.create
          expect(service.process_url).to eq(payment_process_url)
        end
      end

      context "with unsuccesful initialization" do

        it "returns false with invalid token" do
          allow(response).to receive(:get_token).and_return(nil)
          expect(service.create).to eq(false)
        end

        it "fails with repeated token" do
          PuntoPagosRails::Transaction.create(token: 'REPEATED_TOKEN')
          allow(response).to receive(:get_token).and_return('REPEATED_TOKEN')
          expect(service.create).to eq(false)
        end

      end

    end

    context "error" do

      it "returns false" do
        expect(service.create).to eq(false)
      end

      it "sets resource error" do
        allow(Ticket).to receive(:find).with(ticket.id).and_return(ticket)
        service.create
        expect(ticket.errors[:base]).to include(
          I18n.t("activerecord.errors.models.ticket.attributes.base.invalid_puntopagos_response"))
      end

    end
  end
end
