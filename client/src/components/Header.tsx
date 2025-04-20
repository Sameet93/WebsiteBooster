import { useState, useEffect } from "react";
import { Menu, X } from "lucide-react";

export default function Header() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  const toggleMobileMenu = () => {
    setMobileMenuOpen(!mobileMenuOpen);
  };

  const scrollToSection = (sectionId: string) => {
    const section = document.getElementById(sectionId);
    if (section) {
      window.scrollTo({
        top: section.offsetTop - 80,
        behavior: "smooth",
      });
    }
    setMobileMenuOpen(false);
  };

  useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 20) {
        setScrolled(true);
      } else {
        setScrolled(false);
      }
    };

    window.addEventListener("scroll", handleScroll);
    return () => {
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);

  return (
    <header className={`sticky top-0 z-50 bg-background/95 backdrop-blur-sm border-b border-border transition-all ${scrolled ? 'shadow-md' : ''}`}>
      <div className="container mx-auto px-4 py-3 flex justify-between items-center">
        <a
          href="#"
          className="text-white font-semibold text-2xl flex items-center"
          onClick={(e) => {
            e.preventDefault();
            window.scrollTo({ top: 0, behavior: "smooth" });
          }}
        >
          <span className="mr-2">TREPIDUS</span>
        </a>

        {/* Desktop Navigation */}
        <nav className="hidden md:flex space-x-8">
          {["about", "services", "team", "testimonials", "contact"].map((item) => (
            <button
              key={item}
              onClick={() => scrollToSection(item)}
              className="text-muted-foreground hover:text-foreground transition-colors capitalize"
            >
              {item}
            </button>
          ))}
        </nav>

        {/* Mobile Navigation Toggle */}
        <button
          aria-label="Toggle mobile menu"
          className="md:hidden focus:outline-none"
          onClick={toggleMobileMenu}
        >
          {mobileMenuOpen ? (
            <X className="h-6 w-6 text-foreground" />
          ) : (
            <Menu className="h-6 w-6 text-foreground" />
          )}
        </button>
      </div>

      {/* Mobile Navigation Menu */}
      <div
        className={`md:hidden bg-secondary border-b border-border transition-all duration-300 ease-in-out ${
          mobileMenuOpen ? "max-h-64 opacity-100" : "max-h-0 opacity-0 overflow-hidden"
        }`}
      >
        <div className="container mx-auto px-4 py-3">
          <nav className="flex flex-col space-y-3">
            {["about", "services", "team", "testimonials", "contact"].map((item) => (
              <button
                key={item}
                onClick={() => scrollToSection(item)}
                className="text-muted-foreground hover:text-foreground py-2 transition-colors text-left capitalize"
              >
                {item}
              </button>
            ))}
          </nav>
        </div>
      </div>
    </header>
  );
}
