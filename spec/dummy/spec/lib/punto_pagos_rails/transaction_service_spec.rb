require "rails_helper"

include PuntoPagosRails

RSpec.describe TransactionService do
  let(:ticket) { Ticket.create amount: 22 }
  let(:service) { TransactionService.new(ticket) }
  let(:request) { double }
  let(:response) { double }
  let(:token) { "XXXXX" }
  let(:payment_process_url) { double }
  let(:notification) { double }
  let(:status) { double }
  let(:transaction) do
    PuntoPagosRails::Transaction.create(payable: ticket, token: SecureRandom.base64)
  end

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
          Transaction.create(token: "REPEATED_TOKEN")
          allow(response).to receive(:get_token).and_return("REPEATED_TOKEN")
          expect(service.create).to eq(false)
        end
      end
    end

    context "error" do
      it "returns false" do
        expect(service.create).to eq(false)
      end

      it "sets payable error" do
        allow(Ticket).to receive(:find).with(ticket.id).and_return(ticket)
        service.create
        expect(ticket.errors[:base]).to include(
          I18n.t("punto_pagos_rails.errors.invalid_puntopagos_response"))
      end
    end
  end

  describe "#xxx_by_token" do
    it "returns payable (ticket) by token" do
      payable = TransactionService.ticket_by_token(token: transaction.token)
      expect(payable.class).to eq(Ticket)
      expect(payable.id).to eq(ticket.id)
      expect(payable.errors).to be_empty
    end
  end

  describe "#failed_xxx_by_token" do
    it "returns payable (ticket) by token with loaded error" do
      payable = TransactionService.failed_ticket_by_token(token: transaction.token)
      expect(payable.class).to eq(Ticket)
      expect(payable.id).to eq(ticket.id)
      expect(payable.errors.messages[:base]).not_to be_empty
    end
  end

  describe "#notificate" do
    let(:params) { { token: transaction.token } }
    before { allow(PuntoPagos::Notification).to receive(:new).and_return(notification) }

    context "with valid notification" do
      before { allow(notification).to receive(:valid?).with({}, params).and_return(true) }

      it "completes transaction" do
        expect(TransactionService.notificate(params, {})).to eq(
          respuesta: "99", token: transaction.token)
        expect(transaction.reload.state).to eq("completed")
      end

      context "when notification is completed" do
        before { transaction.update_column(:state, "completed") }

        it "does not change status" do
          TransactionService.notificate(params, {})
          expect(transaction.reload.state).to eq("completed")
        end
      end

      context "when notification is rejected" do
        before { transaction.update_column(:state, "rejected") }

        it "does not change status" do
          TransactionService.notificate(params, {})
          expect(transaction.reload.state).to eq("rejected")
        end
      end
    end

    context "with invalid notification" do
      before do
        params[:error] = "error!"
        allow(notification).to receive(:valid?).with({}, params).and_return(false)
      end

      it "rejects the transaction" do
        expect(TransactionService.notificate(params, {})).to eq(
          respuesta: "00", error: params[:error], token: transaction.token)
        expect(transaction.reload.state).to eq("rejected")
        expect(transaction.error).to eq(params[:error])
      end
    end
  end

  describe "#complete" do
    let(:params) { { token: transaction.token } }
    before do
      allow(PuntoPagos::Status).to receive(:new).and_return(status)
      allow(status).to receive(:check).with(
        transaction.token, transaction.id.to_s, transaction.amount_to_s).and_return(true)
    end

    context "with valid status" do
      before { allow(status).to receive(:valid?).and_return(true) }

      it "completes transaction" do
        expect(TransactionService.complete(params)).to be_truthy
        expect(transaction.reload.state).to eq("completed")
        expect(ticket.reload.payment_state).to eq("completed")
      end
    end

    context "with invalid status" do
      before do
        allow(status).to receive(:valid?).and_return(false)
        allow(status).to receive(:error).and_return("error")
      end

      it "completes transaction" do
        expect(TransactionService.complete(params)).to be_truthy
        expect(transaction.reload.state).to eq("rejected")
        expect(transaction.error).to eq("error")
        expect(ticket.reload.payment_state).to eq("rejected")
      end
    end
  end
end
