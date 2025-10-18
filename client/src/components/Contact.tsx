import { Phone } from "lucide-react";
import ContactForm from "./ContactForm";
import ScrollAnimation from "./ScrollAnimation";

export default function Contact() {
  return (
    <section id="contact" className="py-20 bg-background">
      <ScrollAnimation>
        <div className="container mx-auto px-4">
          <h2 className="text-3xl md:text-4xl font-bold mb-12 text-center">
            Get in Touch
          </h2>

          <div className="max-w-5xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-12">
            <div>
              <h3 className="text-2xl font-semibold mb-6">Contact Information</h3>

              <p className="mb-8 text-muted-foreground">
                Feel free to email us directly at{" "}
                <a href="mailto:info@trepidustech.com" className="text-primary hover:underline">
                  info@trepidustech.com
                </a>
              </p>

              {/* Phone contact removed until set up */}

              <div className="mt-12">
                <h4 className="text-xl font-medium mb-4">Follow Us</h4>
                <div className="flex space-x-4">
                  <a
                    href="https://www.linkedin.com/company/trepidus-information-technologies/"
                    className="text-muted-foreground hover:text-primary transition-colors"
                    aria-label={`Follow us on linkedin`}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                      <path
                        fillRule="evenodd"
                        d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"
                        clipRule="evenodd"
                      ></path>
                    </svg>
                  </a>
                </div>
              </div>
            </div>

            <div>
              <ContactForm />
            </div>
          </div>
        </div>
      </ScrollAnimation>
    </section>
  );
}
