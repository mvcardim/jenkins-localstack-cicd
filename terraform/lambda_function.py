def lambda_handler(event, context):
    print("Executando Lambda no LocalStack!")
    return {
        'statusCode': 200,
        'body': 'Olá do LocalStack Lambda!'
    }
