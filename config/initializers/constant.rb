LOB_API_VER = "2020-02-11"
TEST_ADDRESS_TO = "adr_8769d8839f5c16c4"
FILTER_OPTIONS = [["Number of orders", "number_of_order" ],
                  ["Total Spend"     , "total_spend"     ],
                  ["Last order date" , "last_order_date" ],
                  ["First order date", "first_order_date"],
                  ["Last order total", "last_order_total"]
                 ]
CONDITIONS = [["is", 0], ["is greater than", 1], ["is less than", 2],
              ["before", 3], ["between", 4], ["after", 5], ["before", 6],
              ["between", 7], ["after", 8]]
