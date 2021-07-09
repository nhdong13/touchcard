class FaqController < BaseController
  def index
    @questions = [
      {
        question: 'Can I send to existing customers or manually select which customers get a postcard?',
        answer: 'Yes, we can send postcards to any customer segment you like using our one-off campaigns. To get started with a one-off or learn how they work, please contact support below.'
      },{
        question: 'How can I improve the ROI on my Touchcard campaign?',
        answer: 'There are a number of ways you can improve your Touchcard ROI. See our free guide on how to optimize your campaign for maximum ROI <a href="https://help.touchcard.co/help/how-to-optimize-your-touchcard-campaign-for-maximum-roi" target="_blank">on our website</a>.'
      },{
        question: 'How can I track sales generated by Touchcard?',
        answer: 'You can view all the sales generated by Touchcard on the Dashboard tab at the top of the page.'
      },{
        question: 'How much does Touchcard cost, and how does pricing work?',
        answer: "It costs $#{Plan.last.amount.to_f/100} to print and mail a postcard in the USA with no other costs to use the app. You can subscribe to whatever number of credits you need each month. Subscriptions can be changed or canceled at any time. If you need a custom quantity that is not available please get in touch with support."
      },{
          question: 'How do discount codes work?',
          answer: 'Touchcard’s discount code feature automatically generates unique discounts for every customer. Discounts are generated right before printing and will appear in your Shopify admin panel. For instruction on setting up this feature, see our <a href="https://help.touchcard.co/help/how-to-setup-a-successful-touchcard-campaign" target="_blank">setup guide</a>.'
      }
      # ,{
      #     question: 'Can I send postcards internationally?',
      #     answer: 'Yes, we can send postcards to anywhere you like. Due to additional costs for international postage, postcards sent outside of the USA cost two credits instead of one.'
      # }
    ]
  end
end
