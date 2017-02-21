require "rails_helper"
require "upload_sanitizer"

RSpec.describe UploadSanitizer do

  describe "#sanatize" do
    SPECIAL_CHARACTERS = ['%', '$', '&', '=', '@', ':', '+',
                          ',', '?', '{', '}', "\\", "\[", "\]",
                          '<', '>', '#', '^', '`']

    SPECIAL_CHARACTERS.each do |char|
      it "replaces #{char} s3 special character with underscore" do
        name = "test#{char}image#{char}url#{char}5.jpg"
        sanitizer = UploadSanitizer.new(name)
        expect(sanitizer.sanatize).to eq "test_image_url_5.jpg"
      end
    end

    it "replaces all s3 special characters with underscore" do
      name = "A%B$c&d=e@F:g+H,i?j{k}\\l[m]<n>o#P^r`s5.jpg"
      sanitizer = UploadSanitizer.new(name)
      expect(sanitizer.sanatize).to eq "A_B_c_d_e_F_g_H_i_j_k__l_m__n_o_P_r_s5.jpg"
    end
  end
end
