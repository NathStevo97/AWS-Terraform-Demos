terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "eu-west-2"
    dynamodb_table = "your_dynambodb_state_table"
  }
}