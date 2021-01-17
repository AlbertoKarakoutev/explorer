class Bird{
 
  PVector position;
  PVector velocity;
  PVector acceleration;
  
  float maxForce = 0.5;
  float maxSpeed = 1;
  
  PShape bird;
  
  Chunk chunk;
  
  public Bird(Chunk chunk){
    position = new PVector(random(chunkSize/2), random(-chunkSize/2, 0), random(chunkSize/2)); 
    velocity = PVector.random3D();
    velocity.setMag(random(20, 40));
    this.chunk = chunk;
    acceleration = new PVector();
    bird = loadShape("Bird.obj");
    bird.scale(0.3);
  }
  
  
  void display(){
    update();
    
    /*
    Code for bird rotation:
    
    PVector heading = new PVector(position.x, position.z);
    float sine = abs(position.x - velocity.x)/dist(velocity.x, velocity.z, position.x, position.z);
    float mainAngle = asin(position.x/dist(heading.x, heading.y, 0, 0));
    float angle = 180 - (mainAngle*(180/PI)+asin(sine));
    rotateY(radians(angle));
    
    */
    
    pushMatrix();
    translate(position.x, position.y, position.z);
    shapeMode(CENTER);
    fill(0);
    shape(bird);
    popMatrix();
  }
  
  
  void avoid() {
    PVector bottom = new PVector(position.x, 0, position.z);
    PVector top = new PVector(position.x, -chunkSize, position.z);
    PVector left = new PVector(0, position.y, position.z);
    PVector right = new PVector(chunkSize, position.y, position.z);
    PVector front = new PVector(position.x, position.y, 0);
    PVector back = new PVector(position.x, position.y, chunkSize);
    
    PVector steering = new PVector();
    
    float db = dist(position.x, position.y, position.z, bottom.x, bottom.y, bottom.z);
    float dt = dist(position.x, position.y, position.z, top.x, top.y, top.z);
    float dl = dist(position.x, position.y, position.z, left.x, left.y, left.z);
    float dr = dist(position.x, position.y, position.z, right.x,right.y, right.z);
    float df = dist(position.x, position.y, position.z, front.x, front.y, front.z);
    float dba = dist(position.x, position.y, position.z, back.x, back.y, back.z);

    float minWallDistance = 100;
    
    if(db <= minWallDistance){
      velocity.mult(-0.3);
      position.y-=30;
    }
    if(dt <= minWallDistance){
      velocity.mult(-0.3);
      position.y+=30;
    }
    if(dl <= minWallDistance){
      velocity.mult(-0.3);
      position.x+=30;
    }
    if(dr <= minWallDistance){
      velocity.mult(-0.3);
      position.x-=30;
    }
    if(df <= minWallDistance){
      velocity.mult(-0.3);
      position.z+=30;
    }
    if(dba <= minWallDistance){
      velocity.mult(-0.3);
      position.z-=30;
    }

    PVector birdVertex = new PVector();
    birdVertex.x = (position.x>0) ? round(abs((position.x%chunkSize)/scale)) : vertecies - round(abs((position.x%chunkSize)/scale));
    birdVertex.y = position.y;
    birdVertex.z = (position.z>0) ? round(abs((position.z%chunkSize)/scale)) : vertecies - round(abs((position.z%chunkSize)/scale));
    
    float terrainHeightAtBirdLocation = chunk.getVertex((int)birdVertex.x, (int)birdVertex.z).y;
    if(position.y > terrainHeightAtBirdLocation - minWallDistance ){
      position.y -= 30;
      velocity.mult(-0.3);
    }
  }
  
  
  void alignment(Bird[] birds){
    float viewDistance = chunkSize/6;
    float total = 0;
    PVector direction = new PVector();
    for(Bird bird : birds){
      float d = dist(position.x, position.y, position.z, bird.position.x, bird.position.y, bird.position.z);
      if(bird != this && d < viewDistance){
        direction.add(bird.velocity);
        total++;
      }
    }
    if(total > 0){
      direction.div(total);
      direction.sub(velocity);
      direction.setMag(maxSpeed*2);
      direction.limit(maxForce);
    }
    acceleration.add(direction.mult(3));
  }
  
  
  void cohesion(Bird[] birds){
    float viewDistance = chunkSize/5;
    float total = 0;
    PVector direction = new PVector();
    for(Bird bird : birds){
      float d = dist(position.x, position.y, position.z, bird.position.x, bird.position.y, bird.position.z);
      if(bird != this && d < viewDistance){
        direction.add(bird.position);
        total++;
      }
    }
    if(total > 0){
      direction.div(total);
      direction.sub(velocity);
      //direction.setMag(maxSpeed);
      direction.sub(position);
      direction.limit(maxForce);
    }
    acceleration.add(direction.mult(3));
  }
  
  
  void separation(Bird[] birds){
    float viewDistance = chunkSize/20;
    float total = 0;
    PVector direction = new PVector();
    for(Bird bird : birds){
      float d = dist(position.x, position.y, position.z, bird.position.x, bird.position.y, bird.position.z);
      if(bird != this && d < viewDistance){
        PVector diff = PVector.sub(position, bird.position);
        //diff.div(viewDistance);
        direction.add(diff);
        total++;
      }
    }
    if(total > 0){
      direction.div(total);
      //direction.setMag(maxSpeed);
      direction.sub(velocity);
      direction.limit(maxForce);
    }
    acceleration.add(direction.mult(3));
  }
  
  
  void update(){
    float chance = random(1);
    velocity.limit(4);
    position.add(velocity);
    velocity.add(acceleration);
  }
  
}
