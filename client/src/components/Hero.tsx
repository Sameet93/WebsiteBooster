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
    <section id="hero" className="relative py-20 md:py-32">
      {/* Background Image with Overlay */}
      <div 
        className="absolute inset-0 bg-cover bg-center z-0" 
        style={{ 
          backgroundImage: "url('https://images.unsplash.com/photo-1504384308090-c894fdcc538d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80')",
          backgroundPosition: "center"
        }}
      >
        <div className="absolute inset-0 bg-black opacity-70"></div>
      </div>
      
      {/* Content */}
      <div className="container mx-auto px-4 relative z-10">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold mb-6 leading-tight text-white">
            Welcome to <span className="text-primary">Trepidus</span>
          </h1>
          <p className="text-xl md:text-2xl text-gray-300 mb-8">IT Consulting Made Simple</p>
          <Button size="lg" onClick={scrollToContact} className="font-medium">
            Get Started
          </Button>
        </div>
      </div>
    </section>
  );
}
