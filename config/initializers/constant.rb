LOB_API_VER = "2020-02-11"
TEST_ADDRESS_TO = "adr_8769d8839f5c16c4"
FILTER_OPTIONS =[["Number of orders"         , "number_of_order"   ],
                 ["First order date"         , "first_order_date"  ],
                 ["Last order date"          , "last_order_date"   ],
                 ["Total spent on last order", "last_order_total"  ],
                 ["Total spent on all orders", "all_order_total"   ],
                 ["Discount amount received" , "discount_amount"   ],
                 ["Shipping country"         , "shipping_country"  ],
                 ["Shipping state"           , "shipping_state"    ],
                 ["Shipping city"            , "shipping_city"     ],
                 ["Referring site"           , "referring_site"    ],
                 ["Landing site"             , "landing_site"      ],
                 ["Order tag"                , "order_tag"         ],
                 ["Discount code used"       , "discount_code"     ],
                 ["Shipping company exists"  , "shipping_company"  ],
                 ["Shipping zip code"        , "zip_code"          ]
                ]
CONDITIONS = [["Date range", "disable_display_1"],
              ["is equal to", "matches_date"],
              ["is on or between", "between_date"],
              ["is on or before", "before"],
              ["is on or after", "after"], 
              ["Days ago", "disable_display_2"],
              ["is equal to", "matches_number"],
              ["is equal to or between", "between_number"],
              ["is equal to or more than", "greater_number"],
              ["is equal to or less than", "smaller_number"],
              ["is between", "between_string"],
              ["is exactly", "matches_string"],
              ["is contain", "contain_string"],
              ["is exactly", "discount_amount_matches"],
              ["is between", "discount_amount_between"],
              ["from", "from"],
              ["is", "tag_is"],
              ["contains", "tag_contain"],
              ["Begins with", "begin_with"],
              ["Ends with", "end_with"],
              ["No", "no"],
              ["Yes", "yes"],
              ["is", "equal"]
             ]
EXPORT_FILE_SECTIONS = [["CUSTOMER", 11, "000000"], ["ORDERS", 9, "ed7d31"], ["MARKETING", 4, "ffc000"], ["POSTCARDS", 2, "5b9bd5"], ["STATUS", 3, "70ad47"]]
EXPORT_FILE_COLUMNS = ["Customer_ID", "Type", "F. Name", "L. Name", "Street", "City", "State", "Country", "Zip", "Company", "Abandon chkt", "Order ID", "Order Date", "Prod. Name", "SKU", "Collection", "Order Qty", "Item Qty", "Order Total", "Tags", "Ref. Site", "Land. Site", "Disc. Usage", "Disc. Amount", "Postcard Qty", "Last Postcard Rcvd", "Marketing", "Fin. Status", "Order Ful. status", "Send", "And/Or"]
CSV_TITLE = [ "Fullame",
              "Email",
              "Shipping Company",
              "Shipping Address line 1",
              "Shipping City",
              "Shipping State",
              "Shipping Country",
              "Shipping Postal Code",
              "Shipping Phone",
              "Billing Company",
              "Billing Address line 1",
              "Billing City",
              "Billing State",
              "Billing Country",
              "Billing Postal code",
              "Billing Phone",
              "Number of Orders",
              "Total Spend",
              "Last Order Date",
              "Last Order Fulfillment Status",
              "Last Order Total",
              "First Order Date",
              "Postcards Received",
              "Last postcard received",
              "Accepts marketing",
              "Account status"
            ]
DEV_EMAILS = [
  # "tungdv@nustechnology.com",
  # "hoaiptp@nustechnology.com",
  "donghn@nustechnology.com",
  "hungpn@nustechnology.com",
  "danhtd@nustechnology.com"
]

MAXIMUM_CAMPAIGN_NAME_LENGTH = 60
SINGLE_POSTCARD_PRICE = 0.89
