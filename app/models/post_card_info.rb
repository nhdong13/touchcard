class PostCardInfo < ApplicationRecord
  mount_uploader :front_design, FrontDesignUploader
  mount_uploader :back_design, BackDesignUploader
end
