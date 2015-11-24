class Api::V1::AwsController < Api::BaseController
  def sign
    bucket = Aws::S3::Resource.new.bucket("touchcard-user")
    @s3_direct_post = bucket.presigned_post(
      key: "uploads/#{SecureRandom.uuid}/${filename}",
      success_action_status: "201",
      acl: "public-read",
      expires: 1.hours.from_now
    )
    render json: @s3_direct_post.fields, status: :ok
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
