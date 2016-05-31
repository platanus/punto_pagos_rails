require "rails_helper"

include PuntoPagosRails

RSpec.describe TransactionService do
  let(:ticket) { Ticket.create amount: 22 }
  let(:service) { TransactionService.new(ticket.id) }
  let(:request) { double }
  let(:response) { double }
  let(:token) { 'XXXXX' }
  let(:payment_process_url) { double }
  let(:notification) { double }
  let(:status) { double }
  let(:transaction) do
    PuntoPagosRails::Transaction.create(resource: ticket, token: SecureRandom.base64)
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
          Transaction.create(token: 'REPEATED_TOKEN')
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
          I18n.t("punto_pagos_rails.errors.invalid_puntopagos_response"))
      end
    end
  end

  describe "#validate" do
    before do
      allow(PuntoPagos::Status).to receive(:new).and_return(status)
      allow(status).to receive(:check).with(
        transaction.token, transaction.id.to_s, transaction.amount_to_s)
    end

    it "creates a status object" do
      allow(status).to receive(:valid?).and_return(true)
      TransactionService.validate(transaction.token, transaction)
      expect(PuntoPagos::Status).to have_received(:new)
    end

    context "when the token is valid" do
      it "runs callback after successful payment" do
        allow(status).to receive(:valid?).and_return(true)
        TransactionService.validate(transaction.token, transaction)
        ticket.reload
        expect(ticket.message).to eq("successful payment! #{ticket.id}")
      end
    end

    context "when the token is invalid" do

      it "runs error callback" do
        allow(status).to receive(:valid?).and_return(false)
        allow(status).to receive(:error).and_return("Transaccion Incompleta")
        TransactionService.validate(transaction.token, transaction)
        ticket.reload
        expect(ticket.message).to eq("error paying ticket #{ticket.id}")
      end
    end
  end

  describe "#notificate" do

    before do
      allow(PuntoPagos::Notification).to receive(:new).and_return(notification)
      allow(notification).to receive(:valid?).with({}, {}).and_return(true)
      allow(PuntoPagosRails::Transaction).to receive(:find_by_token).and_return(transaction)
    end

    it "creates a notification" do
      TransactionService.notificate({}, {})
      expect(PuntoPagos::Notification).to have_received(:new)
    end

    context "when the notification is valid" do
      it "runs callback after successful payment" do
        TransactionService.notificate({}, {})
        expect(ticket.message).to eq("successful payment! #{ticket.id}")
      end

      it "the notification is completed" do
        TransactionService.notificate({}, {})
        expect(transaction.reload.state).to eq('completed')
      end
    end

    context "when the notification is invalid" do
      before do
        allow(notification).to receive(:valid?).with({}, {}).and_return(false)
        TransactionService.notificate({}, {})
      end

      it "the notification is rejected" do
        expect(transaction.reload.state).to eq('rejected')
      end

      it "calls error callbacks" do
        expect(ticket.message).to eq("error paying ticket #{ticket.id}")
      end
    end

    context "when the notification is completed" do
      before do
        transaction.update_column :state, 'completed'
      end

      it "should not be rejectable" do
        TransactionService.notificate({}, {})
        expect(transaction.reload.state).to_not eq('rejected')
      end
    end

    context "when the notification is rejected" do
      before do
        transaction.update_column :state, 'rejected'
      end

      it "should not be completable" do
        TransactionService.notificate({}, {})
        expect(transaction.reload.state).to_not eq('completed')
      end
    end
  end
end
