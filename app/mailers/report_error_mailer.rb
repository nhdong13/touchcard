class ReportErrorMailer < ApplicationMailer

  def send_error_report sending_result
    mg_client = Mailgun::Client.new

    campaigns_query = CardOrder.select(:campaign_name, :campaign_status, :budget, :send_date_start, :send_date_end).find_by_id(Postcard.where("error IS NOT NULL").distinct.pluck(:card_order_id))
    campaigns = ActiveModelSerializers::SerializableResource.new(campaigns_query, {each_serializer: CardOrderSerializer}).serializable_hash
    error_details = Postcard.where("error IS NOT NULL").group(:error).count(:error)

    mail_html_content = ApplicationController.renderer.render template: '/report_error_mailer/send_error_report', layout: 'mailer', locals: {campaigns: campaigns, sending_result: sending_result, error_details: error_details}

    # Define your message parameters
    message_params =  { from: 'mailgun@sandbox7035359c3a924ff9ac2c8f42db30a207.mailgun.org',
                        to:   'tungdv@nustechnology.com',
                        subject: 'The Ruby SDK is awesome!',
                        html: mail_html_content
                      }



    # Send your message through the client
    mg_client.send_message 'sandbox7035359c3a924ff9ac2c8f42db30a207.mailgun.org', message_params

    # For some reason, Mailgun don't recognize sandbox domain when using with Action Mailer
    #
    # mail(to: "tungdv@nustechnology.com", subject: "Testing")
  end
end
