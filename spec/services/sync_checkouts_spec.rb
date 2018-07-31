require "rails_helper"

describe SyncCheckouts do
  before(:each) do
    #time = Time.now
    #start_time = time - 24.hours
    #end_time = time - 12.hours
    #shop = create(:shop)
    #stub_count(shop, start_time, end_time)
    #stub_checkouts(shop, start_time, end_time)

    #SyncCheckouts.new(shop, time).call
  end

  it "inserts new abandoned checkout to database" do
    shop = create(:shop)
    stub_count(shop)
    stub_checkouts(shop)

    SyncCheckouts.new(shop).call
    expect(Checkout.count).to eq 1
    expect(Checkout.first.shopify_id).to eq 450789469
    expect(Checkout.first.abandoned_checkout_url).to eq(
      "https://checkout.shopify.com/12/checkouts/d1d6/recover?key=34b4")
  end

  it "can't insert 2 checkouts with the same shopify if" do
    shop = create(:shop)
    stub_count(shop)
    stub_checkouts(shop)

    SyncCheckouts.new(shop).call
    SyncCheckouts.new(shop).call

    expect(Checkout.count).to eq 1
  end
end

def stub_count(shop)
  stub_request(:get, /.*count.json*/).
    with(:headers => {'Accept'=>'application/json',
                      'X-Shopify-Access-Token'=>"#{shop.token}"}).
    to_return(:status => 200, :body => "1", :headers => {})
end

def stub_checkouts(shop)
  stub_request(:get, /.*checkouts.json*/).
    with(:headers => {'Accept'=>'application/json',
                      'X-Shopify-Access-Token'=>"#{shop.token}"}).
    to_return(:status => 200, :body => body_fixture, :headers => {})
end

def body_fixture
  response_text = File.read(
    "#{Rails.root}/spec/fixtures/shopify/checkouts/default.json")
  JSON.parse(response_text).to_json
end
