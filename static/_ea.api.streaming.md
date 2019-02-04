# Dive EA Streaming API


<a name="overview"></a>
## Overview
Dive Experience Amplifier Streaming API provides a set of services which enable a real-time card carousel and contextual information for linear TV and video on demand


### Version information
*Version* : 1.0.0


### URI scheme
*Host* : stream.dive.tv  
*Base Path* : /  
*Socket.io Path* : /v1/stream  
*Schemes* : HTTPS, WSS


<a name="getvodstream"></a>
## Dynamic VOD card stream
`GET /movies`


### Description
Socket.io endpoint for the card stream of the requested VOD contextual information, starting from the indicated timestamp


### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**Accept-Language**  <br>*optional*|Client locale, as language-country|string||
|**Query**|**movie_id**  <br>*required*|Client ID for the requested VOD|string||
|**Query**|**timestamp**  <br>*required*|Current playback timestamp in seconds|number(float)||


### Responses

After a successful connection, the socket will start to receive events with the real-time sequence of contextual information related to the requested VOD, as detailed in [Stream messages](#streammessages)

On any error, an 'error' event will be sent through the socket, followed by a client disconnection.  
The error message format is specified in the [Stream messages](#streammessages) section.


### Produces

* `application/json`


<a name="getchannelstream"></a>
## Dynamic channel card stream
`GET /channels`


### Description
Socket.io endpoint for the card stream of the requested channel contextual information.


### Parameters

|Type|Name|Description|Schema|Default|
|---|---|---|---|---|
|**Header**|**Accept-Language**  <br>*optional*|Client locale, as language-country|string||
|**Query**|**channel_id**  <br>*required*|Client ID for the requested linear TV channel|string||


### Responses

After a successful connection, the socket will start to receive events with the real-time sequence of contextual information related to the requested linear TV channel, as detailed in [Stream messages](#streammessages)

On any error, an 'error' event will be sent through the socket, followed by a client disconnection.  
The error message format is specified in the [Stream messages](#streammessages) section.


### Produces

* `application/json`


<a name="streammessages"></a>
## Stream messages

This section details the server and client messages sent and received through the socket.io connections.  

Server messages:

* authenticated
* unauthorized
* error
* movie_start
* movie_end
* scene_start
* scene_update
* scene_end
* pause_start
* pause_end

Client messages:

* authenticate
* vod_set
* vod_pause
* vod_continue
* vod_end

### Authenticated
Server message, indicates that user has been correctly authenticated after handshake.

####Event type
_authenticated_

####Message body
Empty body

### Unauthorized
Server message, indicates that user couldn't be authenticated during handshake.

####Event type
_unauthorized_

####Message body

|Name|Description|Schema|
|---|---|---|
|**message**  <br>*required*|Error message|string|
|**code**  <br>*required*|Error code|string|
|**type**  <br>*required*|Error type|string|




> unauthorized

``` json
{
    "message": "No Authorization header was found",
    "code": "credentials_required",
    "type": "UnauthorizedError"
}
```

### Error
Server message, indicates a client or server error during stream connection or processing.

####Event type
_error_

####Message body
For error codes and descriptions, see [Errors](#errors)  

|Name|Description|Schema|
|---|---|---|
|**status**  <br>*required*|Error status code|number(int)|
|**description**  <br>*required*|Error description|string|




> error

``` json
{
    "status": 404,
    "description": "Not found"
}
```

### Movie start
Server message, signals the start of a VOD movie or linear TV broadcast. Includes the ID of the related catalog card.

####Event type
_movie\_start_

####Message body

|Name|Description|Schema|
|---|---|---|
|**movie_id**  <br>*required*|Internal catalog card ID|string|





> movie_start

``` json
{
    "movie_id": "39f8b960-2eea-11e6-97ac-0684985cbbe3"
}
```

### Movie end
Server message, signals the end of a VOD movie or linear TV broadcast.

####Event type
_movie\_end_

####Message body
Empty body

### Scene start
Server message, signals the beginning of movie scene. Includes an optional list of context cards present from the beginning of the scene.

####Event type
_scene\_start_

####Message body

|Name|Description|Schema|
|---|---|---|
|**cards**  <br>*optional*|List of cards which appear from the beginning of the scene|< [Card](#card) > array|




> scene_start

``` json
{
    "cards": [
        {
            "card_id": "39f8b960-2eea-11e6-97ac-0684985cbbe3",
            "version": "SRhfxJLqkJx3J0vT9yw1+__MK",
            "type": "character",
            "locale": "en_US",
            "title": "Lucienne's friend #2",
            "subtitle": "Card subtitle",
            "image": 
            {
                "thumb": "https://card.dive.tv/....jpg",
                "full": "https://card.dive.tv/....jpg",
                "anchor_x": 50,
                "anchor_y": 50,
                "source":
                {
                    "name": "TMDB",
                    "url": "https://www.tmdb.com/actor/245354534",
                    "disclaimer": "TMDB All rights reserved",
                    "image": "https://cdn.dive.tv/....png"
                }
            },
            "has_content": true,
            "relations": [
            {
                "type": "single",
                "content_type": "home_deco",
                "data": [
                {
                    "card_id": "ecca8672-1e76-11e6-....",
                    "version": "0jOeUIeLCaOcSI4FSebNj4+ERkk",
                    "locale": "es_ES",
                    "title": "Antonio Gaudí Complete Works (2009)",
                    "subtitle": "Aurora Cuito, Cristina Montes",
                    "type": "leisure_sport",
                    "has_content": true
                }]
            }]
        }
    ]
}
```

### Scene update
Server message, indicates an update on current scene. Includes the list of new context cards which appear in the scene.

####Event type
_scene\_update_

####Message body

|Name|Description|Schema|
|---|---|---|
|**cards**  <br>*optional*|List of cards which appear at this point of the scene|< [Card](#card) > array|




> scene_update

``` json
{
    "cards": [
        {
            "card_id": "39f8b960-2eea-11e6-97ac-0684985cbbe3",
            "version": "SRhfxJLqkJx3J0vT9yw1+__MK",
            "type": "character",
            "locale": "en_US",
            "title": "Lucienne's friend #2",
            "subtitle": "Card subtitle",
            "image": 
            {
                "thumb": "https://card.dive.tv/....jpg",
                "full": "https://card.dive.tv/....jpg",
                "anchor_x": 50,
                "anchor_y": 50,
                "source":
                {
                    "name": "TMDB",
                    "url": "https://www.tmdb.com/actor/245354534",
                    "disclaimer": "TMDB All rights reserved",
                    "image": "https://cdn.dive.tv/....png"
                }
            },
            "has_content": true,
            "relations": [
            {
                "type": "single",
                "content_type": "home_deco",
                "data": [
                {
                    "card_id": "ecca8672-1e76-11e6-....",
                    "version": "0jOeUIeLCaOcSI4FSebNj4+ERkk",
                    "locale": "es_ES",
                    "title": "Antonio Gaudí Complete Works (2009)",
                    "subtitle": "Aurora Cuito, Cristina Montes",
                    "type": "leisure_sport",
                    "has_content": true
                }]
            }]
        }
    ]
}
```

### Scene end
Server message, signals the end of the current movie scene and marks every card of this scene as out of context.

####Event type
_scene\_end_

####Message body
Empty body

### Pause start
Server message, signals a pause in the contextual streaming. This pause can be a generated by the user during VOD playback or a commercial block in a linear TV broadcast.

####Event type
_pause\_start_

####Message body
Empty body

### Pause end
Server message, signals the end of current pause state.

####Event type
_pause\_end_

####Message body
Empty body

### Authenticate
Client message, sends authentication token during connection handshake.

####Event type
_authenticate_

####Message body

|Name|Description|Schema|
|---|---|---|
|**token**  <br>*required*|JWT token value|string|




> authenticate

``` json
{
    "token": "eyJhbGciOiJIUzI1NiIsInR5dgCI6IkpXVCJ9.eyJhdWQiOlsiYXBpLXNlcnZlciIsIm9hdXRoLXNlcnZlciJdLCJkZXZpY2VfaWQiOiIxMjM0NTYiLCJncmFudF90eXBlIjoiZGV2aWNlX2NyZWRlbnRpYWxzIiwic2NvcGUiOlsiZGV2aWNlIl0sImV4cCI6MTQ4NzcwNzQxMywiYXV0aG9yaXRpZXMiOlsiUk9MRV9DQVJEX0RFVEFJTCIsIlJPTEVfVFZfR1JJRCIsIlJfbvTEVfQ0FUQUxPRyIsIlJPTEVfT05FX1NIT1QiXSwiY2xpZW50X2lkIjoicnR2ZV90ZXN0IiwianRpIfgoiZTRjMzJlYmItYjI2NC00Yzg0LTk1YjktY2UwNjNiYjI5YTU4In0.uRhnAvVvkVU_qMcjwIFI9Oo3J8kRtGofgdEn18HSTqHgw"
}
```

### VOD set
Client message, sets a new playback timestamp for the current VOD contextual stream.

####Event type
_vod\_set_

####Message body

|Name|Description|Schema|
|---|---|---|
|**timestamp**  <br>*required*|New playback timestamp, in seconds|number(float)|




> vod_set

``` json
{
    "timestamp": 1240.35
}
```

### VOD pause
Client message, signals a pause in current VOD playback.

####Event type
_vod\_pause_

####Message body
Empty body

### VOD continue
Client message, signals a VOD playback resume after a pause.

####Event type
_vod\_continue_

####Message body
Empty body

### VOD end
Client message, indicates the end of current VOD playback and closes the contextual stream.

####Event type
_vod\_end_

####Message body
Empty body
