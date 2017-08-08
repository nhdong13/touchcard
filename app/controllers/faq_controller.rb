class FaqController < ApplicationController
  def index
    @questions = [
      {
        question: 'What are the guidelines for creating a card?',
        answer: 'You can download our postcard guidelines for the <a href="/images/address-side-guide.jpg" target="_blank">address side</a> and <a href="/images/image-side-guide.jpg" target="_blank">image side</a>. Both sides of the card must be 6.25"x4.25" and 300 dpi. The cards are cut down to 6"x4" in the process. We accept image files. Any ink in the postage address area will be removed. For the coupon, we automatically print the coupon details in the drag and drop square that measure 1.7"x1"'
      },{
        question: 'Are there any additional monthly costs besides the .99 cents for the card?',
        answer: 'We allow to send your full plan amount and only charge .99 cents for both printing and mailing, and 1.99 for printing and mailing internationally'
      },{
        question: 'When are my cards sent?',
        answer: 'You can setup the delay in "post-sale" postcard page. The delay is calculated from the time the order comes in.'
      },{
        question: 'How is the revenue tracked in the dashboard?',
        answer: 'After we send a customer a postcard, we keep track to see if they made a second purchase and then reflect it on your dashboard. Or if they sent the coupon to a friend to use and they made a purchase.'
      }
    ]
  end
end
