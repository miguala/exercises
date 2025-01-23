package main

import (
	"context"
	"encoding/json"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/google/uuid"
)

type Contact struct {
	ID        string `json:"id"`
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
	Status    string `json:"status"`
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Printf("INICIO CONTACT CREATE LAMBDA 8A") // <--- Log

	sess := session.Must(session.NewSession())
	db := dynamodb.New(sess)

	var contact Contact
	json.Unmarshal([]byte(request.Body), &contact)

	contact.ID = uuid.New().String()
	contact.Status = "CREATED"
	tableName := os.Getenv("TABLE_NAME")

	input := &dynamodb.PutItemInput{
		TableName: aws.String(tableName),
		Item: map[string]*dynamodb.AttributeValue{
			"id":        {S: aws.String(contact.ID)},
			"firstName": {S: aws.String(contact.FirstName)},
			"lastName":  {S: aws.String(contact.LastName)},
			"status":    {S: aws.String(contact.Status)},
		},
	}

	_, err := db.PutItem(input)
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	response, _ := json.Marshal(contact)
	return events.APIGatewayProxyResponse{
		StatusCode: 201,
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       string(response),
	}, nil
}

func main() {
	lambda.Start(handler)
}
