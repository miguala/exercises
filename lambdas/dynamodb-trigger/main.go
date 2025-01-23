package main

import (
	"context"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sns"
)

func handler(ctx context.Context, e events.DynamoDBEvent) {
	log.Printf("INICIO CONTACT DYNAMODB TRIGGER LAMBDA 8A") // <--- Log

	sess := session.Must(session.NewSession())
	svc := sns.New(sess)
	topicArn := os.Getenv("SNS_TOPIC_ARN")

	for _, record := range e.Records {
		log.Printf("Evento recibido: %s", record.EventName) // <--- Log
		if record.EventName == "INSERT" {
			id := record.Change.NewImage["id"].String()
			log.Printf("ID a publicar en SNS: %s", id) // <--- Log

			_, err := svc.Publish(&sns.PublishInput{
				Message:  aws.String(id),
				TopicArn: aws.String(topicArn),
			})
			if err != nil {
				log.Printf("Error publicando en SNS: %v", err) // <--- Log error
			}
		}
	}
}

func main() {
	lambda.Start(handler)
}
