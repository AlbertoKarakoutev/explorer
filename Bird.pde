class Bird{
 
  PVector position;
  PVector velocity;
  PVector acceleration;
  
  float maxForce = 1;
  float maxSpeed = 1;
  
  Chunk chunk;
  
  public Bird(Chunk chunk){
    position = new PVector(random(chunkSize/2), random(-chunkSize/0.9, -chunkSize), random(chunkSize/2)); 
    velocity = PVector.random3D();
    velocity.setMag(random(20, 40));
    this.chunk = chunk;
    acceleration = new PVector();
    
  }
  
  
  void display(){
    update();

    float theta = atan(velocity.z/velocity.x);
    float fi = atan(velocity.y/velocity.x);
    if(velocity.x>=0)theta += PI/2; fi += PI/2;
    if(velocity.x<0)theta += PI*1.5; fi += PI*1.5;
    
    pushMatrix();
    translate(position.x, position.y, position.z);
    rotateY(-theta);
    shape(bird);
    popMatrix();
  }
  
  
  void avoid() {
    
    PVector steering = new PVector();
    
    float db = dist(position.x, position.y, position.z, position.x, 0, position.z);
    float dt = dist(position.x, position.y, position.z, position.x, -chunkSize, position.z);
    float dl = dist(position.x, position.y, position.z, 0, position.y, position.z);
    float dr = dist(position.x, position.y, position.z, chunkSize, position.y, position.z);
    float df = dist(position.x, position.y, position.z, position.x, position.y, 0);
    float dba = dist(position.x, position.y, position.z, position.x, position.y, chunkSize);

    float min = 100;
 
    boolean headingForCollision = db<=min||dt<=min||dr<=min||dl<=min||df<=min||dba<=min;
    if(headingForCollision){
      float dist1 = min(db, dt, dl);
      float dist2 = min(dr, df, dba);
      float dist = min(dist1, dist2);
      for(PVector ray : rays()){
        
        if(isInside(PVector.add(position, ray), min)){
          ray.setMag(map(dist, 100, 0, 0, 3));
          acceleration.add(ray);
          break;
        }
      }
    }

    PVector birdVertex = new PVector();
    birdVertex.x = (position.x>0) ? round(abs((position.x%chunkSize)/scale)) : vertecies - round(abs((position.x%chunkSize)/scale));
    birdVertex.y = position.y;
    birdVertex.z = (position.z>0) ? round(abs((position.z%chunkSize)/scale)) : vertecies - round(abs((position.z%chunkSize)/scale));
    
    float terrainHeightAtBirdLocation = chunk.getVertex((int)birdVertex.x, (int)birdVertex.z).y;
    if(position.y > terrainHeightAtBirdLocation - 200 ){
      velocity.mult(-0.5);
      position.y-=0.2;
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
    acceleration.add(direction.mult(1));
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
    acceleration.add(direction.mult(1));
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
    acceleration.add(direction.mult(1));
  }
  
  boolean isInside(PVector vector, float offset){
    if(vector.x <= offset || vector.x >= chunkSize-offset)return false;
    if(vector.y >= -offset || vector.y <= -chunkSize+offset)return false;
    if(vector.z <= offset || vector.z >= chunkSize-offset)return false;
    return true;
  }
    
  PVector[] rays(){
    
    int numViewDirections = 25;
    PVector[] directions = new PVector[numViewDirections];

    float goldenRatio = (1 + sqrt(5)) / 2;
    float angleIncrement = PI * 2 * goldenRatio;
    
    float mult = 210;
    
    for (int i = 0; i < numViewDirections; i++) {
        float t = (float) i / numViewDirections;
        float fi = acos (1 - 2 * t);
        float theta = angleIncrement * i;

        float x = sin (fi) * cos (theta);
        float y = sin (fi) * sin (theta);
        float z = cos (fi);
        directions[i] = new PVector(x*mult, y*mult, z*mult);
    }
    return directions;
  }
  
  void update(){
    float chance = random(1);
    if(chance > 0.8){
      //acceleration = PVector.random3
    }
    velocity.limit(4);
    position.add(velocity);
    velocity.add(acceleration);
  }
  
}
