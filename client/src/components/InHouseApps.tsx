import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import ScrollAnimation from "./ScrollAnimation";
import { Rocket, Code, Lightbulb, Gauge, Shield, Users } from "lucide-react";

export default function InHouseApps() {
  const capabilities = [
    {
      icon: <Lightbulb className="w-6 h-6" />,
      title: "Innovative Solutions",
      description: "We identify opportunities and build custom apps that solve real business problems"
    },
    {
      icon: <Gauge className="w-6 h-6" />,
      title: "Rapid Development",
      description: "From concept to production in weeks, not months, using modern tech stacks"
    },
    {
      icon: <Shield className="w-6 h-6" />,
      title: "Enterprise-Grade",
      description: "Security-first architecture with scalable infrastructure and best practices"
    },
    {
      icon: <Users className="w-6 h-6" />,
      title: "Customer-Focused",
      description: "Built with your users in mind, delivering exceptional experiences"
    }
  ];

  return (
    <section id="in-house-apps" className="py-20 bg-background">
      <div className="container mx-auto px-4">
        <ScrollAnimation>
          <div className="text-center mb-16">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 mb-6">
              <Rocket className="w-8 h-8 text-primary" />
            </div>
            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              We Build In-House Apps That Scale
            </h2>
            <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
              Beyond consulting, we create powerful custom applications that drive real business value. 
              CloudCostGuardian is just one example of how we turn ideas into production-ready solutions.
            </p>
          </div>
        </ScrollAnimation>

        <ScrollAnimation>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-16">
            {capabilities.map((capability, index) => (
              <Card key={index} className="border-2 hover:border-primary/50 transition-all duration-300" data-testid={`card-capability-${index}`}>
                <CardHeader>
                  <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4 text-primary">
                    {capability.icon}
                  </div>
                  <CardTitle className="text-xl">{capability.title}</CardTitle>
                </CardHeader>
                <CardContent>
                  <CardDescription className="text-base">
                    {capability.description}
                  </CardDescription>
                </CardContent>
              </Card>
            ))}
          </div>
        </ScrollAnimation>

        <ScrollAnimation>
          <Card className="bg-gradient-to-br from-primary/5 to-background border-2 border-primary/20">
            <CardContent className="py-12">
              <div className="flex flex-col md:flex-row items-center gap-8">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-4">
                    <Code className="w-10 h-10 text-primary" />
                    <h3 className="text-2xl font-bold">Full-Stack Expertise</h3>
                  </div>
                  <p className="text-muted-foreground mb-6">
                    Our team specializes in building modern web applications using React, TypeScript, Node.js, 
                    and cloud-native technologies. We handle everything from architecture design to deployment 
                    and ongoing maintenance.
                  </p>
                  <ul className="space-y-2 text-muted-foreground">
                    <li className="flex items-center gap-2">
                      <span className="text-primary">✓</span>
                      <span>AI-powered applications and integrations</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="text-primary">✓</span>
                      <span>Cloud cost optimization tools</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="text-primary">✓</span>
                      <span>Custom dashboards and analytics platforms</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="text-primary">✓</span>
                      <span>API development and microservices</span>
                    </li>
                  </ul>
                </div>
                <div className="flex-shrink-0">
                  <Button size="lg" asChild data-testid="button-discuss-project">
                    <a href="#contact">
                      Discuss Your Project
                    </a>
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </ScrollAnimation>
      </div>
    </section>
  );
}
