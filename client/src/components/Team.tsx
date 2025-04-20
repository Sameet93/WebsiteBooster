import { Card } from "@/components/ui/card";
import ScrollAnimation from "./ScrollAnimation";
import { AspectRatio } from "@/components/ui/aspect-ratio";

export default function Team() {
  const teamMembers = [
    {
      name: "Sameet",
      role: "Co-founder & CTO",
      imgUrl: "https://mlrdxjezzfez.i.optimole.com/w:201/h:268/q:mauto/ig:avif/http://trepidustech.com/wp-content/uploads/2024/11/IMG_2631-scaled.jpeg"
    },
    {
      name: "Dharnesh",
      role: "Co-founder",
      imgUrl: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=500&h=667"
    },
    {
      name: "Yashmay",
      role: "Technical Lead",
      imgUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=500&h=667"
    }
  ];

  return (
    <section id="team" className="py-20 bg-background">
      <ScrollAnimation>
        <div className="container mx-auto px-4">
          <h2 className="text-3xl md:text-4xl font-bold mb-12 text-center">
            Our Leadership Team
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-5xl mx-auto">
            {teamMembers.map((member, index) => (
              <Card key={index} className="bg-secondary overflow-hidden hover:shadow-lg transition-shadow">
                <AspectRatio ratio={1} className="bg-muted">
                  <div className="w-full h-full flex items-center justify-center overflow-hidden">
                    <img
                      src={member.imgUrl}
                      alt={`${member.name} - ${member.role}`}
                      className={`w-full h-full object-cover ${member.name === "Sameet" ? "object-top scale-110 grayscale-[30%]" : ""}`}
                      loading="lazy"
                      style={{
                        filter: member.name === "Sameet" ? "contrast(1.1) brightness(1.05)" : "none"
                      }}
                    />
                  </div>
                </AspectRatio>
                <div className="p-5">
                  <h3 className="text-xl font-semibold">{member.name}</h3>
                  <p className="text-primary">{member.role}</p>
                </div>
              </Card>
            ))}
          </div>
        </div>
      </ScrollAnimation>
    </section>
  );
}
