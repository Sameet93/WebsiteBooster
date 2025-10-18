import sgMail from '@sendgrid/mail';

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

  const FROM = process.env.SENDGRID_FROM || 'info@trepidustech.com';

  const msg = {
    to: 'info@trepidustech.com', // company inbox
    from: FROM, // must be a verified sender in SendGrid
    replyTo: data.email,
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
    const res: any = await sgMail.send(msg);
    // @sendgrid/mail may return an array or a single response depending on usage
    const resp = Array.isArray(res) ? res[0] : res;
    const status = resp?.statusCode ?? resp?.status ?? null;
    console.log('SendGrid send response status:', status);
    if (resp?.body) {
      console.log('SendGrid response body:', JSON.stringify(resp.body, null, 2));
    }
    // SendGrid returns 202 on accepted mail
    return status === 202 || status === '202';
  } catch (error: any) {
    console.error('SendGrid error:', error);
    if (error?.response?.body) {
      console.error('SendGrid response body:', JSON.stringify(error.response.body, null, 2));
    }
    return false;
  }
}