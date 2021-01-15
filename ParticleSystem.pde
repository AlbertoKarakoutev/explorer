class ParticleSystem {

  ArrayList<Particle> particles;
  PVector origin;    

  ParticleSystem(int num, PVector v) {
    particles = new ArrayList<Particle>();
    origin = v.copy();         
    for (int i = 0; i < num; i++) {
      particles.add(new Particle(origin));
    }
  }

  void run(PVector newLocation) {
    origin = newLocation.copy();
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  void applyForce(PVector dir) {
    for (Particle p : particles) {
      p.loc.add(dir);
    }
  }  

  void addParticle() {
    particles.add(new Particle(origin));
  }
}
