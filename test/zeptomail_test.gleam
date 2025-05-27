import gleam/hackney
import gleam/io
import gleam/string
import zeptomail

pub fn main() {
  let key = ""
  let assert Ok(response) =
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
  |> string.inspect
  |> io.println
}
