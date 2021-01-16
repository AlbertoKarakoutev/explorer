class Player{
 
  PVector cameraLocation;
  PVector location;
  PVector playerVertex;
  
  float viewFactor = 10;
  float radius = 3000/viewFactor;
  float speed = 0;
  float speedMaximum = (viewFactor > 2) ? 100/(viewFactor-2) : 100/viewFactor;
  float theta;
  float fi;

  PShape airplane;
  
  ParticleSystem ps;
  ParticleSystem collisionExplosion;
  
  public Player(){
    
      airplane = loadShape("Plane.obj");
      playerVertex = new PVector();
      airplane.scale(1/viewFactor);
      cameraLocation = new PVector(0,0,0);
      location = new PVector(0, -3000, 0);

      PVector psLocation = location.copy();
      psLocation.y +=5;
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

  void displayInformation(){
    textSize(200/viewFactor);
    noLights();
    fill(255);
    rotateX(-HALF_PI);
    rotateZ(-HALF_PI);
    text((int)location.x + ", " + (int)location.y + ", " + (int)location.z, -1000/viewFactor, -400/viewFactor, 0);
    text("Speed: " + speed, -500, -200, 0);
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

  void move(){
    detectCollision();
    
    PVector wind = cameraLocation.copy();
    PVector psLocation = location.copy();
    wind.y-=500;
    psLocation.y +=5;
    ps.run(psLocation);
    float ratio = (radius + speed)/radius;
    
    
    if(keyPressed){
      if(speed < speedMaximum)speed+=(speedMaximum/4)/frameRate; 
      if (key == 'w') {
        location.x = (1-ratio)*cameraLocation.x + ratio*location.x;
        location.y = (1-ratio)*cameraLocation.y + ratio*location.y;
        location.z = (1-ratio)*cameraLocation.z + ratio*location.z;
       
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
        location = new PVector(0, -5000, 0);
        calculateChunks();
      }
    }else{
      if(!stop){
        rotateFI(map(speed/speedMaximum, 1, 0, 0, 5)/500);
        if(speed > 0){
          if(!maintainSpeed)speed-=(speedMaximum/10)/frameRate; 
          if(speed >= 0)location.y+=map(speed/speedMaximum, 1, 0, 0, 10);
        }else if(speed<0){
          if(!stop){
            if(location.y<2000)location.y+=10;
          }
        }
      
        location.x = (1-ratio)*cameraLocation.x + ratio*location.x;
        location.y = (1-ratio)*cameraLocation.y + ratio*location.y;
        location.z = (1-ratio)*cameraLocation.z + ratio*location.z;
      }
    }
    
  }
  
  void detectCollision(){
    playerVertex.x = (location.x>0) ? floor(abs((player.getLocation().x%chunkSize)/scale)) : vertecies - floor(abs((player.getLocation().x%chunkSize)/scale));
    playerVertex.y = (location.z>0) ? floor(abs((player.getLocation().z%chunkSize)/scale)) : vertecies - floor(abs((player.getLocation().z%chunkSize)/scale));
    float terrainHeightAtPlayerLocation = 0;
    terrainHeightAtPlayerLocation = chunks[1][1].getVertex((int)playerVertex.x, (int)playerVertex.y).y - airplane.getHeight();
    //Triangle3D.closestPointOnSurface(Vec3D p)
    //println(airplane.depth);
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
    return this.speed;
  }
  
  float getMaximumSpeed(){
    return this.speedMaximum;
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
 
