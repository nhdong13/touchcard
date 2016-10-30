class ChangeS3BucketPathsInCardSides < ActiveRecord::Migration

  # We need to move S3 bucket names. This replaces URLS pointed to by our
  # previous bucket 'touchcard-user' to our new bucket 'touchcard-data'

  def up
    CardSide.where("image IS NOT NULL").each do |side|
      side.image.sub! "https://touchcard-user.s3.amazonaws.com", "https://touchcard-data.s3.amazonaws.com"
      side.save!
    end
  end

  def down
    # This migration should not be reversed. We're losing access to 'touchcard-user'.
  end
end
