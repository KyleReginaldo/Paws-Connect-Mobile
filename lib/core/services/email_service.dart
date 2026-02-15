import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  static String get emailFrom => dotenv.get('EMAIL_FROM', fallback: '');
  static String get smtpPass => dotenv.get('SMTP_PASS', fallback: '');

  static Future<bool> sendSupportEmail({
    required String userEmail,
    required String userName,
    required String subject,
    required String message,
  }) async {
    try {
      debugPrint('EmailService: Preparing to send email');
      debugPrint('EmailService: From: $emailFrom');
      debugPrint('EmailService: User: $userName ($userEmail)');
      debugPrint('EmailService: Subject: $subject');

      // Configure Gmail SMTP
      final smtpServer = gmail(emailFrom, smtpPass);

      // Create message
      final emailMessage = Message()
        ..from = Address(emailFrom, 'PawsConnect Support')
        ..recipients.add(emailFrom) // Send to support email
        ..subject = 'Support Request: $subject'
        ..html =
            '''
          <h2>Support Request from PawsConnect App</h2>
          <p><strong>From:</strong> $userName</p>
          <p><strong>Email:</strong> $userEmail</p>
          <p><strong>Subject:</strong> $subject</p>
          <hr>
          <h3>Message:</h3>
          <p>${message.replaceAll('\n', '<br>')}</p>
          <hr>
          <p><em>This message was sent from the PawsConnect mobile application.</em></p>
        ''';

      debugPrint('EmailService: Sending email...');

      // Send email
      final sendReport = await send(emailMessage, smtpServer);

      debugPrint(
        'EmailService: Email sent successfully: ${sendReport.toString()}',
      );
      return true;
    } catch (e) {
      debugPrint('EmailService: Error sending email: $e');
      return false;
    }
  }

  static Future<bool> sendConfirmationEmail({
    required String userEmail,
    required String userName,
    required String subject,
  }) async {
    try {
      debugPrint('EmailService: Sending confirmation email to user');

      // Configure Gmail SMTP
      final smtpServer = gmail(emailFrom, smtpPass);

      // Create confirmation message
      final confirmationMessage = Message()
        ..from = Address(emailFrom, 'PawsConnect Support')
        ..recipients.add(userEmail)
        ..subject = 'We received your support request: $subject'
        ..html =
            '''
          <h2>Thank you for contacting PawsConnect Support</h2>
          <p>Dear $userName,</p>
          <p>We have received your support request regarding: <strong>$subject</strong></p>
          <p>Our support team will review your message and get back to you as soon as possible.</p>
          <p>Thank you for using PawsConnect!</p>
          <hr>
          <p><em>Best regards,<br>PawsConnect Support Team</em></p>
        ''';

      // Send confirmation email
      await send(confirmationMessage, smtpServer);

      debugPrint('EmailService: Confirmation email sent successfully');
      return true;
    } catch (e) {
      debugPrint('EmailService: Error sending confirmation email: $e');
      return false;
    }
  }

  static Future<bool> sendOTPEmail({
    required String userEmail,
    required String userName,
    required String otpCode,
    String? subject,
    String? message,
  }) async {
    try {
      debugPrint('EmailService: Sending OTP email to $userEmail');

      // Validate email credentials
      if (emailFrom.isEmpty || smtpPass.isEmpty) {
        debugPrint('❌ EmailService: Email credentials not configured!');
        debugPrint('❌ Please set EMAIL_FROM and SMTP_PASS in your .env file');
        throw Exception(
          'Email credentials not configured. Please check .env file.',
        );
      }

      debugPrint('✅ EmailService: Using email: $emailFrom');

      // Configure Gmail SMTP
      final smtpServer = gmail(emailFrom, smtpPass);

      // Create OTP message
      final otpMessage = Message()
        ..from = Address(emailFrom, 'PawsConnect Security')
        ..recipients.add(userEmail)
        ..subject = subject ?? 'Password Reset - Verification Code'
        ..html =
            message ??
            '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background-color: #FF7A00; padding: 20px; text-align: center;">
              <h1 style="color: white; margin: 0;">🐾 PawsConnect</h1>
            </div>
            
            <div style="padding: 30px; background-color: #f9f9f9;">
              <h2 style="color: #333; margin-bottom: 20px;">Password Reset Request</h2>
              
              <p style="color: #555; font-size: 16px; line-height: 1.5;">
                Hello ${userName.isNotEmpty ? userName : 'User'},
              </p>
              
              <p style="color: #555; font-size: 16px; line-height: 1.5;">
                We received a request to reset your password for your PawsConnect account.
              </p>
              
              <div style="background-color: white; border: 2px solid #FF7A00; border-radius: 10px; padding: 20px; margin: 20px 0; text-align: center;">
                <p style="color: #333; font-size: 14px; margin-bottom: 10px;">Your verification code is:</p>
                <h1 style="color: #FF7A00; font-size: 32px; font-weight: bold; letter-spacing: 3px; margin: 0;">$otpCode</h1>
                <p style="color: #666; font-size: 12px; margin-top: 10px;">This code will expire in 10 minutes</p>
              </div>
              
              <p style="color: #555; font-size: 16px; line-height: 1.5;">
                Enter this code in the PawsConnect app to proceed with resetting your password.
              </p>
              
              <div style="background-color: #fff3e0; border-left: 4px solid #FF7A00; padding: 15px; margin: 20px 0;">
                <p style="color: #e65100; font-size: 14px; margin: 0;">
                  <strong>Security Notice:</strong> If you didn't request this password reset, please ignore this email. Your account remains secure.
                </p>
              </div>
              
              <p style="color: #777; font-size: 14px; line-height: 1.5;">
                Best regards,<br>
                The PawsConnect Team
              </p>
            </div>
            
            <div style="background-color: #333; padding: 15px; text-align: center;">
              <p style="color: #999; font-size: 12px; margin: 0;">
                This is an automated message from PawsConnect. Please do not reply to this email.
              </p>
            </div>
          </div>
        ''';

      debugPrint('EmailService: Sending OTP email...');

      // Send email
      final sendReport = await send(otpMessage, smtpServer);

      debugPrint(
        'EmailService: OTP email sent successfully: ${sendReport.toString()}',
      );
      return true;
    } catch (e) {
      debugPrint('EmailService: Error sending OTP email: $e');
      return false;
    }
  }
}
