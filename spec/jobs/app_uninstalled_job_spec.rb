require 'rails_helper'

RSpec.describe ShopUninstalledJob, type: :job do
  include ActiveJob::TestHelper

  let(:shop) { create(:shop, credit: 2, domain: 'testshop1.myshopify.com') }
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
    expect(ShopUninstalledJob.new.queue_name).to eq('default')
  end

  describe '#perform' do
    before :each do
      stub_slack_notify
      perform_enqueued_jobs { job }
    end

    it 'sets shop credit to 0' do
      credit = Shop.where(domain: shop.domain).first.credit
      expect(credit).to eq 0
    end

    it 'uninstalls Shop' do
      uninstalled_at = Shop.where(domain: shop.domain).first.uninstalled_at
      expect(uninstalled_at).not_to eq nil
    end
  end
end
