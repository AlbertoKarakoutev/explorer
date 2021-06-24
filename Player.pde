class Player{
 
  PVector cameraLocation;
  PVector location;
  PVector velocity;
  PVector weight;
  
  float viewFactor = 10;
  float radius = 250;
  float acceleration = 20;
  float maximumVelocity = 200;
  float theta;
  float fi;

  PShape airplane;
  
  ParticleSystem ps;
  ParticleSystem collisionExplosion;
  
  public Player(){
    
      airplane = loadShape("models/Plane.obj");
      float factor = 50/airplane.getHeight();
      airplane.scale(factor);
      cameraLocation = new PVector(0,0,0);
      location = new PVector(chunkSize/4, -chunkSize/2 - airplane.getHeight(), chunkSize/2);
      rotateFI(PI/2);
      velocity = new PVector(250, 0, 0);
      weight = new PVector(0, 1, 0);

      PVector psLocation = location.copy();
      psLocation.y +=10;
      ps = new ParticleSystem(400, psLocation);
      
  }
  
  
  void update(){
   look();
   move();
  }
  
  void look(){
    rotateModel();
    rotateCamera();
  }

  void rotateModel(){
    pushMatrix();
      translate(location.x, location.y, location.z);
      rotateY(-theta);
      rotateZ(fi);
      rotateY(map(mouseX, 0, width, -1.5, 1.5));
      shapeMode(CENTER);
      shape(airplane);
    popMatrix();
  }

  void rotateCamera(){
    cameraLocation.x = location.x + radius * cos(theta) * sin(-fi);
    cameraLocation.z = location.z + radius * sin(theta) * sin(-fi);
    cameraLocation.y = location.y + radius * cos(-fi);

    pushMatrix();
      translate(location.x, location.y, location.z);
      rotateY(-theta);
      rotateZ(fi);
      displayInformation();
    popMatrix();

    limitRotationAngles();

    camera(cameraLocation.x, cameraLocation.y, cameraLocation.z, location.x, location.y, location.z, 0, 1, 0);  
  }

  void limitRotationAngles(){
    if(!stop){
     float damp = 0.05;
     float mouseXCentered = map(mouseX, 0, width, -damp, damp);
     float mouseYCentered = map(mouseY, 0, height, -damp, damp);
     theta += mouseXCentered;
     if(theta > TWO_PI || theta < -TWO_PI)theta=0;
     rotateFI(mouseYCentered);
    }
    if(frameCount == 1){
      fi=2.4;
    }
  }

  void move(){

    movementEffects();
    
    if(acceleration > maximumVelocity)acceleration = maximumVelocity;

    if(!stop){

      readInput();

      setVelocity();

      if(isGravityActive)applyGravity();
      applyVelocity();
      
    }
  }
  
  void applyGravity(){
      weight.mult(map(velocity.mag(), 0, maximumVelocity, maximumVelocity, 0));
      if(!isUnderground(location.y+velocity.y+weight.y))velocity.add(weight);

      weight.set(0, 1, 0);
  }

  void setVelocity(){
      
      velocity.x = acceleration * -cos(theta) * sin(-fi);
      velocity.z = acceleration * -sin(theta) * sin(-fi);
      velocity.y = acceleration * -cos(-fi);

  }

  void applyVelocity(){
      /*Zero small velocities*/
      if(velocity.mag() < 1){
        velocity.setMag(0);
      }

      location.x+=velocity.x/10;
      location.z+=velocity.z/10;

      if(!isUnderground(location.y)){
        location.y += velocity.y/10;
      }else{
        location.y = getTerrainHeightAtPlayerLocation();
      }
  }

  void readInput(){      
    if(keyPressed){
      /*Increase velocity*/
      if (key == 'w') {
        acceleration+=1;
      }else{
        acceleration = (acceleration >= 0) ? acceleration-1 : 0;
      }
      /*Increase maximum velocity*/
      if (keyCode == SHIFT) {
        maximumVelocity += 0.1;
      }
      /*Reset*/
      if(key == 'r'){
        location.set(chunkSize/2, -10000, chunkSize/2);
        initializeChunks();
      }
    }else{
      acceleration = (acceleration >= 0) ? acceleration-1 : 0;
    }
  }

  boolean isUnderground(float playerHeight){
    //boolean isInsideX = location.x > chunkSize*0.1 && location.x < chunkSize*0.9;
    //boolean isInsideY = location.y > chunkSize*0.1;
    //boolean isInsideZ = location.z > chunkSize*0.45 && location.z < chunkSize*0.55;
    //boolean isInsideTrack = isInsideX && isInsideY && isInsideZ;
    
    boolean isInsideTrack = false;
    boolean isUnderTerrain = playerHeight + 2*airplane.getHeight() > getTerrainHeightAtPlayerLocation();
    
    if(isInsideTrack || isUnderTerrain){
      return true;
    }
    return false;
  }
    
  float getTerrainHeightAtPlayerLocation(){
    /*Player vertex x and z*/
    float pLocationX = (location.x>=0) ? (location.x%chunkSize)/scale : vertecies - (abs(location.x)%chunkSize)/scale;
    float pLocationZ = (location.z>=0) ? (location.z%chunkSize)/scale : vertecies - (abs(location.z)%chunkSize)/scale;

    int centerChunk = floor(chunks.length/2);
    
    return chunks[centerChunk][centerChunk].calculateSmoothHeightAtLocation(pLocationX, pLocationZ);
  }

  /*
    Show coordinates and speed
  */
  void displayInformation(){
    textSize(200/viewFactor);
    noLights();
    pushStyle();
    rotateX(-HALF_PI);
    rotateZ(-HALF_PI);
    text((int)location.x + ", " + ((int)-location.y) + ", " + (int)location.z, -1000/viewFactor, -400/viewFactor, 0);
    text("Speed: " + round(velocity.mag()) + " km/h", -300, -200, 0);
    text("Maximum speed: " + round(maximumVelocity) + " km/h", -300, -240, 0);
    popStyle();
  }

  /*
    Re-calculate the vertical rotation and cap it
  */
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
 
