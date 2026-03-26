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

# IAM Role para Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Zip do código da Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Função Lambda
resource "aws_lambda_function" "hello_world" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "hello_world_lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      ENV = "localstack"
    }
  }

  tags = {
    Environment = "localstack"
  }
}
