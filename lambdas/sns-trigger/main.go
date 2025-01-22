package main

import (
	"context"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
)

func handler(ctx context.Context, e events.SNSEvent) {
	sess := session.Must(session.NewSession())
	db := dynamodb.New(sess)

	for _, record := range e.Records {
		contactID := record.SNS.Message

		input := &dynamodb.UpdateItemInput{
			TableName: aws.String("Contacts8a"),
			Key: map[string]*dynamodb.AttributeValue{
				"id": {S: aws.String(contactID)},
			},
			UpdateExpression:          aws.String("set #status = :s"),
			ExpressionAttributeNames:  map[string]*string{"#status": aws.String("status")},
			ExpressionAttributeValues: map[string]*dynamodb.AttributeValue{":s": {S: aws.String("PROCESSED")}},
		}

		db.UpdateItem(input)
	}
}

func main() {
	lambda.Start(handler)
}
