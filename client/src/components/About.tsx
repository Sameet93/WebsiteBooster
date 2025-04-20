import { Card, CardContent } from "@/components/ui/card";
import ScrollAnimation from "./ScrollAnimation";

export default function About() {
  const features = [
    {
      title: "Communication",
      description:
        "We strive to keep our clients well informed at all times, we own our work and judge our success by yours.",
    },
    {
      title: "Quality",
      description:
        "We ensure to only build the best, our team personifies professionalism while ensuring the best time frames are upheld.",
    },
    {
      title: "Support",
      description:
        "We provide support at all times, with us you are always a priority. Issues are resolved as soon as possible ensuring your satisfaction.",
    },
  ];

  return (
    <section id="about" className="py-20 bg-background">
      <ScrollAnimation>
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl md:text-4xl font-bold mb-12 text-center">
              What makes us stand out?
            </h2>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {features.map((feature, index) => (
                <Card key={index} className="bg-secondary border-border hover:border-primary transition-colors duration-300">
                  <CardContent className="pt-6">
                    <h3 className="text-xl font-semibold mb-3 text-primary">{feature.title}</h3>
                    <p className="text-muted-foreground">{feature.description}</p>
                  </CardContent>
                </Card>
              ))}
            </div>

            <div className="mt-16 text-muted-foreground space-y-4">
              <p>
                At Trepidus Tech, we specialize in delivering top-tier consulting services that drive your business forward. Our team combines unparalleled expertise with innovative solutions to help your company reach its full potential. By choosing Trepidus Tech, you gain access to strategic insights, exceptional service, and a steadfast commitment to your success.
              </p>

              <p>
                Our tailored services support your growth and provide a framework for fostering a culture of collaboration, innovation, and continuous improvement. Our deep expertise in tech consulting—including cloud migration, AI integration, and infrastructure architecture—ensures that your business not only adapts to but excels in today's rapidly evolving digital landscape.
              </p>

              <p>
                Let us equip your team with strategic insights and customized solutions that pave the way for sustainable growth and success. Together, we can turn challenges into opportunities and aspirations into achievements.
              </p>
            </div>
          </div>
        </div>
      </ScrollAnimation>
    </section>
  );
}
