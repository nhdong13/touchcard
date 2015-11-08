describe API::V1::PostcardsController do
  require 'spec_helper'
  include SpecTestHelper

  let (:postcard)   { create(:postcard) }
  let (:postcard1)  { create(:postcard) }

  describe "Postcards Index" do
    describe "not logged in" do
      it "should have status 302" do
        get :index

        expect(response.status).to eq(302)
      end
    end

    describe "logged in" do
      it "should have status 200" do
        login(postcard.shop)
        get :index

        expect(response.status).to eq(200) # TODO: Update serializer to return array
      end

      it "should return both postcards" do
        login(postcard.shop)
        get :index

        json = JSON.parse(response.body)
        expect(json['postcard']).to eq("2") # TODO: Figure out index body
      end
    end
  end

  describe "Show postcard" do
    describe "with unknown id" do
      it "should respond with 404" do
        login(postcard.shop)
        get :show, id: (postcard.id + 1)

        expect(response.status).to eq(404)
      end
    end

    describe "with known id" do
      it "should respond with 200" do
        login(postcard.shop)
        get :show, id: postcard.id

        expect(response.status).to eq(200)
      end
    end
  end

  # TODO: Should there be tests for create and update since only the server will do that?
end
