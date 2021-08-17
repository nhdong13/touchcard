class ReportErrorMailer < ApplicationMailer

  def send_error_report
    mg_client = Mailgun::Client.new

    testing = Shop.find(6).card_orders.last(10)
    campaigns = ActiveModelSerializers::SerializableResource.new(testing, {each_serializer: CardOrderSerializer}).serializable_hash

    mail_html_content = ApplicationController.renderer.render template: '/report_error_mailer/send_error_report', layout: 'mailer', locals: {campaigns: campaigns}

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
