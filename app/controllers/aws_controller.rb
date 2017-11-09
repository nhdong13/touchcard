require "upload_sanitizer"

class AwsController < BaseController

  def sign
    bucket_name = ENV["S3_BUCKET_NAME"]
    sanitizer = UploadSanitizer.new(params[:name])
    key = "uploads/#{SecureRandom.uuid}/#{sanitizer.sanitize}"
    s3_object = Aws::S3::Resource.new(region: 'us-east-1').bucket(bucket_name).object(key)
    signed_url = s3_object.presigned_url(:put)
    url = signed_url.split('?').first

    render json: { signedUrl: signed_uri.to_s, url: url }, status: ok

  end

end
