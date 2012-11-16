class Gedifilename < ActiveRecord::Base
  belongs_to :gedifile  
  has_many :accesshistories
  
  def generate_token
    self.auth_token = SecureRandom.urlsafe_base64
    self.auth_token_timestamp = Time.zone.now
    save!
  end 
end
