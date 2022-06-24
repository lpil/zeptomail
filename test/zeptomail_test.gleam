import gleam/io
import gleam/hackney
import zeptomail

pub fn main() {
  let key = ""
  assert Ok(response) =
    zeptomail.Email(
      from: zeptomail.Addressee("Louis", ""),
      to: [zeptomail.Addressee("Louis", "")],
      reply_to: [],
      cc: [],
      bcc: [],
      body: zeptomail.TextBody("Hello, Mike!"),
      subject: "Hello, Joe!",
    )
    |> zeptomail.email_request(key)
    |> hackney.send
  response
  |> zeptomail.decode_email_response
  |> io.debug
}
