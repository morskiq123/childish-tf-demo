##################################
############## S3 ################
##################################
resource "aws_s3_bucket" "app_s3_bucket" {
    bucket = "${var.app_name}" 
    # the name of the bucket can create an issue if for say
    # we have to deploy different buckets for different 
    # environments. This is something that we need ot keep in mind
  
}

#####################################
########### Dynamo DB ###############  
#####################################

resource "aws_dynamodb_table" "app_dynamo_db" {
  name           = "${var.app_name}-table"
  read_capacity  = 5
  write_capacity = 5
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}