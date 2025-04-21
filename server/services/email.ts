import * as sgMail from '@sendgrid/mail';

// Check if SendGrid API key is available
if (!process.env.SENDGRID_API_KEY) {
  console.warn('SENDGRID_API_KEY not found in environment variables');
}

// Initialize SendGrid with API key if available
if (process.env.SENDGRID_API_KEY) {
  sgMail.setApiKey(process.env.SENDGRID_API_KEY);
}

export interface EmailData {
  name: string;
  email: string;
  subject: string;
  message: string;
}

export async function sendContactEmail(data: EmailData): Promise<boolean> {
  if (!process.env.SENDGRID_API_KEY) {
    console.error('Cannot send email: SENDGRID_API_KEY not set');
    return false;
  }

  const msg = {
    to: 'info@trepidustech.com', // Replace with your company email
    from: 'noreply@trepidustech.com', // Replace with your verified sender
    subject: `Contact Form: ${data.subject}`,
    text: `
Name: ${data.name}
Email: ${data.email}
Subject: ${data.subject}

Message:
${data.message}
    `,
    html: `
<h3>New Contact Form Submission</h3>
<p><strong>Name:</strong> ${data.name}</p>
<p><strong>Email:</strong> ${data.email}</p>
<p><strong>Subject:</strong> ${data.subject}</p>
<p><strong>Message:</strong></p>
<p>${data.message.replace(/\n/g, '<br>')}</p>
    `,
  };

  try {
    await sgMail.send(msg);
    return true;
  } catch (error) {
    console.error('SendGrid error:', error);
    return false;
  }
}