class ReportErrorMailer < ApplicationMailer

  def send_error_report
    @sending_result = {
      card_sent_amount: Postcard.where(paid: true, sent: true).count,
      error_cards_amount: Postcard.where("error is NOT NULL").count,
      total_card: Postcard.count
    }
    campaigns_query = CardOrder.find(Postcard.where("error IS NOT NULL").distinct.pluck(:card_order_id))
    @campaigns = ActiveModelSerializers::SerializableResource.new(campaigns_query, {each_serializer: CardOrderSerializer}).serializable_hash
    @error_details = Postcard.where("error IS NOT NULL").group(:error).count(:error)

    DEV_EMAILS.each do |mail|
      mail(to: mail, subject: "Error Report")
    end
  end
end
