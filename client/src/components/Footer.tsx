export default function Footer() {
  const scrollToSection = (sectionId: string) => {
    const section = document.getElementById(sectionId);
    if (section) {
      window.scrollTo({
        top: section.offsetTop - 80,
        behavior: "smooth",
      });
    }
  };

  return (
    <footer className="bg-secondary border-t border-border py-8">
      <div className="container mx-auto px-4">
        <div className="flex flex-col md:flex-row justify-between items-center">
          <div className="mb-6 md:mb-0">
            <a href="#" className="text-foreground font-semibold text-xl">
              TREPIDUS
            </a>
            <p className="text-muted-foreground mt-2">IT Consulting Made Simple</p>
          </div>

          <div className="flex flex-col md:flex-row space-y-4 md:space-y-0 md:space-x-8 items-center">
            <nav className="flex space-x-4">
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

            <p className="text-muted-foreground text-sm">
              &copy; {new Date().getFullYear()} Trepidus Tech. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
}
