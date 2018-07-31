module GtmHelper

  # GTM_ID
  # "GTM-P74SBS2" # touchcard-development
  # "GTM-PH73XG2" # touchcard.herokuapp.com

  # GTM_ENVIRONMENT_PARAMS - only used in production (touchcard.herokuapp.com)
  # "&gtm_auth=Vu4BC2LBqiawRiIX2VOn4g&gtm_preview=env-2&gtm_cookies_win=x"  # Live
  # "&gtm_auth=n553XLcYVrmY05MZ2RjQyA&gtm_preview=env-5&gtm_cookies_win=x"  # 'Development'
  #
  # Note: Reamaze doesn't care. It only pushes to LIVE / Production


  def gtm_head_tag
    return unless gtm_id = ENV.fetch('GTM_ID', nil)
    environment_params = ENV.fetch('GTM_ENVIRONMENT_PARAMS', nil)
        tag = <<~HEREDOC
      <!-- Google Tag Manager -->
      <script>
      document.addEventListener('turbolinks:load', function(event) {
        var url = event.data.url;  
        dataLayer.push({
          'event': 'pageView',
          'virtualUrl': url
        });
      });
      (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
      new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
      j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
      'https://www.googletagmanager.com/gtm.js?id='+i+dl+ '#{environment_params}';f.parentNode.insertBefore(j,f);
      })(window,document,'script','dataLayer','#{gtm_id}');</script>
      <!-- End Google Tag Manager -->
    HEREDOC
    tag.html_safe
  end

  def gtm_body_tag
    return unless gtm_id = ENV.fetch('GTM_ID', nil)
    environment_params = ENV.fetch('GTM_ENVIRONMENT_PARAMS', nil)
    tag = <<~HEREDOC
      <!-- Google Tag Manager (noscript) -->
      <noscript><iframe src="https://www.googletagmanager.com/ns.html?id=#{gtm_id}#{environment_params}"
      height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
      <!-- End Google Tag Manager (noscript) -->
    HEREDOC
    tag.html_safe
  end

end
