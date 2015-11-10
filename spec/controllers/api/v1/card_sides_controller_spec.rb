require 'rails_helper'

RSpec.describe Api::V1::CardSidesController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:shop) { create(:shop) }
  let(:other_shop) { create(:shop) }
  let(:card_template) { create(:card_template, shop: shop) }
  let(:card_side) { card_template.card_side_front }

  context 'when not signed in' do
    describe '#show' do
      it '401s' do
        get :show, id: card_side.id
        expect(response.status).to eq(401)
        expect(json).to include('errors')
      end
    end

    describe '#update' do
      it '401s' do
        put :update, id: card_side.id, card_side: { image: 'bah' }
        expect(response.status).to eq(401)
        expect(json).to include('errors')
      end
    end
  end

  context 'logged in' do
    before(:each) { session[:shopify] = shop.id }

    describe '#show' do
      let(:expected_params) { card_side.attributes.slice('id', 'image') }

      context 'when card_side owned by user' do
        context 'if side exists' do
          before(:each ) { get :show, id: card_side.id }

          it 'succeeds' do
            expect(response.status).to eq(200)
          end

          it 'includes id and image' do
            expect(json['card_side']).to include(expected_params)
          end
        end
      end

      context 'when card_side not owned by user' do
        before(:each) { card_template.update_attributes!(shop: other_shop) }

        it '401s' do
          get :show, id: card_side.id
          expect(response.status).to eq(401)
          expect(json).to include('errors')
        end
      end
    end

    describe '#update' do
      context 'if side exists' do
        it 'succeeds' do
          put :update, id: card_side.id, card_side: { image: 'New Image' }
          expect(response.status).to eq(200)
        end

        it 'updates image' do
          put :update, id: card_side.id, card_side: { image: 'New Image' }
          db_card_side = CardSide.find(card_side.id)
          expect(db_card_side.image).to eq('New Image')
        end
      end

      context 'if side does not exist' do
        it '404s' do
          put :update, id: -1, card_side: { image: 'New Image' }
          expect(response.status).to eq(404)
        end
      end

      context 'when card_side not owned by user' do
        before(:each) { card_template.update_attributes!(shop: other_shop) }

        it '401s' do
          put :update, id: card_side.id, card_side: { image: 'New Image' }
          expect(response.status).to eq(401)
          expect(json).to include('errors')
        end
      end
    end
  end
end
