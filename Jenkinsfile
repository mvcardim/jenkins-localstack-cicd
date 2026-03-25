pipeline {
    agent any

    environment {
        LOCALSTACK_ENDPOINT   = "http://127.0.0.1:14566"
        AWS_ACCESS_KEY_ID     = "test"
        AWS_SECRET_ACCESS_KEY = "test"
        AWS_DEFAULT_REGION    = "us-east-1"
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Ação Terraform'
        )
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verificar LocalStack') {
            steps {
                sh 'curl -sf ${LOCALSTACK_ENDPOINT}/_localstack/health && echo "LocalStack OK!"'
            }
        }

        stage('Lint Terraform') {
            steps {
                dir('terraform') {
                    sh '''
                        echo "=== Inicializando tflint ==="
                        tflint --init

                        echo "=== Executando tflint ==="
                        tflint --format=compact
                        echo "✅ Lint OK!"
                    '''
                }
            }
        }

        stage('Segurança - tfsec') {
            steps {
                dir('terraform') {
                    sh '''
                        echo "=== Executando tfsec ==="
                        tfsec . --no-color --soft-fail
                        echo "✅ tfsec OK!"
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform init -input=false -backend=false
                        terraform validate
                        echo "✅ Terraform Validate OK!"
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan -input=false'
                }
            }
        }

        stage('Terraform Apply / Destroy') {
            when { expression { params.ACTION in ['apply', 'destroy'] } }
            steps {
                dir('terraform') {
                    script {
                        if (params.ACTION == 'apply') {
                            sh 'terraform apply -auto-approve tfplan'
                        } else {
                            sh 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
        }

        stage('Verificar Recursos') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh '''
                    echo "=== Buckets S3 ==="
                    aws --endpoint-url=${LOCALSTACK_ENDPOINT} --profile localstack s3 ls

                    echo "=== Filas SQS ==="
                    aws --endpoint-url=${LOCALSTACK_ENDPOINT} --profile localstack sqs list-queues

                    echo "=== Tabelas DynamoDB ==="
                    aws --endpoint-url=${LOCALSTACK_ENDPOINT} --profile localstack dynamodb list-tables

                    echo "=== Instâncias EC2 ==="
                    aws --endpoint-url=${LOCALSTACK_ENDPOINT} --profile localstack ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table
                '''
            }
        }
    }

    post {
        success { echo "✅ Pipeline finalizada com sucesso!" }
        failure { echo "❌ Pipeline falhou!" }
        always  { cleanWs() }
    }
}
