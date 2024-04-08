This Simple Storage API provides a flexible and efficient way to store and retrieve blob data, supporting multiple storage backends including local filesystem, Amazon S3, and FTP servers. Designed with scalability and simplicity in mind, this Ruby on Rails application offers an intuitive RESTful interface for uploading and accessing blob data, making it ideal for a wide range of data storage scenarios.

Features
Multi-backend Support: Seamlessly switch between local, S3, FTP, and database storage options based on environmental configuration.
Base64 Data Handling: Accepts and returns data encoded in Base64, ensuring safe transmission of binary data over HTTP.
Flexible Blob Identifiers: Utilize custom or generated IDs for easy data reference and retrieval.
Secure Access: Implement token-based authentication to ensure that blob operations are securely managed.
Scalable Architecture: Built on Ruby on Rails, ready to scale with your application's needs.


Getting Started
Follow these instructions to get the Simple Storage API up and running on your local machine for development and testing purposes.
Prerequisites
Ruby version: 2.7 or newer
Rails version: 6.0 or newer
PostgreSQL for the database
An Amazon S3 account for S3 storage (optional)
Access to an FTP server for FTP storage (optional)


Installation
Clone the repository: git clone https://github.com/your-username/simple-storage-api.git
cd simple-storage-api

Install dependencies:
bundle install

Setup the database:
rails db:create db:migrate

Configure environment variables by creating a .env file in the root directory and setting the necessary values:

STORAGE_BACKEND=s3
AWS_BUCKET=myawsblobbucket
AWS_REGION=eu-west-1
AWS_SECRET_ACCESS_KEY=Akj4KokdYAPs6fvmM+B1K\/66QKHPKaKbzc\/AYZ3O
AWS_ACCESS_KEY_ID=AKIARXZCWR4WQYZM5V6Y
STORAGE_DIRECTORY=/Users/taimoor/Downloads
FTP_HOST=ftp://ftp.example.com
FTP_USER=ftpuser
FTP_PASSWORD=ftppassword
FTP_DIRECTORY=/path/to/ftp/directory


Start the server:
rails server

To upload a blob:
curl -X POST http://localhost:3000/blobs \
  -H 'Content-Type: application/json' \
  -d '{"id": "unique_blob_id", "data": "base64_encoded_data"}'


To retrieve a blob:
curl http://localhost:3000/blobs/unique_blob_id


Testing
Run tests using RSpec:

rspec