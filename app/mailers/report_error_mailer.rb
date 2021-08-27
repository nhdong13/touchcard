class ReportErrorMailer < ApplicationMailer

  def send_error_report campaign

    all_postcards = campaign.postcards

    @sending_result = {
      card_sent_amount: all_postcards.where(paid: true, sent: true).count,
      error_cards_amount: all_postcards.where("error is NOT NULL").count,
      total_card: all_postcards.count,
    }

    @sending_result[:pending_card] = @sending_result[:total_card] - (@sending_result[:error_cards_amount] + @sending_result[:card_sent_amount])
    @campaign = ActiveModelSerializers::SerializableResource.new(campaign, {each_serializer: CardOrderSerializer}).serializable_hash
    @campaign[:send_date_end] = DatetimeService.new(@campaign[:send_date_end]).to_date
    @campaign[:send_date_start] = DatetimeService.new(@campaign[:send_date_start]).to_date
    @error_detail = all_postcards.select(:id, :error).where("error IS NOT NULL")
    @error_summary = all_postcards.where("error IS NOT NULL").group(:error).count(:error)

    mail(to: "tungdv@nustechnology.com", subject: "Error Report")
  end
end
