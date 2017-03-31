require 'rails_helper'

RSpec.describe AppUninstalledJob, type: :job do
  include ActiveJob::TestHelper

  let(:shop) { create(:shop, domain: 'testshop1.myshopify.com') }
  let(:plan) { create(:plan) }
  let!(:subscription) { Subscription.create(shop: shop, quantity: 1, plan: plan) }
  subject(:job) do
    webhook_text = File.read("#{Rails.root}/spec/fixtures/shopify/webhooks/app_uninstalled.json")
    webhook_obj = JSON.parse(webhook_text).with_indifferent_access
    described_class.perform_later(shop_domain: shop.domain, webhook: webhook_obj)
  end

  def stub_slack_notify
    stub_request(:post, "https://hooks.slack.com/services/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").
         with(:body => "{\"text\":\"A shop has uninstalled Touchcard: testshop1.myshopify.com.\"}",
              :headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'69', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => "", :headers => {})
  end

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(AppUninstalledJob.new.queue_name).to eq('default')
  end

  it 'uninstalls shop' do
    puts shop.subscriptions.length
    stub_slack_notify
    perform_enqueued_jobs { job }
    expect(Shop.where(domain: shop.domain).count).to eq 0
  end

end
