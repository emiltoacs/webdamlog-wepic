# specific requirement of wepic database
# PENDING centrenlize here the loading of all the wrapper instead of soing it in wldatabase
module WrapperHelper::DatabaseWepicSpec

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