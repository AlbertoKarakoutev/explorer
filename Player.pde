class Player{
 
  PVector cameraLocation;
  PVector location;
  PVector velocity;
  PVector acceleration;
  
  PVector weight;
  
  PVector playerVertex;
  
  float viewFactor = 10;
  float radius = 3000/viewFactor;
  float speedMaximum = (viewFactor > 2) ? 100/(viewFactor-2) : 100/viewFactor;
  float theta;
  float fi;

  static final float g = 1.8;
  static final float planeAcc = 10;

  PShape airplane;
  
  ParticleSystem ps;
  ParticleSystem collisionExplosion;
  
  public Player(){
    
      airplane = loadShape("Plane.obj");
      playerVertex = new PVector();
      airplane.scale(4/viewFactor);
      cameraLocation = new PVector();
      
      location = new PVector(0, -4000, 0);
      velocity = new PVector();
      acceleration = new PVector();
      
      weight = new PVector(0, -g, 0);
      
      PVector psLocation = location.copy();
      psLocation.y +=10;
      ps = new ParticleSystem(200, psLocation);
      
  }
  
    void move(){
    detectCollision();
    PVector wind = cameraLocation.copy();
    PVector psLocation = location.copy();
    wind.y-=500;
    psLocation.y +=10;
    ps.run(psLocation);
    
    if(velocity.mag()>0){
      windSound.amp(map(velocity.mag(), 0, 50*1.5, 0, 1));
      if(!windSound.isPlaying()){
        windSound.loop();
      }
    }else{
      windSound.stop();
    }
    
    acceleration.x = planeAcc * cos(theta) * sin(-fi);
    acceleration.z = planeAcc * sin(theta) * sin(-fi);
    acceleration.y = planeAcc * cos(-fi);
   
    //acceleration.add(weight);
    
    if(keyPressed){
      if (key == 'w') {
        
        acceleration.setMag(planeAcc);
        
        wind.y += 1000;
        ps.applyForce(wind.sub(location).div(10000));
        for (int i = 0; i < 10; i++) {
          ps.addParticle();
        }
      }
      if (keyCode == SHIFT) {
        speedMaximum += 0.2;
      }
      if(key == 'r'){
        calculateChunks();
        location = new PVector(0, -5000, 0);
      }
    }
    velocity.add(acceleration.mult(-1));
    velocity.limit(50);
    
    location.add(velocity);
    
    acceleration.set(0, 0, 0);
  }
  
  void update(){
    
   move();
   look();
  }
  
  
  void look(){
    cameraLocation.x = location.x + radius * cos(theta) * sin(-fi);
    cameraLocation.z = location.z + radius * sin(theta) * sin(-fi);
    cameraLocation.y = location.y + radius * cos(-fi);
      
    pushMatrix();
    translate(location.x, location.y, location.z);
    //Rotate model in the proper direction
    rotateY(-theta);
    rotateZ(fi);
    rotateY(map(mouseX, 0, width, -1.5, 1.5));
    shapeMode(CENTER);
    shape(airplane);
    popMatrix();
    
    pushMatrix();
    translate(location.x, location.y, location.z);
    rotateY(-theta);
    rotateZ(fi);
    displayInformation();
    popMatrix();
    
    if(!stop){
     float damp = 0.05;
     float mouseXCentered = map(mouseX, 0, width, -damp, damp);
     float mouseYCentered = map(mouseY, 0, height, -damp, damp);
     theta += mouseXCentered;
     if(theta > TWO_PI || theta < -TWO_PI)theta=0;
     rotateFI(mouseYCentered);
    }
    beginCamera();
    if(frameCount == 1){
      fi=2.4;
    }
    camera(cameraLocation.x, cameraLocation.y, cameraLocation.z, location.x, location.y, location.z, 0, 1, 0);  
    
    endCamera();
  }

  
  void displayInformation(){
    textSize(200/viewFactor);
    noLights();
    fill(255);
    rotateX(-HALF_PI);
    rotateZ(-HALF_PI);
    text((int)location.x + ", " + ((int)-location.y) + ", " + (int)location.z, -1000/viewFactor, -400/viewFactor, 0);
    text("Speed: " + velocity.mag(), -500, -200, 0);
  }


  void rotateFI(float amount){
    if(fi<3 && fi > 0.1){
      fi += amount;
    }else{
      if(fi + amount < 3 && fi + amount > 0.1){
        fi += amount;
      }
    }
    if(fi < 0.1) fi=0.1;
    if(fi > 3) fi=3;
  }

  
  void detectCollision(){
    playerVertex.x = (location.x>0) ? round(abs((player.getLocation().x%chunkSize)/scale)) : vertecies - round(abs((player.getLocation().x%chunkSize)/scale));
    playerVertex.z = (location.z>0) ? round(abs((player.getLocation().z%chunkSize)/scale)) : vertecies - round(abs((player.getLocation().z%chunkSize)/scale));
    float terrainHeightAtPlayerLocation = chunks[floor(chunks.length/2)][floor(chunks.length/2)].getVertex((int)playerVertex.x, (int)playerVertex.z).y - airplane.getHeight()/2;

    if(player.getLocation().y > terrainHeightAtPlayerLocation){
      location.y -= 100;
      //collisionExplosion = new ParticleSystem(500, location.copy());
      stop = !stop;
    }
  }
    
  float[] getChunk(){
    float[] chunkNum = new float[2];
    if(location.x>=0){
      chunkNum[0] = floor((chunkSize + location.x)/chunkSize);
    }else{
      chunkNum[0] = ceil(location.x/chunkSize);
    }
    if(location.z>=0){
      chunkNum[1] = floor(location.z/chunkSize);
    }else{
      chunkNum[1] = ceil((-chunkSize + location.z)/chunkSize);
    }
    return chunkNum;
  }

  float getSpeed(){
    return this.velocity.mag();
  }
  
  PVector getCameraLocation(){
    return this.cameraLocation;
  }
  
  PVector getLocation(){
    return this.location;
  }
  
  float getRadius(){
    return this.radius;
  }
 
  
}
 
