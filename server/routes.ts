import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { z } from "zod";
import { sendContactEmail } from "./services/email";

const contactSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  subject: z.string().optional().default("Website Contact Form"),
  message: z.string().min(10),
});

export async function registerRoutes(app: Express): Promise<Server> {
  // Contact form endpoint
  app.post("/api/contact", async (req, res) => {
    try {
      const validatedData = contactSchema.parse(req.body);
      
      // Send email using SendGrid
      const emailSent = await sendContactEmail(validatedData);
      
      if (emailSent) {
        res.status(200).json({ 
          success: true, 
          message: "Contact form submitted successfully" 
        });
      } else {
        // Email failed to send but data was valid
        res.status(500).json({ 
          success: false, 
          message: "Failed to send email, please try again later" 
        });
      }
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ 
          success: false, 
          message: "Validation failed", 
          errors: error.errors 
        });
      }
      
      res.status(500).json({ 
        success: false, 
        message: "Failed to process contact form" 
      });
    }
  });

  const httpServer = createServer(app);

  return httpServer;
}
