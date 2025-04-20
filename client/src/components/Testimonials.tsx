import { Card, CardContent } from "@/components/ui/card";
import { Star } from "lucide-react";
import ScrollAnimation from "./ScrollAnimation";

export default function Testimonials() {
  const testimonials = [
    {
      content:
        "We have worked with Sameet for a few years, and have been extremely impressed with his professionalism and willingness to go the extra mile. He has ensured that we are set up for success as an e-commerce platform.",
      company: "Motopay",
      location: "Nigeria",
    },
    {
      content:
        "We started using Trepidus after struggling to find a company who could meet our needs. With Trepidus, we have found a seamless solution to our platform needs, ensuring everything runs efficiently and help is only a click away. - Mohamed Shaheer",
      company: "Amal Ecommerce",
      location: "Dubai",
    },
    {
      content:
        "Trepidus was instrumental in our timely launch and scale up of operations at Aney in KSA. We had launched with a limited in a challenging environment which required a lot of planning to get the architecture of our technology correct.",
      company: "Aney",
      location: "KSA",
    },
  ];

  return (
    <section id="testimonials" className="py-20 bg-secondary">
      <ScrollAnimation>
        <div className="container mx-auto px-4">
          <h2 className="text-3xl md:text-4xl font-bold mb-12 text-center">
            A word from our clients
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-5xl mx-auto">
            {testimonials.map((testimonial, index) => (
              <Card key={index} className="bg-background border-border h-full">
                <CardContent className="pt-6 flex flex-col h-full">
                  <div className="mb-4 text-primary">
                    <div className="flex">
                      {[...Array(5)].map((_, i) => (
                        <Star key={i} className="h-5 w-5 fill-current" />
                      ))}
                    </div>
                  </div>

                  <p className="text-muted-foreground flex-grow italic">
                    {testimonial.content}
                  </p>

                  <div className="mt-4 pt-4 border-t border-border">
                    <h4 className="font-semibold">{testimonial.company}</h4>
                    <p className="text-sm text-muted-foreground">
                      {testimonial.location}
                    </p>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </ScrollAnimation>
    </section>
  );
}
