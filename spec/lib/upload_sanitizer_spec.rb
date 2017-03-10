require "rails_helper"
require "upload_sanitizer"

RSpec.describe UploadSanitizer do

  describe "#file_name" do
    it "replaces all s3 special characters with string empty" do
      name = "jpgtest%$&=@:+,?{}\[]<>#^`.jpg"
      sanitizer = UploadSanitizer.new(name)
      expect(sanitizer.new_name).to eq "jpgtest.jpg"
    end

    it "catches parentheses in filename" do
      name = "on)etree_touchcard_reverse0))0(1))).png"
      sanitizer = UploadSanitizer.new(name)
      expect(sanitizer.new_name).to eq "onetree_touchcard_reverse001.png"
    end

    it "generates random name, name is blank after replace" do
      name = "%$&=@:+,?{}\[]<>#^`.png"
      sanitizer = UploadSanitizer.new(name)
      expect(sanitizer.new_name.length).to eq 14
    end
  end
end
