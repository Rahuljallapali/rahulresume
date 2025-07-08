import 'package:emailjs/emailjs.dart' as emailjs;

class EmailService {
  // EmailJS configuration
  static const String _serviceId = 'service_3wkd7gm';
  static const String _templateId = 'template_4dlrq2o'; // Replace with your EmailJS template ID
  static const String publicKey = 'rDUz8SsNXHGEp1MtU';
  static const String privateKey = 'U1mV9w32zMGtCw8CQTJJ4'; // Replace with your EmailJS public key

  static Future<bool> sendEmail({
    required String name,
    required String email,
    required String message,
  }) async {
    try {

      emailjs.init(const emailjs.Options(
        publicKey: publicKey,
        privateKey: privateKey,
        limitRate: emailjs.LimitRate(
          id: 'app',
          throttle: 10000,
        ),
      ));

      await emailjs.send(
        _serviceId,
        _templateId,
        {
          'from_name': name,
          'from_email': email,
          'message': message,
          'to_email': 'rahuljallapalli57@gmail.com',
          'to_name': 'Rahul Jallapalli',
        },
      );
      
      print('Email sent successfully!');
      return true;
    } catch (error) {
      print('Error sending email: $error');
      return false;
    }
  }
} 