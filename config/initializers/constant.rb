LOB_API_VER = "2020-02-11"
TEST_ADDRESS_TO = "adr_8769d8839f5c16c4"
FILTER_OPTIONS =[["Number of orders"  , "number_of_order"   ],
                 ["First order date"  , "first_order_date"  ],
                 ["Last order date"   , "last_order_date"   ],
                #  ["Total Spend"       , "total_spend"       ],
                #  ["Last order total"  , "last_order_total"  ],
                #  ["Shipping country"  , "shipping_country"  ],
                #  ["Shipping state"    , "shipping_state"    ],
                #  ["Shipping city"     , "shipping_city"     ],
                #  ["Referring site"    , "referring_site"    ],
                #  ["Landing site"      , "landing_site"      ],
                #  ["Order tag"        , "order_tag"        ],
                #  ["Discount code used", "discount_code"]
                ]
CONDITIONS = [["Date range", "disable_display_1"], ["is before", "before"], ["is between", "between_date"], ["is after", "after"], 
              ["Days ago", "disable_display_2"], ["is exactly", "matches_number"], ["is between", "between_number"],
              ["is between", "between_string"], ["is exactly", "matches_string"], ["from", "from"], ["is", "tag_is"], ["contains", "tag_contain"]
             ]
EXPORT_FILE_SECTIONS = [["CUSTOMER", 11, "000000"], ["ORDERS", 9, "ed7d31"], ["MARKETING", 4, "ffc000"], ["POSTCARDS", 2, "5b9bd5"], ["STATUS", 3, "70ad47"]]
EXPORT_FILE_COLUMNS = ["Customer_ID", "Type", "F. Name", "L. Name", "Street", "City", "State", "Country", "Zip", "Company", "Abandon checkout", "Order_ID", "Order Date", "Prod. Name", "SKU", "Collection", "Order Quantity", "Item Quantity", "Order Total", "Tags", "Ref. Site", "Land. Site", "Disc. Usage", "Disc. Amount", "Postcard", "Last Postcard", "Marketing", "Fin. Status", "Order Ful. status"]
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
