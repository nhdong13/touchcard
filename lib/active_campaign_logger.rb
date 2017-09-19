
# This class is for logging ActiveCampaign calls that are called from
# Delayed Job. Since DelayedJob logging in Heroku requires STDOUT/STDERR
# logging we use Puts.

# This should probably be a generic puts logging class for DelayedJob instead

class ActiveCampaignLogger
  def self.log(method_params, method_result)
    puts "#{'ERROR: ' unless (method_result["result_code"] == 1)}ActiveCampaign\n"
    puts "Method Params: #{method_params}"
    puts "Method Result: #{method_result}"
  end
end
