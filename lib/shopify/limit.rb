# Mixin to keep track for shopifies api rate limit
# You can avarage 2 calls per second to shopify api
module Shopify
  module Limit
    CYCLE = 0.5 # You can average 2 calls per second

    def wait_for_next(start_time, pages)
      return if pages <= 1
      stop_time = Time.now
      processing_duration = stop_time - start_time
      wait_time = (CYCLE - processing_duration).ceil
      sleep wait_time if wait_time > 0
      start_time = Time.now
    end
  end
end
