import { Card, CardContent } from "@/components/ui/card";
import ScrollAnimation from "./ScrollAnimation";

export default function Services() {
  const services = [
    {
      title: "Cloud Migration",
      description:
        "Seamless transition to cloud infrastructure with minimal disruption to your operations.",
    },
    {
      title: "AI Integration",
      description:
        "Implement AI solutions that provide real business value and competitive advantage.",
    },
    {
      title: "Infrastructure Architecture",
      description:
        "Design scalable, secure, and efficient IT infrastructure tailored to your needs.",
    },
    {
      title: "Custom Software Development",
      description:
        "Bespoke software solutions that address your unique business challenges.",
    },
  ];

  return (
    <section id="services" className="py-20 bg-secondary">
      <ScrollAnimation>
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl md:text-4xl font-bold mb-12 text-center">
              Our Services
            </h2>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              {services.map((service, index) => (
                <Card key={index} className="bg-background border-border hover:shadow-lg transition-all duration-300">
                  <CardContent className="pt-6">
                    <h3 className="text-xl font-semibold mb-3">{service.title}</h3>
                    <p className="text-muted-foreground">{service.description}</p>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        </div>
      </ScrollAnimation>
    </section>
  );
}
