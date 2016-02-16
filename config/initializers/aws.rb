unless Account.all.empty?
  access_key_id = Account.all[0].access_key_id
  secret_access_key = Account.all[0].secret_access_key

  Aws.config.update({
    :region => 'us-east-1',
    :access_key_id => access_key_id,
    :secret_access_key => secret_access_key
  })
end
