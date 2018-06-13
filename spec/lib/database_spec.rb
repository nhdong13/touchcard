require 'rails_helper'

describe "rake cardsetup:card_side_to_json", type: :task do

  it "migrates_correctly" do

    old_formats = [
        { shop_id: 75, discount_x: 67, discount_y: 68, discount_pct: -10, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/18a83a77-fe73-4441-a540-a2cabe598567/touchcard-welcome-new-clients-1_front-side.png" },
    # { shop_id: 748, discount_x: 8, discount_y: 42, discount_pct: -15, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/dbdeb11b-e3ec-431b-ab8f-14655a2199c9/VE28_1875x1275_Touchcard_Reverse_2.jpg" },
    # { shop_id: 730, discount_x: 1, discount_y: 73, discount_pct: -20, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/ea70a2e4-ebaf-4256-8e9f-fd5bac514dca/fright_rags_front_1875x1275_brown.jpg" },
    # { shop_id: 39, discount_x: 8, discount_y: 73, discount_pct: -20, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/4e56a7b6-c930-48a3-bb17-c252dc4fe118/Postcard2BackBlankCoupon.jpg" },
    # { shop_id: 858, discount_x: 2, discount_y: 64, discount_pct: -20, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/b36efa57-a455-4cf5-81f3-b8563678296d/SOURCEvapes_1875x1275_back_2.jpg" },
    # { shop_id: 508, discount_x: 3, discount_y: 68, discount_pct: -15, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/45cc53b2-7239-4f4d-9b72-61ceb52d99ea/Touchcard_BACK.jpg" },
    # { shop_id: 538, discount_x: 7, discount_y: 40, discount_pct: -20, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/00a0642c-f968-462c-8b63-0f15db18bfe3/THANK_YOU_CARDS__3_.png" },
    # { shop_id: 674, discount_x: 0, discount_y: 73, discount_pct: -15, discount_exp: 5, image: "https://touchcard-data.s3.amazonaws.com/uploads/9afee744-32b8-41b8-bfca-afcfd31511ed/campus_protein_back_1875x1275_emails.png" },
    # { shop_id: 864, discount_x: 6, discount_y: 21, discount_pct: -15, discount_exp: 2, image: "https://touchcard-data.s3.amazonaws.com/uploads/81e87db0-1a7b-4bdd-811b-5c9f4f3d9980/postcard_thankyou_back.jpg" },
    # { shop_id: 31, discount_x: 7, discount_y: 67, discount_pct: -20, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/af41b8b1-ada2-478f-a020-8475144a7239/TDL_thankyou_postcard_front-V2.jpg" },
    # { shop_id: 855, discount_x: 2, discount_y: 48, discount_pct: -25, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/f778f98a-0b09-43fd-97f9-2d86b66e4159/donkey_tees_back_1875x1275.jpg" },
    # { shop_id: 651, discount_x: 0, discount_y: 73, discount_pct: -15, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/0b65b2c4-427f-4c3b-a85c-5f7d6f5513fa/pawstruck_back_1875x1275.png" },
    # { shop_id: 76, discount_x: 59, discount_y: 5, discount_pct: -10, discount_exp: 10, image: "https://touchcard-data.s3.amazonaws.com/uploads/0062ffd5-7901-4fd8-b832-8590b9c24805/MailerFront2.jpg" },
    # { shop_id: 76, discount_x: 62, discount_y: 66, discount_pct: -10, discount_exp: 10, image: "https://touchcard-data.s3.amazonaws.com/uploads/18fdf858-447c-43d3-b198-4db607a83c98/FinalMailerFront3.jpg" },
    # { shop_id: 842, discount_x: 0, discount_y: 73, discount_pct: -10, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/b6cdd325-bdac-49c6-98e4-453a968e568a/REBEL8_THANKYOU_BACK_1875.jpg" },
    # { shop_id: 4, discount_x: 40, discount_y: 32, discount_pct: -10, discount_exp: 2, image: "https://touchcard-data.s3.amazonaws.com/uploads/53ad1992-c294-4656-8bf2-4df308e31ad2/Clawhammer-front-printfile.jpg" },
    # { shop_id: 741, discount_x: 5, discount_y: 67, discount_pct: -20, discount_exp: 8, image: "https://touchcard-data.s3.amazonaws.com/uploads/dbf21832-4c15-482e-adcf-65000738ee84/touchcardback.jpg" },
    # { shop_id: 679, discount_x: 9, discount_y: 69, discount_pct: -10, discount_exp: 2, image: "https://touchcard-data.s3.amazonaws.com/uploads/0abaa1f7-fbb5-410a-8ffa-58004a0468e7/post_card.jpg" },
    # { shop_id: 99, discount_x: 71, discount_y: 6, discount_pct: -15, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/a0265e80-534b-44f0-90cd-41998659aad8/postcard_shopify3.jpg" },
    # { shop_id: 398, discount_x: 65, discount_y: 40, discount_pct: -20, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/67e48430-71fc-424d-92ff-5bb322cc9dc6/NOTETouchcardPostcard4x6_updatedCTA_Final2.jpg" },
    # { shop_id: 182, discount_x: 13, discount_y: 40, discount_pct: -20, discount_exp: 1, image: "https://touchcard-data.s3.amazonaws.com/uploads/941b4b24-38f5-454c-8683-53a390614c5e/TouchCardFinal_1875x1275.jpg" },
    # { shop_id: 841, discount_x: 2, discount_y: 50, discount_pct: -25, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/b94ab143-7c80-4aea-967b-059bfc1315d1/clotheohio_back_1875x1275.jpg" },
    # { shop_id: 393, discount_x: 3, discount_y: 63, discount_pct: -15, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/bb6e5b70-8de6-4703-9d0e-bda0fd344359/TOUCHCARD_BackV2.jpg" },
    # { shop_id: 394, discount_x: 3, discount_y: 69, discount_pct: -25, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/f26e9e01-2a34-4bd1-9070-2581251bc894/!card1B-front.jpg" },
    # { shop_id: 753, discount_x: 61, discount_y: 1, discount_pct: -20, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/092af34a-44bb-4d3a-b228-8fe2efb61e21/Back_of_Postcard_Design2__2_.png" },
    # { shop_id: 732, discount_x: 5, discount_y: 48, discount_pct: -10, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/adf3d766-699f-4b51-b95e-f770a21cde6e/AA_PostCard_back__3_.jpg" },
    # { shop_id: 535, discount_x: 68, discount_y: 70, discount_pct: -15, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/b41e463a-11ce-469e-af8f-87eceb3abf4c/TouchcardsPostcard_Front.jpg" },
    # { shop_id: 535, discount_x: 6, discount_y: 56, discount_pct: -15, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/fe95e426-84b1-4a3a-91d7-77682962fcf1/TouchcardsPostcard_Back.jpg" },
    # { shop_id: 700, discount_x: 9, discount_y: 9, discount_pct: -10, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/2e2223c7-38f6-4ca5-aa40-032c7ce2d6c5/LWP_postcard_back2.jpg" },
    # { shop_id: 605, discount_x: 2, discount_y: 71, discount_pct: -10, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/6cab187d-a110-467a-be58-b0bca2e074c3/LIV_Promo_Postcard_BACK_01.jpg" },
    # { shop_id: 878, discount_x: 1, discount_y: 70, discount_pct: -20, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/d0fce04f-ca10-42ad-a5a3-26e1e1635d24/dazzle__2__discount_box.jpg" },
    # { shop_id: 482, discount_x: 64, discount_y: 52, discount_pct: -10, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/eed9a01d-49ee-4031-9567-e3dfc20aa101/touch-card-front.fw.png" },
    # { shop_id: 908, discount_x: 43, discount_y: 3, discount_pct: -10, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/e509c726-cfae-4479-9988-a1263a03fa43/Thank_You_Postcard_Back.jpg" },
    # { shop_id: 655, discount_x: 9, discount_y: 70, discount_pct: -10, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/b427d2ec-5686-43c9-a176-543747940629/CDO_Postcard_Back.png" },
    # { shop_id: 258, discount_x: 69, discount_y: 4, discount_pct: -10, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/14caab1f-7ffb-4fae-a81e-7747664d249f/CC_Thankyou1_back.jpg" },
    # { shop_id: 258, discount_x: 2, discount_y: 6, discount_pct: -10, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/68aa732a-c776-43a4-8ca1-95de0bcccd2d/CC_Thankyou1.jpg" },
    # { shop_id: 592, discount_x: 35, discount_y: 64, discount_pct: -25, discount_exp: 2, image: "https://touchcard-data.s3.amazonaws.com/uploads/edd993d1-48bd-4b55-8dc7-62e95af9f047/3postcard_template.jpg" },
    # { shop_id: 739, discount_x: 0, discount_y: 7, discount_pct: -10, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/8601e3f5-7082-4c5e-b464-df31c66694bc/thank_you_for_your_recent_purchase_.png" },
    # { shop_id: 739, discount_x: 4, discount_y: 20, discount_pct: -10, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/9ccfaed4-50f9-4f29-af5d-5b2e5d9e4212/Front_card_1_.png" },
    # { shop_id: 658, discount_x: 70, discount_y: 2, discount_pct: -15, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/7dec3d27-d3d5-4634-8d69-4f900488dda9/PostcardFront.jpg" },
    # { shop_id: 780, discount_x: 0, discount_y: 1, discount_pct: -15, discount_exp: 4, image: "https://touchcard-data.s3.amazonaws.com/uploads/9b852894-dc91-482d-8ff4-83182d3cf9bc/man_with_hands_together_4460x4460_copie.jpg" },
    # { shop_id: 574, discount_x: 1, discount_y: 71, discount_pct: -10, discount_exp: 10, image: "https://touchcard-data.s3.amazonaws.com/uploads/3c1db553-8c61-4e73-9ca0-87547766930c/Omega_Kicks_Postcard_Front___.JPG" },
    # { shop_id: 894, discount_x: 2, discount_y: 67, discount_pct: -10, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/6c5f5e86-5e54-465e-871f-eef2400268d1/Thank_you_note___original.jpg" },
    # { shop_id: 705, discount_x: 3, discount_y: 58, discount_pct: -10, discount_exp: 3, image: "https://touchcard-data.s3.amazonaws.com/uploads/03fc7858-a29e-48e3-abb0-2ee66eff5e14/Untitled_design__2_.png" }
    ]

    old_formats.each do |f|
      front_side = create(:card_side, {image: f[:image], discount_x: f[:discount_x], discount_y: f[:discount_y]})
      co = create(:card_order, {card_side_front: front_side, front_json: {}, back_json: {}, discount_pct: f[:discount_pct], discount_exp: f[:discount_exp] })
    end

    task.execute

    CardOrder.all.each do |co|
      postcard = create(:postcard, card_order: co, sent: false, paid: true, discount_code: "ABC-DEF-GHI", discount_pct: 20)
      output_path =  LobRenderUtil.render_side_png(postcard: postcard, is_front: true)
      puts output_path
    end


    # TODO:
    #   Get an input file with old data
    #   -- How do we get these as renders for comparison?
    #
    #   Create new data
    #   Render new cards
    #
    #   Compare cars (exact comparison may not work, may need to just visually compare)
    #

  end
end
