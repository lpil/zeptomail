// https://www.zoho.com/zeptomail/help/api/email-sending.html

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
  Addressee(address: String, name: String)
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
    data: List(Detail),
  )
}

/// An error returned by the ZeptoMail API.
/// The possible error codes are documented here:
/// <https://www.zoho.com/zeptomail/help/api/error-codes.html>
///
pub type ApiError {
  ApiError(code: String, request_id: String, message: String, error: Detail)
}

pub type Detail {
  Detail(code: String, message: String, target: String)
}
