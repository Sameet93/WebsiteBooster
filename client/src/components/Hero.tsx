import { Button } from "@/components/ui/button";

export default function Hero() {
  const scrollToContact = () => {
    const contact = document.getElementById("contact");
    if (contact) {
      window.scrollTo({
        top: contact.offsetTop - 80,
        behavior: "smooth",
      });
    }
  };

  return (
    <section id="hero" className="relative bg-secondary py-20 md:py-32">
      <div className="container mx-auto px-4">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold mb-6 leading-tight">
            Welcome to <span className="text-primary">Trepidus</span>
          </h1>
          <p className="text-xl md:text-2xl text-muted-foreground mb-8">IT Consulting Made Simple</p>
          <Button size="lg" onClick={scrollToContact}>
            Get Started
          </Button>
        </div>
      </div>
    </section>
  );
}
