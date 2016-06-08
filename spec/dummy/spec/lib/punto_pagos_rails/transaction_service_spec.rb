require "rails_helper"

include PuntoPagosRails

RSpec.describe TransactionService do
  let(:ticket) { Ticket.create amount: 22 }
  let(:service) { TransactionService.new(ticket) }
  let(:request) { double }
  let(:response) { double }
  let(:token) { 'XXXXX' }
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
