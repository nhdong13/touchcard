module CardHtml
  module_function
  def generate(options)
    discount_html = ""
    discount_html = "
      <div class=\"discount\">
        <div class=\"percent\">#{options[:discount_pct]}% OFF</div>
        <div class=\"code\">#{options[:discount_code]}</div>
        <div class=\"expiration\">EXPIRES #{options[:discount_exp]}</div>
      </div>
    " if options[:discount_code].present?

    "
    <html>
      <head>
        <link href='https://fonts.googleapis.com/css?family=Montserrat:400,700' rel='stylesheet' type='text/css'>
        <style>
          *, *:before, *:after {
            -webkit-box-sizing: border-box;
            -moz-box-sizing: border-box;
            box-sizing: border-box;
          }

          body {
            width: 6.25in;
            height: 4.25in;
            margin: 0;
            padding: 0;
            background-image: url(#{options[:background_image]});
            background-size: 6.25in 4.25in;
            background-repeat: no-repeat;
          }

          #safe-area {
            position: absolute;
            width: 5.875in;
            height: 3.875in;
            left: 0.1875in;
            top: 0.1875in;
          }

          .discount {
            position: absolute;
            top: 33%;
            left: 40.5%;
            width: 28%;
            height: 25%;
            text-align: center;
            padding: 1%;
            font-family: 'Montserrat';
          }

          .percent {
            font-size: 0.30in;
            font-weight: 800;
            margin: 0.06in 0 0;
          }

          .code {
            font-size: 0.17in;
          }

          .expiration {
            margin-top: 0.11in;
            font-size: 0.09in;
          }
        </style>
      </head>

      <body>
        <div id=\"safe-area\">
          #{discount_html}
        </div>
      </body>
    </html>
    "
  end
end
