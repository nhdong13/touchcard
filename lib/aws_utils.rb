module AwsUtils

  def upload_to_s3(file_key, file_path)
    obj = S3_BUCKET.object(file_key)
    obj.upload_file(file_path)

    # Set access on S3 to public
    s3 = Aws::S3::Client.new
    s3.put_object_acl(bucket: ENV['S3_BUCKET_NAME'], key: file_key, acl: 'public-read')

    # return the public url
    return obj.public_url.to_s
  end

  def delete_from_s3(delete_url)
    S3_BUCKET.objects.each do |obj|
      if obj.public_url.to_s == delete_url
        S3_BUCKET.objects.delete(obj.key)
      end
    end
  end
end
