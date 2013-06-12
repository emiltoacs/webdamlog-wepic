# specific requirement of wepic database
module DatabaseWepicSpec

  attr_reader :tables

  # PENDING specify here all the needed wrapper for wepic and check implementation at loading

  def check_tables
    %w(
    Picture
    PictureLocation
    Rating
    Comment
    Contact
    ).each do |tables|
      # TODO check ActiveRecord presence and schema
    end
  end

end