CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: 'AKIAJVI5ONMVWHIYX2RQ',
    aws_secret_access_key: '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',
    region: 'us-east-1',
    :host                   => "s3.amazonaws.com",
    :endpoint               => "https://s3.amazonaws.com",
  }

  config.fog_directory  = 'touchcard-data-dev'
  config.fog_public     = true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
end