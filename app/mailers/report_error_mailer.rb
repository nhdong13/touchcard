class ReportErrorMailer < ApplicationMailer

  def send_error_report campaign

    all_postcards = campaign.postcards

    @sending_result = {
      card_sent_amount: all_postcards.where(paid: true, sent: true).count,
      error_cards_amount: all_postcards.where("error is NOT NULL").count,
      total_card: all_postcards.count
    }

    @campaign = ActiveModelSerializers::SerializableResource.new(campaign, {each_serializer: CardOrderSerializer}).serializable_hash
    @error_details = all_postcards.where("error IS NOT NULL").group(:error).count(:error)

    mail(to: DEV_EMAILS, subject: "Error Report")
  end
end
