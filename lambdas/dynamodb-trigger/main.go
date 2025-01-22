package main

import (
	"context"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sns"
)

func handler(ctx context.Context, e events.DynamoDBEvent) {
	sess := session.Must(session.NewSession())
	svc := sns.New(sess)

	for _, record := range e.Records {
		if record.EventName == "INSERT" {
			id := record.Change.NewImage["id"].String()

			svc.Publish(&sns.PublishInput{
				Message:  aws.String(id),
				TopicArn: aws.String("arn:aws:sns:us-east-1:ACCOUNT_ID:ContactsTopic"),
			})
		}
	}
}

func main() {
	lambda.Start(handler)
}
