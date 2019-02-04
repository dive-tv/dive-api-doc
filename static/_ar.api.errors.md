<a name="errors"></a>
# Errors

The Dive Ad Resonance API uses the following error codes:

Error Code | Description | Meaning
---------- | ----------- | -------
400 | Bad Request | Client sent a malformed request
401 | Unauthorized | Invalid or missing Authorization token
403 | Forbidden | Provided credentials don't have access to this feature
404 | Not Found | The specified resource could not be found
405 | Method Not Allowed | Client tried to access a resource using an invalid method
406 | Not Acceptable | Client requested a format other than application/json
429 | Too Many Requests | Request rate limit exceeded
500 | Internal Server Error | Internal server error. Try again later.
503 | Service Unavailable | Requested method temporarily failed. Try again later.
