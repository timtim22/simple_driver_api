require 'net/http'
require 'uri'
require 'openssl'
require 'base64'
require 'digest'
require 'cgi'

class BlobStorageService
  def self.store(blob, data)
    case ENV['STORAGE_BACKEND']
    when 's3'
      store_in_s3(blob, data)
    when 'local'
      store_locally(blob, data)
    when 'ftp'
      store_ftp(blob, data)
    when 'database'
      store_in_database(blob, data)
    else
      false
    end
  end

  def self.store_in_s3(blob, data)
    uri = URI("https://s3.eu-west-1.amazonaws.com/#{ENV['AWS_BUCKET']}/#{blob.id}")

    date = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    datestamp = Time.now.utc.strftime("%Y%m%d")
    canonical_uri = "#{blob.id}"
    canonical_querystring = ''

    payload_hash = Digest::SHA256.hexdigest(data)
    
    canonical_headers = [
      "host:#{ENV['AWS_BUCKET']}.s3.amazonaws.com",
      "x-amz-date:#{date}",
      "x-amz-content-sha256:#{payload_hash}"
    ].join("\n") + "\n"

    signed_headers = 'host;x-amz-content-sha256;x-amz-date'

    canonical_request = [
      "PUT",
      canonical_uri,
      canonical_querystring,
      canonical_headers,
      signed_headers,
      payload_hash
    ].join("\n")

    canonical_request_hash = Digest::SHA256.hexdigest(canonical_request)

    algorithm = 'AWS4-HMAC-SHA256'
    credential_scope = "#{datestamp}/#{ENV['AWS_REGION']}/s3/aws4_request"
    string_to_sign = [
      algorithm,
      date,
      credential_scope,
      canonical_request_hash
    ].join("\n")

    signing_key = get_signature_key(ENV['AWS_SECRET_ACCESS_KEY'], datestamp, ENV['AWS_REGION'], 's3')

    signature = OpenSSL::HMAC.hexdigest('sha256', signing_key, string_to_sign)

    authorization_header = [
      "#{algorithm} Credential=#{ENV['AWS_ACCESS_KEY_ID']}/#{credential_scope}",
      "SignedHeaders=#{signed_headers}",
      "Signature=#{signature}"
    ].join(', ')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Put.new(uri.request_uri)
    request['Authorization'] = authorization_header
    request['x-amz-date'] = date
    request['x-amz-content-sha256'] = payload_hash
    request.body = data

    response = http.request(request)

    if response.code.to_i == 200
      true
    else
      Rails.logger.error "Failed to store blob locally: #{response.code} - #{response.body}"
      false
    end
  end

  def self.store_locally(blob, data)
    Dir.mkdir(ENV['STORAGE_DIRECTORY']) unless Dir.exist?(ENV['STORAGE_DIRECTORY'])

    file_name = "#{blob.id}_#{Time.now.to_i}"
    file_path = File.join(ENV['STORAGE_DIRECTORY'], file_name)

    File.open(file_path, 'wb') { |file| file.write(data) }

    blob.path = file_path
    true
  rescue StandardError => e
    Rails.logger.error "Failed to store blob locally: #{e.message}"
    false
  end

  def self.store_in_database(blob, data)
    blob_data = blob.blob_data || blob.build_blob_data
    blob_data.data = data
    blob_data.save
    true
  rescue StandardError => e
    Rails.logger.error "Failed to store blob in database: #{e.message}"
    false
  end

  def self.store_ftp(blob, data)
    file_name = "#{blob.id}_#{Time.now.to_i}"

    Net::FTP.open(ENV['FTP_HOST'], ENV['FTP_USER'], ENV['FTP_PASSWORD']) do |ftp|
      ftp.passive = true
      ftp.chdir(ENV['FTP_DIRECTORY'])
      ftp.storbinary("STOR #{file_name}", StringIO.new(data), Net::FTP::DEFAULT_BLOCKSIZE)
    end

    blob.path = File.join(ENV['FTP_DIRECTORY'], file_name)
    true
  rescue StandardError => e
    Rails.logger.error "Failed to store blob ##{blob.id} via FTP: #{e.message}"
    false
  end

  def self.get_signature_key(key, date_stamp, region_name, service_name)
    k_date = OpenSSL::HMAC.digest('sha256', "AWS4" + key, date_stamp)
    k_region = OpenSSL::HMAC.digest('sha256', k_date, region_name)
    k_service = OpenSSL::HMAC.digest('sha256', k_region, service_name)
    k_signing = OpenSSL::HMAC.digest('sha256', k_service, "aws4_request")
    k_signing
  end
end

