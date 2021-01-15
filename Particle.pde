class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  float lifespan;

  Particle(PVector l) {
    acc = new PVector(0, 0);
    float vx = randomGaussian()*0.2;
    float vz = randomGaussian()*0.2;
    vel = new PVector(vx, 0, vz);
    loc = l.copy();
    lifespan = random(50, 300);
  }

  void run() {
    update();
    render();
  }
  
  void update() {
    vel.add(acc);
    loc.add(vel);
    lifespan -= random(1.5, 3.5);
    acc.mult(0);
  }

  void render() {
     pushStyle();
     stroke(100);
     strokeWeight(6);
     point(loc.x, loc.y, loc.z);
     popStyle();
  }

  boolean isDead() {
    if (lifespan <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
