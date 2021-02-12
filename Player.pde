class Player{
 
  PVector cameraLocation;
  PVector location;
  PVector velocity;
  PVector weight;
  PVector playerVertexFloat;
  
  float viewFactor = 10;
  float radius = 3000/viewFactor;
  //float speedMaximum = (viewFactor > 2) ? 15/(viewFactor-2) : 15/viewFactor;
  float acceleration = 0;
  float maximumVelocity = 250;
  float theta;
  float fi;

  PShape airplane;
  
  ParticleSystem ps;
  ParticleSystem collisionExplosion;
  
  public Player(){
    
      airplane = loadShape("models/Plane.obj");
      playerVertexFloat = new PVector();
      airplane.scale(4/viewFactor);
      cameraLocation = new PVector(0,0,0);
      location = new PVector(chunkSize/2, -10000, chunkSize/2);
      velocity = new PVector();
      weight = new PVector(0, 1, 0);

      PVector psLocation = location.copy();
      psLocation.y +=10;
      ps = new ParticleSystem(200, psLocation);
      
  }
  
  
  void update(){
   look();
   move();
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




  void move(){

    movementEffects();
    
    if(acceleration > maximumVelocity)acceleration = maximumVelocity;

    if(!stop){
      if(keyPressed){
        if (key == 'w') {
          acceleration+=1;
        }else{
          acceleration = (acceleration >= 0) ? acceleration-1 : 0;
        }
        if (keyCode == SHIFT) {
          maximumVelocity += 0.1;
        }
        if(key == 'r'){
          location = new PVector(0, -5000, 0);
          initializeChunks();
        }
      }else{
        acceleration = (acceleration >= 0) ? acceleration-1 : 0;
      }
      
      velocity.x = acceleration * -cos(theta) * sin(-fi);
      velocity.z = acceleration * -sin(theta) * sin(-fi);
      velocity.y = acceleration * -cos(-fi);

      weight.mult(map(velocity.mag(), 0, maximumVelocity, maximumVelocity, 0));
      if(!isUnderground(PVector.add(velocity, weight).add(location).y))velocity.add(weight);

      if(velocity.mag() < 1){
        velocity.setMag(0);
      }
      
      if(isUnderground(location.y+velocity.y/10)){
        location.x+=velocity.x/10;
        location.z+=velocity.z/10;
        if(location.y+velocity.y < location.y)location.add(velocity.copy().div(10));
      }else{
        location.add(velocity.copy().div(10));
      }
      weight.set(0, 1, 0);
    }
  }
  
  
  boolean isUnderground(float playerHeight){
    playerVertexFloat.x = (location.x>=0) ? (location.x%chunkSize)/scale : vertecies - (abs(location.x)%chunkSize)/scale;
    playerVertexFloat.z = (location.z>=0) ? (location.z%chunkSize)/scale : vertecies - (abs(location.z)%chunkSize)/scale;
    float terrainHeightAtPlayerLocation = chunks[floor(chunks.length/2)][floor(chunks.length/2)].calculateHeight(playerVertexFloat.x, playerVertexFloat.z);
    if(playerHeight > terrainHeightAtPlayerLocation){
      location.y = lerp(location.y, terrainHeightAtPlayerLocation, 0.3);
      return true;
    }
    return false;
  }
    
  void displayInformation(){
    textSize(200/viewFactor);
    noLights();
    pushStyle();
    //fill(255);
    rotateX(-HALF_PI);
    rotateZ(-HALF_PI);
    text((int)location.x + ", " + ((int)-location.y) + ", " + (int)location.z, -1000/viewFactor, -400/viewFactor, 0);
    text("Speed: " + round(velocity.mag()) + " km/h", -300, -200, 0);
    text("Maximum speed: " + round(maximumVelocity) + " km/h", -300, -240, 0);
    popStyle();
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

  void movementEffects(){
    
    PVector wind = cameraLocation.copy();
    PVector psLocation = location.copy();
    
    psLocation.y +=10;
    ps.run(psLocation);
    
    wind.y-=500;
    if(velocity.mag()>0){
      windSound.amp(map(velocity.mag(), 0, maximumVelocity, 0, 0.1));
      if(!windSound.isPlaying()){
        //windSound.loop();
      }
    }else{
      windSound.stop();
    }
    if(stop)windSound.stop();
    
    if(keyPressed){
      if (key == 'w') {
        wind.y += 1000;
          
        ps.applyForce(wind.sub(location).div(10000));
        for (int i = 0; i < 10; i++) {
          ps.addParticle();
        }
      }
    }
  }
  
  PVector getCameraLocation(){
    return this.cameraLocation;
  }
  
  PVector getLocation(){
    return this.location;
  }
  
  float[] getChunk(){
    float[] chunkNum = new float[2];

    chunkNum[0] = (location.x>=0) ? floor((chunkSize + location.x)/chunkSize) : ceil(location.x/chunkSize);
    chunkNum[1] = (location.z>=0) ? floor(location.z/chunkSize) : ceil((-chunkSize + location.z)/chunkSize);
   
    return chunkNum;
  }

  float getRadius(){
    return this.radius;
  }
 
  float getVelocity(){
    return this.velocity.mag();
  }
  
  float getMaximumVelocity(){
    return this.maximumVelocity;
  }

}
 
