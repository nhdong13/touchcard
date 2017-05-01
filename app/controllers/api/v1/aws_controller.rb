require "upload_sanitizer"

class Api::V1::AwsController < Api::BaseController
  def sign
    bucket_name = ENV["AWS_BUCKET_NAME"]
    bucket = Aws::S3::Resource.new(region: 'us-east-1').bucket(bucket_name)
    sanitizer = UploadSanitizer.new(params[:name])
    @s3_direct_post = bucket.presigned_post(
      key: "uploads/#{SecureRandom.uuid}/#{sanitizer.sanitize}",
      success_action_status: "201",
      acl: "public-read"
    )
    render json: @s3_direct_post.fields.merge(bucket: bucket_name), status: :ok
  end
  # def sign
  #   @expires = 1.hours.from_now
  #   render json: {
  #     acl: "public-read",
  #     awsaccesskeyid: ENV["AWS_ACCESS_KEY_ID"],
  #     bucket: "touchcard-user",
  #     expires: @expires,
  #     key: "uploads/#{params[:name]}",
  #     policy: policy,
  #     signature: signature,
  #     success_action_status: "201",
  #     "Content-Type" => params[:type],
  #     "Cache-Control" => "max-age=630720000, public"
  #   }, status: :ok
  # end
  #
  # def signature
  #   Base64.strict_encode64(
  #     OpenSSL::HMAC.digest(
  #       OpenSSL::Digest::Digest.new("sha1"),
  #       ENV["AWS_SECRET_ACCESS_KEY"],
  #       policy(secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
  #     )
  #   )
  # end
  #
  # def policy(options = {})
  #   Base64.strict_encode64(
  #     {
  #       expiration: @expires,
  #       conditions: [
  #         { bucket: "touchcard-user" },
  #         { acl: "public-read" },
  #         { expires: @expires },
  #         { success_action_status: "201" },
  #         [ "starts-with", "$key", "" ],
  #         [ "starts-with", "$Content-Type", "" ],
  #         [ "starts-with", "$Cache-Control", "" ],
  #         [ "content-length-range", 0, 524288000 ]
  #       ]
  #     }.to_json
  #   )
  # end
end
