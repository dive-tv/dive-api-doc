# Authentication

All requests to this API must include a valid token in order to be processed.  
The _/v1/token_ endpoint allows to create and refresh authorization tokens by means of the client API key.

## Obtain a new token

In order to obtain a newly issued token, the following request should be made:

### Endpoint

POST [https://rest.dive.tv/v1/token?grant_type=device_credentials](https://rest.dive.tv/v1/token?grant_type=device_credentials)

### Form data

  - device_id: {device\_id}
    - Unique identifier for the device making the request

### Headers

  - Content-Type: application/json
  - Authorization: Basic {client\_key}
    - {client\_key} is the client API k1ey

### Response

If client key is correct, the token endpoint will answer with a new token:

``` json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVwJ9.eyJhdWQiOlsiYXBpLXNlcnZlciIsIm9hdXRoLXNlcnZlciJdLCJkZXZpY2VfaWQiOiIxMjM0NTYiLCJncmFudF90eXBlIjoiZGV2aWNlX2NyZWRlbnRpYWxzIiwic2NvcGUiOlsiZGV2aWNlIl0sImV4cCI6MTQ4NzcwNzQxMywiYXV0aG9yaXRpZXMiOlsiUk9MRV9DQsJEX0RFVEFJTCIsIlJPTEVfVFZfR1JJRCIsIlJPTEVfQ0FUQUxPRyIsIlJPTEVfT05FX1NIT1QiXSwiY2xpZW50X2lkIjoicnR2ZV90ZXN0IiwianRpIjoiZTRjMzJlYmItYjI2NC00Yzg0LTk1YjktY2UwNjNiYjI5YTU4In0.uRhnAvVvkVU_qMcjwIFI9Oo3s8kRasGolEn18HSTqHgw",
  "token_type": "bearer",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IfpXVCJ9.eyJhdWQiOlsiYXBpLXNlcnZlciIsIm9hdXRoLXNlcnZlciJdLCJkZXZpY2VfaWQiOiIxMjM0NTYiLCJncmFudF90eXBlIjoiZGV2aWNlX2NyZWRlbnRpYWxzIiwic2NvcGUiOlsiZGV2aWNlIl0sImF0aSI6ImU0YzMyZWJiLWIyNjQtNGM4NC05NWI5LWNlMDYzYmIyOWE1OCIsImV4cCI6MTUwMzdg1MDQxMywiYXV0aG9yaXRpZXMiOlsiUk9MRV9DQVJEX0RFVEFJTCIsIlJPTEVfVFZfR1JJRCIsIlJPTEVfQ0FUQUxPRyIsIlJPTEVfT05FX1NIT1QiXSwiY2xpZW50X2lkIjoicnR2ZV90ZXN0IiwianRpIjoiOGViYzEzZTAtZmVmZS00NjYzLWI0ZDAtMmE2MGZiMmIyNTU1In0.AEaXnE3PRsJEpdLQJ9acivdffJPueqHfv4AsWI-hJCGAss",
  "expires_in": 8999,
  "scope": "device",
  "device_id": "123456",
  "client_id": "test",
  "jti": "e4c32ebb-b264-4c84-95b9-ce063bb29a58"
}
```

  
Issued tokens have a validity of 9000 seconds (value of _expires\_in_ field), and refresh tokens have a validity of 180 days.
  
API clients should store the refresh token in a persistent location, so it can be used to issue additional tokens without needed to send the device ID again.

## Refresh a existing token

In order to obtain a newly issued token, the following request should be made:

### Endpoint

POST [https://rest.dive.tv/v1/token?grant_type=refresh_token](https://rest.dive.tv/v1/token?grant_type=refresh_token)

### Form data

  - refresh_token: {refresh\_token}
    - The stored refresh token from a previous call

### Headers

  - Content-Type:application/json
  - Authorization:Basic {client\_key}
    - {client\_key} is the client API key

### Response

Same as a new token request.

## Authenticate a request

Every request to the REST and Streaming APIs must be authenticated with a valid token.

### REST API

The _Authorization_ header must be present on every request to the REST API services.  
The value of this header should be formed by the word _Bearer_ and the value of the obtained token:

``` javascript
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5dgCI6IkpXVCJ9.eyJhdWQiOlsiYXBpLXNlcnZlciIsIm9hdXRoLXNlcnZlciJdLCJkZXZpY2VfaWQiOiIxMjM0NTYiLCJncmFudF90eXBlIjoiZGV2aWNlX2NyZWRlbnRpYWxzIiwic2NvcGUiOlsiZGV2aWNlIl0sImV4cCI6MTQ4NzcwNzQxMywiYXV0aG9yaXRpZXMiOlsiUk9MRV9DQVJEX0RFVEFJTCIsIlJPTEVfVFZfR1JJRCIsIlJfbvTEVfQ0FUQUxPRyIsIlJPTEVfT05FX1NIT1QiXSwiY2xpZW50X2lkIjoicnR2ZV90ZXN0IiwianRpIfgoiZTRjMzJlYmItYjI2NC00Yzg0LTk1YjktY2UwNjNiYjI5YTU4In0.uRhnAvVvkVU_qMcjwIFI9Oo3J8kRtGofgdEn18HSTqHgw
```

### Streaming API

In order to connect to the secure socket.io stream, a handshake process must be performed:

1. Connect to the socket
2. On connect: send 'authenticate' message with the token value
3. On 'authenticated': ready to receive data
4. On 'unauthorized': authentication failure (token expired or invalid)

Sample client code:

``` javascript
let socket = io.connect('https://stream.dive.tv/movies');
socket.on('connect', () => {
  socket
    .emit('authenticate', {token: jwt}) //send the jwt
    .on('authenticated', () => {
      // configure message listeners
    })
    .on('unauthorized', (msg) => {
      console.log("unauthorized: " + JSON.stringify(msg.data))
      throw new Error(msg.data.type)
    })
})
```
