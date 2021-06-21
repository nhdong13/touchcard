module S3TestHelper
  def temp_s3_upload(file_key, file_path)
    bucket_name = 'touchcard-ci-temp'
    temp_bucket = Aws::S3::Resource.new(
      region: 'us-east-1',
      credentials: Aws::Credentials.new(ENV['AWS_TEST_ACCESS_KEY_ID'], ENV['AWS_TEST_SECRET_ACCESS_KEY'])
      ).bucket(bucket_name)
    obj = temp_bucket.object(file_key)
    obj.upload_file(file_path)

    # Set access on S3 to public
    s3 = Aws::S3::Client.new(
      region: 'us-east-1',
      credentials: Aws::Credentials.new(ENV['AWS_TEST_ACCESS_KEY_ID'], ENV['AWS_TEST_SECRET_ACCESS_KEY'])
      )
    s3.put_object_acl(bucket: bucket_name, key: file_key, acl: 'public-read')

    # return the public url
    return obj.public_url.to_s
  end
end




