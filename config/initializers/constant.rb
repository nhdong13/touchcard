LOB_API_VER = "2020-02-11"
TEST_ADDRESS_TO = "adr_8769d8839f5c16c4"
FILTER_OPTIONS =[["Select a filter"   , ""                  ],
                 ["Number of orders"  , "number_of_order"   ],
                 ["Total Spend"       , "total_spend"       ],
                 ["Order date"        , "order_date"        ],
                 ["Last order total"  , "last_order_total"  ],
                 ["Shipping country"  , "shipping_country"  ],
                 ["Shipping state"    , "shipping_state"    ],
                 ["Shipping city"     , "shipping_city"     ],
                 ["Referring site"    , "referring_site"    ],
                 ["Landing site"      , "landing_site"      ],
                 ["Order tag"         , "order_tag"         ],
                 ["Discount code used", "discount_code_used"]
                ]
CONDITIONS = [["Select a filter" , ""], ["is", "0"], ["is greater than", "1"], ["is less than", "2"],
              ["Absolute", "disable_display_1"], ["before", "before"], ["between", "between_date"], ["after", "after"], 
              ["Relative", "disable_display_2"], ["between", "between_number"], ["matches", "matches_number"],
              ["between", "between_string"], ["matches", "matches_string"], ["from", "from"]
             ]
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
