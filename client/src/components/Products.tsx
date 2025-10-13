import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import ScrollAnimation from "./ScrollAnimation";
import { Shield, Zap, Globe, Bell, BarChart3, Code2, Lock, Cloud, ArrowRight, Sparkles } from "lucide-react";

export default function Products() {
  const features = [
    {
      icon: <Sparkles className="w-6 h-6" />,
      title: "Advanced Detection",
      description: "Sophisticated AI algorithms detect cost anomalies with high precision using statistical techniques."
    },
    {
      icon: <Globe className="w-6 h-6" />,
      title: "Multi-Cloud Support",
      description: "Monitor costs across AWS, GCP, and Azure from a single dashboard with unified alerts."
    },
    {
      icon: <Bell className="w-6 h-6" />,
      title: "Instant Notifications",
      description: "Real-time alerts via Slack or Teams when cost anomalies are detected."
    },
    {
      icon: <Zap className="w-6 h-6" />,
      title: "Actionable Insights",
      description: "Every alert includes detailed analysis and recommended actions to resolve issues."
    },
    {
      icon: <BarChart3 className="w-6 h-6" />,
      title: "Analytics",
      description: "Visualize cost trends and identify optimization opportunities with intuitive dashboards."
    },
    {
      icon: <Code2 className="w-6 h-6" />,
      title: "Enterprise API",
      description: "Automate FinOps workflows with our enterprise API for custom integrations."
    }
  ];

  const integrations = [
    { name: "AWS", category: "Cloud Provider" },
    { name: "Google Cloud", category: "Cloud Provider" },
    { name: "Azure", category: "Cloud Provider" },
    { name: "Slack", category: "Alerts" },
    { name: "Microsoft Teams", category: "Alerts" },
    { name: "Terraform", category: "IaC" }
  ];

  return (
    <section id="products" className="py-20 bg-muted/30">
      <div className="container mx-auto px-4">
        <ScrollAnimation>
          <div className="text-center mb-16">
            <Badge className="mb-4" variant="outline">
              <Sparkles className="w-3 h-3 mr-1" />
              Featured Product
            </Badge>
            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              CloudCostGuardian
            </h2>
            <p className="text-xl text-muted-foreground max-w-3xl mx-auto mb-6">
              Keep Your Cloud Costs Down to Earth: AI-Powered FinOps for Predictable Cloud Spend
            </p>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              Prevent budget surprises. Automate cost optimizations. Built by Trepidus Tech.
            </p>
          </div>
        </ScrollAnimation>

        <ScrollAnimation>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-16">
            {features.map((feature, index) => (
              <Card key={index} className="border-2 hover:border-primary/50 transition-all duration-300" data-testid={`card-feature-${index}`}>
                <CardHeader>
                  <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4 text-primary">
                    {feature.icon}
                  </div>
                  <CardTitle className="text-xl">{feature.title}</CardTitle>
                </CardHeader>
                <CardContent>
                  <CardDescription className="text-base">
                    {feature.description}
                  </CardDescription>
                </CardContent>
              </Card>
            ))}
          </div>
        </ScrollAnimation>

        <ScrollAnimation>
          <Card className="bg-secondary/50 border-2 mb-16">
            <CardHeader className="text-center">
              <div className="flex items-center justify-center gap-2 mb-4">
                <Shield className="w-8 h-8 text-primary" />
                <CardTitle className="text-2xl">Security-First Architecture</CardTitle>
              </div>
              <CardDescription className="text-base">
                Built to keep your cloud and finance data safe
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid md:grid-cols-3 gap-6">
                <div className="text-center">
                  <Lock className="w-8 h-8 mx-auto mb-3 text-primary" />
                  <h4 className="font-semibold mb-2">Encryption Everywhere</h4>
                  <p className="text-sm text-muted-foreground">
                    Data encrypted in transit and at rest using AWS KMS
                  </p>
                </div>
                <div className="text-center">
                  <Shield className="w-8 h-8 mx-auto mb-3 text-primary" />
                  <h4 className="font-semibold mb-2">Least-Privilege Access</h4>
                  <p className="text-sm text-muted-foreground">
                    Fine-grained IAM roles and SSO support
                  </p>
                </div>
                <div className="text-center">
                  <Cloud className="w-8 h-8 mx-auto mb-3 text-primary" />
                  <h4 className="font-semibold mb-2">Hardened Infrastructure</h4>
                  <p className="text-sm text-muted-foreground">
                    Multi-AZ deployments with automated patching
                  </p>
                </div>
              </div>
              <div className="mt-6 pt-6 border-t border-border">
                <div className="flex flex-wrap justify-center gap-4 text-sm text-muted-foreground">
                  <span>✓ SOC 2-aligned controls</span>
                  <span>✓ Continuous backup</span>
                  <span>✓ Customer-managed secrets</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </ScrollAnimation>

        <ScrollAnimation>
          <div className="text-center mb-8">
            <h3 className="text-2xl font-bold mb-4">Seamless Integrations</h3>
            <p className="text-muted-foreground mb-8">
              Connect with the tools your teams already use
            </p>
            <div className="flex flex-wrap justify-center gap-3 mb-12">
              {integrations.map((integration, index) => (
                <Badge key={index} variant="secondary" className="px-4 py-2 text-sm">
                  {integration.name}
                </Badge>
              ))}
            </div>
          </div>
        </ScrollAnimation>

        <ScrollAnimation>
          <Card className="bg-gradient-to-br from-primary/10 via-primary/5 to-background border-2 border-primary/20">
            <CardHeader className="text-center pb-4">
              <CardTitle className="text-2xl md:text-3xl mb-2">
                Ready to Guard Your Cloud Costs?
              </CardTitle>
              <CardDescription className="text-base">
                Get 6 months free, then continue for just $9/month
              </CardDescription>
            </CardHeader>
            <CardContent className="flex flex-col sm:flex-row gap-4 justify-center items-center">
              <Button size="lg" asChild className="w-full sm:w-auto" data-testid="button-claim-free">
                <a href="https://cloudcostguardian.com/register" target="_blank" rel="noopener noreferrer">
                  Claim 6 Months Free
                  <ArrowRight className="ml-2 w-4 h-4" />
                </a>
              </Button>
              <Button size="lg" variant="outline" asChild className="w-full sm:w-auto" data-testid="button-learn-more">
                <a href="https://cloudcostguardian.com/docs" target="_blank" rel="noopener noreferrer">
                  Learn More
                </a>
              </Button>
            </CardContent>
          </Card>
        </ScrollAnimation>
      </div>
    </section>
  );
}
