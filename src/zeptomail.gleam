// https://www.zoho.com/zeptomail/help/api/email-sending.html
import gleam/dynamic/decode
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json.{type Json}
import gleam/option.{type Option, None}
import gleam/result

/// Create a HTTP request to send an email via the ZeptoMail API
pub fn email_request(email: Email, api_token: String) -> Request(String) {
  let body =
    email
    |> encode_email
    |> json.to_string

  request.new()
  |> request.set_method(http.Post)
  |> request.set_host("api.zeptomail.com")
  |> request.set_path("/v1.1/email")
  |> request.set_body(body)
  |> request.prepend_header("authorization", api_token)
}

/// Create a HTTP request to send an email via the ZeptoMail API
pub fn decode_email_response(
  response: Response(String),
) -> Result(ApiData, ApiError) {
  case response.status >= 200 && response.status < 300 {
    True ->
      response.body
      |> json.parse(api_data_decoder())
      |> result.map_error(UnexpectedResponse)
    False ->
      response.body
      |> json.parse(api_error_decoder())
      |> result.map_error(UnexpectedResponse)
      |> result.then(Error)
  }
}

pub type Email {
  Email(
    from: Addressee,
    to: List(Addressee),
    cc: List(Addressee),
    bcc: List(Addressee),
    reply_to: List(Addressee),
    body: Body,
    subject: String,
  )
}

pub type Addressee {
  Addressee(name: String, address: String)
}

fn encode_email(email: Email) -> Json {
  let bodykind = case email.body {
    TextBody(_) -> "textbody"
    HtmlBody(_) -> "htmlbody"
  }
  let addressee_array = fn(addressees) {
    json.array(addressees, fn(a) {
      json.object([#("email_address", encode_addressee(a))])
    })
  }

  json.object([
    #("from", encode_addressee(email.from)),
    #("to", addressee_array(email.to)),
    #("cc", addressee_array(email.cc)),
    #("bcc", addressee_array(email.bcc)),
    #("reply_to", json.array(email.reply_to, encode_addressee)),
    #("subject", json.string(email.subject)),
    #(bodykind, json.string(email.body.content)),
  ])
}

fn encode_addressee(addressee: Addressee) -> Json {
  json.object([
    #("name", json.string(addressee.name)),
    #("address", json.string(addressee.address)),
  ])
}

pub type Body {
  TextBody(content: String)
  HtmlBody(content: String)
}

pub type ApiData {
  ApiData(
    object: String,
    request_id: String,
    message: String,
    data: List(ApiDatum),
  )
}

fn api_data_decoder() -> decode.Decoder(ApiData) {
  use object <- decode.field("object", decode.string)
  use request_id <- decode.field("request_id", decode.string)
  use message <- decode.field("message", decode.string)
  use data <- decode.field("data", decode.list(api_datum_decoder()))
  decode.success(ApiData(object, request_id, message, data))
}

pub type ApiDatum {
  ApiDatum(code: String, message: String)
}

fn api_datum_decoder() -> decode.Decoder(ApiDatum) {
  use code <- decode.field("code", decode.string)
  use message <- decode.field("message", decode.string)

  decode.success(ApiDatum(code, message))
}

/// An error returned by the ZeptoMail API.
/// The possible error codes are documented here:
/// <https://www.zoho.com/zeptomail/help/api/error-codes.html>
///
pub type ApiError {
  ApiError(code: String, message: String, details: List(ApiErrorDetail))
  UnexpectedResponse(json.DecodeError)
}

fn api_error_decoder() -> decode.Decoder(ApiError) {
  use code <- decode.subfield(["error", "code"], decode.string)
  use message <- decode.subfield(["error", "message"], decode.string)
  use details <- decode.subfield(
    ["error", "details"],
    decode.list(api_error_detail_decoder()),
  )

  decode.success(ApiError(code, message, details))
}

pub type ApiErrorDetail {
  ApiErrorDetail(
    code: String,
    message: String,
    target: Option(String),
    target_value: Option(String),
  )
}

fn api_error_detail_decoder() -> decode.Decoder(ApiErrorDetail) {
  use code <- decode.field("code", decode.string)
  use message <- decode.field("message", decode.string)
  use target <- decode.optional_field(
    "target",
    None,
    decode.optional(decode.string),
  )
  use target_value <- decode.optional_field(
    "target_value",
    None,
    decode.optional(decode.string),
  )
  decode.success(ApiErrorDetail(code, message, target, target_value))
}
