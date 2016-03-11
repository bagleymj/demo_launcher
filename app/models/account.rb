class Account < ActiveRecord::Base
  has_many :templates  

  def self.cf_client
    access_key_id = Account.first.access_key_id
    secret_access_key = Account.first.secret_access_key
    region = Account.first.region
    Aws::CloudFormation::Client.new(access_key_id: access_key_id,
                                    secret_access_key: secret_access_key,
                                    region: region)
  end

  def self.ec2_client
    access_key_id = Account.first.access_key_id
    secret_access_key = Account.first.secret_access_key
    region = Account.first.region
    Aws::EC2::Client.new(access_key_id: access_key_id,
                         secret_access_key: secret_access_key,
                         region: region)
  end
  
  
  

end
