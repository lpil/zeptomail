# zeptomail

[![Package Version](https://img.shields.io/hexpm/v/zeptomail)](https://hex.pm/packages/zeptomail)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/zeptomail/)

A wrapper for [ZeptoMail's transactional email API](https://www.zoho.com/zeptomail/).


## Usage

Add this package to your Gleam project:

```sh
gleam add zeptomail
```

And then send some email!

```gleam
import gleam/hackney
import zeptomail.{Addressee}

pub fn main() {
  let key = "your-api-key-here"

  let email = zeptomail.Email(
    from: [Addressee("Mike", "mike@example.com")],
    to: Addressee("Joe", "joe@example.com"),
    reply_to: [],
    cc: [Addressee("Robert", "robert@example.com")],
    bcc: [],
    body: zeptomail.TextBody("Hello, Mike!"),
    subject: "Hello, Joe!",
  )

  // Prepare an API request
  let request = zeptomail.email_request(email, key)

  // Send the API request using `gleam_hackney`
  assert Ok(response) = hackney.send(request)

  // Parse the API response to verify success
  assert Ok(data) = zeptomail.decode_email_response(response)
}
```
