# Bucket S3
resource "aws_s3_bucket" "app" {
  bucket = "app-bucket-cicd"
  tags = {
    Environment = "localstack"
    ManagedBy   = "terraform"
  }
}

# Fila SQS
resource "aws_sqs_queue" "app" {
  name = "app-queue-cicd"
  tags = {
    Environment = "localstack"
  }
}

# Tabela DynamoDB
resource "aws_dynamodb_table" "app" {
  name         = "app-table-cicd"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "localstack"
  }
}

# Instância EC2 (Exemplo LocalStack)
resource "aws_instance" "app_server" {
  ami           = "ami-00000000" # AMI id fictício para LocalStack
  instance_type = "t2.micro"

  tags = {
    Name        = "app-server-cicd"
    Environment = "localstack"
  }
}
