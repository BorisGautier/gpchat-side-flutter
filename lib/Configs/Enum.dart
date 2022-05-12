enum ChatStatus { blocked, waiting, requested, accepted, broadcast }
enum MessageType { text, image, video, doc, location, contact, audio }
enum AuthenticationType { passcode, biometric }
enum Themetype { messenger, whatsapp }
enum LoginStatus {
  sendSMScode,
  sendingSMScode,
  sentSMSCode,
  verifyingSMSCode,
  failure
}
