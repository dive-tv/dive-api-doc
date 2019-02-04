---
title: Dive Legacy Apps API Reference

toc_footers:
  - <a href='http://dive.tv/'>2018 Dive all rights reserved</a>

includes:
  - dive.api.overview
  - dive.api.paths
  - dive.api.definitions
  - dive.api.errors

search: true
---

# Overview

Welcome to the Dive Legacy Apps API documentation.

## Swagger UI

You can see and test this API specs with Swagger UI. You only need to access to this [link](http://petstore.swagger.io) and paste this url (https://cdn.dive.tv/swagger/dive-api.json) inside the top input.

# Authentication

All requests to this API must include an Authorization header with a valid token.
The _/v1/token_ endpoint allows to create and refresh authorization tokens by means of the client API key.

## Obtain new token

In order to obtain a newly issued token, the following request should be made:

### Endpoint

POST [https://api.dive.tv/v1/token?grant_type=password](https://api.dive.tv/v1/token?grant_type=password)

### Form data

  - username: {username}
  - password: {password}
    - MD5 encoded password  

### Headers

  - Content-Type: application/json
  - Authorization: Basic {client\_key}
    - {client\_key} is the client API key

### Response

If client key is correct, the token endpoint will answer with a new token:

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVwJ9.eyJhdWQiOlsiYXBpLXNlcnZlciIsIm9hdXRoLXNlcnZlciJdLCJkZXZpY2VfaWQiOiIxMjM0NTYiLCJncmFudF90eXBlIjoiZGV2aWNlX2NyZWRlbnRpYWxzIiwic2NvcGUiOlsiZGV2aWNlIl0sImV4cCI6MTQ4NzcwNzQxMywiYXV0aG9yaXRpZXMiOlsiUk9MRV9DQsJEX0RFVEFJTCIsIlJPTEVfVFZfR1JJRCIsIlJPTEVfQ0FUQUxPRyIsIlJPTEVfT05FX1NIT1QiXSwiY2xpZW50X2lkIjoicnR2ZV90ZXN0IiwianRpIjoiZTRjMzJlYmItYjI2NC00Yzg0LTk1YjktY2UwNjNiYjI5YTU4In0.uRhnAvVvkVU_qMcjwIFI9Oo3s8kRasGolEn18HSTqHgw",
  "token_type": "bearer",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IfpXVCJ9.eyJhdWQiOlsiYXBpLXNlcnZlciIsIm9hdXRoLXNlcnZlciJdLCJkZXZpY2VfaWQiOiIxMjM0NTYiLCJncmFudF90eXBlIjoiZGV2aWNlX2NyZWRlbnRpYWxzIiwic2NvcGUiOlsiZGV2aWNlIl0sImF0aSI6ImU0YzMyZWJiLWIyNjQtNGM4NC05NWI5LWNlMDYzYmIyOWE1OCIsImV4cCI6MTUwMzdg1MDQxMywiYXV0aG9yaXRpZXMiOlsiUk9MRV9DQVJEX0RFVEFJTCIsIlJPTEVfVFZfR1JJRCIsIlJPTEVfQ0FUQUxPRyIsIlJPTEVfT05FX1NIT1QiXSwiY2xpZW50X2lkIjoicnR2ZV90ZXN0IiwianRpIjoiOGViYzEzZTAtZmVmZS00NjYzLWI0ZDAtMmE2MGZiMmIyNTU1In0.AEaXnE3PRsJEpdLQJ9acivdffJPueqHfv4AsWI-hJCGAss",
  "expires_in": 8999,
  "scope": "user",
  "user_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "jti": "e4c32ebb-b264-4c84-95b9-ce063bb29a58"
}
```

The issued token has a validity of 9000 seconds (value of _expires\_in_ field).
Subsequent requests to any API endpoint must use the issued token as the value of the _Authorization_ header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5dgCI6IkpXVCJ9.eyJhdWQiOlsiYXBpLXNlcnZlciIsIm9hdXRoLXNlcnZlciJdLCJkZXZpY2VfaWQiOiIxMjM0NTYiLCJncmFudF90eXBlIjoiZGV2aWNlX2NyZWRlbnRpYWxzIiwic2NvcGUiOlsiZGV2aWNlIl0sImV4cCI6MTQ4NzcwNzQxMywiYXV0aG9yaXRpZXMiOlsiUk9MRV9DQVJEX0RFVEFJTCIsIlJPTEVfVFZfR1JJRCIsIlJfbvTEVfQ0FUQUxPRyIsIlJPTEVfT05FX1NIT1QiXSwiY2xpZW50X2lkIjoicnR2ZV90ZXN0IiwianRpIfgoiZTRjMzJlYmItYjI2NC00Yzg0LTk1YjktY2UwNjNiYjI5YTU4In0.uRhnAvVvkVU_qMcjwIFI9Oo3J8kRtGofgdEn18HSTqHgw
```

Dive clients should store the refresh token in a persistent location, so it can be used to issue additional tokens without needed to send the password again.
Refresh tokens have a validity of 180 days.

## Refresh existing token

In order to obtain a newly issued token, the following request should be made:

### Endpoint

POST [https://api.dive.tv/v1/token?grant_type=refresh_token](https://api.dive.tv/v1/token?grant_type=refresh_token)

### Form data

  - refresh_token: {refresh\_token}
    - The stored refresh token from a previous call

### Headers

  - Content-Type:application/json
  - Authorization:Basic {client\_key}
    - {client\_key} is the client API key

### Response

Same as a new token request.