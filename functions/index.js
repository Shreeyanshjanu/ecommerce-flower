const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

console.log("🔧 Initializing email transporter...");

const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 465,
  secure: true,
  auth: {
    user: "burntheflowersunflower@gmail.com",
    pass: "fyjmmlxnrartwikg", // Remove spaces from App Password
  },
  tls: {
    rejectUnauthorized: true,
  },
});

// Verify SMTP connection
transporter.verify(function (error, success) {
  if (error) {
    console.error("❌ SMTP Connection Error:", error);
  } else {
    console.log("✅ SMTP Server ready to send emails");
  }
});

exports.sendOtpEmail = functions.https.onCall(async (data, context) => {
  console.log("===== FUNCTION CALLED =====");
  
  // DON'T use JSON.stringify on data - it has circular refs
  console.log("Email:", data.email);
  console.log("OTP:", data.otp);
  console.log("Purpose:", data.purpose);

  // Extract values
  const email = data.email;
  const otp = data.otp;
  const purpose = data.purpose || 'verification';

  // Validate
  if (!email || !otp) {
    console.error("❌ Missing required fields!");
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Email and OTP are required",
    );
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    console.error("❌ Invalid email format");
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid email format",
    );
  }

  let subject;
  let htmlContent;

  if (purpose === "password-change") {
    subject = "🔒 Change Password OTP - Bloom Boom";
    htmlContent = `
      <!DOCTYPE html>
      <html>
      <head><meta charset="UTF-8"></head>
      <body style="font-family: Arial; padding: 20px; background: #f5f5f5;">
        <div style="max-width: 600px; margin: 0 auto; background: #fff; 
                    padding: 40px; border-radius: 10px;">
          <h1 style="color: #079A3D; text-align: center;">
            🌸 Bloom Boom
          </h1>
          <h2 style="color: #333;">Change Password Verification</h2>
          <p>Hello,</p>
          <p>You requested to change your password. 
             Use the OTP below to verify:</p>
          <div style="background: #079A3D; color: white; font-size: 36px; 
                      padding: 20px; text-align: center; border-radius: 8px; 
                      letter-spacing: 8px; margin: 30px 0; font-weight: bold;">
            ${otp}
          </div>
          <p><strong>This OTP is valid for 10 minutes.</strong></p>
          <p style="color: #666; font-size: 14px;">
            If you didn't request this, please ignore this email.
          </p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
          <p style="color: #999; font-size: 12px; text-align: center;">
            © 2025 Bloom Boom. All rights reserved.<br>
            This is an automated email. Please do not reply.
          </p>
        </div>
      </body>
      </html>
    `;
  } else if (purpose === "password-reset") {
    subject = "🔐 Password Reset OTP - Bloom Boom";
    htmlContent = `
      <!DOCTYPE html>
      <html>
      <head><meta charset="UTF-8"></head>
      <body style="font-family: Arial; padding: 20px; background: #f5f5f5;">
        <div style="max-width: 600px; margin: 0 auto; background: #fff; 
                    padding: 40px; border-radius: 10px;">
          <h1 style="color: #079A3D; text-align: center;">
            🌸 Bloom Boom
          </h1>
          <h2 style="color: #333;">Password Reset Request</h2>
          <p>Hello,</p>
          <p>You requested to reset your password. 
             Use the OTP below to proceed:</p>
          <div style="background: #079A3D; color: white; font-size: 36px; 
                      padding: 20px; text-align: center; border-radius: 8px; 
                      letter-spacing: 8px; margin: 30px 0; font-weight: bold;">
            ${otp}
          </div>
          <p><strong>This OTP is valid for 10 minutes.</strong></p>
          <div style="background: #fff3cd; padding: 15px; 
                      border-left: 4px solid #ffc107; margin: 20px 0;">
            <strong>⚠️ Security Alert:</strong>
            If you didn't request this password reset, 
            please ignore this email and secure your account.
          </div>
          <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
          <p style="color: #999; font-size: 12px; text-align: center;">
            © 2025 Bloom Boom. All rights reserved.<br>
            This is an automated email. Please do not reply.
          </p>
        </div>
      </body>
      </html>
    `;
  } else {
    subject = "✉️ Verification OTP - Bloom Boom";
    htmlContent = `
      <!DOCTYPE html>
      <html>
      <head><meta charset="UTF-8"></head>
      <body style="font-family: Arial; padding: 20px; background: #f5f5f5;">
        <div style="max-width: 600px; margin: 0 auto; background: #fff; 
                    padding: 40px; border-radius: 10px;">
          <h1 style="color: #079A3D; text-align: center;">
            🌸 Bloom Boom
          </h1>
          <h2 style="color: #333;">Verification Code</h2>
          <p>Hello,</p>
          <p>Your verification code is:</p>
          <div style="background: #079A3D; color: white; font-size: 36px; 
                      padding: 20px; text-align: center; border-radius: 8px; 
                      letter-spacing: 8px; margin: 30px 0; font-weight: bold;">
            ${otp}
          </div>
          <p><strong>This OTP is valid for 10 minutes.</strong></p>
          <p style="color: #666; font-size: 14px;">
            Please enter this code in the app to complete your verification.
          </p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
          <p style="color: #999; font-size: 12px; text-align: center;">
            © 2025 Bloom Boom. All rights reserved.<br>
            This is an automated email. Please do not reply.
          </p>
        </div>
      </body>
      </html>
    `;
  }

  const mailOptions = {
    from: "\"Bloom Boom 🌸\" <burntheflowersunflower@gmail.com>",
    to: email,
    subject: subject,
    html: htmlContent,
  };

  try {
    console.log("📤 Sending email to:", email);
    
    const info = await transporter.sendMail(mailOptions);
    
    console.log("✅ EMAIL SENT SUCCESSFULLY!");
    console.log("MessageId:", info.messageId);

    return {
      success: true,
      message: "OTP sent successfully",
      messageId: info.messageId,
    };
  } catch (error) {
    console.error("❌ EMAIL SEND ERROR:");
    console.error("Name:", error.name);
    console.error("Message:", error.message);
    console.error("Code:", error.code);
    
    throw new functions.https.HttpsError(
        "internal",
        `Email send failed: ${error.message}`,
    );
  }
});

exports.testEmail = functions.https.onCall(async (data, context) => {
  console.log("✅ Test function called successfully");
  return {success: true, message: "Function is working!"};
});
