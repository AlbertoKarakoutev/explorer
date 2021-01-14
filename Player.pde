
class Player{
 
  PVector location;
  PVector direction;
  
  float viewFactor = 10;
  float radius = 3000/viewFactor;
  float speed = 0;
  float speedMaximum = (viewFactor > 2) ? 100/(viewFactor-2) : 100/viewFactor;
  boolean stop = false;
  float theta;
  float fi;

  PShape airplane;
  
  ParticleSystem ps;

  public Player(){
    
      airplane = loadShape("Plane.obj");
      
      airplane.scale(1/viewFactor);
      location = new PVector(0,0,0);
      direction = new PVector(0, -3000, 0);

      PVector psLocation = direction.copy();
      psLocation.y +=5;
      ps = new ParticleSystem(200, psLocation);

  }
  
  void update(){
   look();
   move();
  }
  
  void look(){
    location.x = direction.x + radius * cos(theta) * sin(-fi);
    location.z = direction.z + radius * sin(theta) * sin(-fi);
    location.y = direction.y + radius * cos(-fi);
      
    pushMatrix();
    translate(direction.x, direction.y, direction.z);
    //Rotate model in the proper direction
    rotateY(-theta);
    rotateZ(fi);
    rotateY(map(mouseX, 0, width, -1.5, 1.5));
    shapeMode(CENTER);
    shape(airplane);
    textSize(200/viewFactor);
    noLights();
    fill(255);
    rotateX(-HALF_PI);
    rotateZ(-HALF_PI);
    text((int)direction.x + ", " + (int)direction.y + ", " + (int)direction.z, -1000/viewFactor, -400/viewFactor, 0);
    //box(50);
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
    camera(location.x, location.y, location.z, direction.x, direction.y, direction.z, 0, 1, 0);  
    
    endCamera();
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
    
    PVector wind = location.copy();
    PVector psLocation = direction.copy();
    wind.y-=500;
    psLocation.y +=5;
    ps.run(psLocation);
    float ratio = (radius + speed)/radius;
    if(keyPressed){
      if(speed < speedMaximum)speed+=speedMaximum/frameRate; 
      if (key == 'w') {
        direction.x = (1-ratio)*location.x + ratio*direction.x;
        direction.y = (1-ratio)*location.y + ratio*direction.y;
        direction.z = (1-ratio)*location.z + ratio*direction.z;
       
        wind.y += 1000;
        ps.applyForce(wind.sub(direction).div(10000));
        for (int i = 0; i < 10; i++) {
          ps.addParticle();
        }
      }
      if (key == 's') { 
        direction.x = (ratio)*location.x + (1-ratio)*direction.x;
        direction.y = (ratio)*location.y + (1-ratio)*direction.y;
        direction.z = (ratio)*location.z + (1-ratio)*direction.z;
      }
      if (keyCode == SHIFT) {
        speedMaximum += 1;
      }
      if(key == 'r'){
        direction = new PVector(0, 0, 0);
        calculateChunks();
      }
    }else{
      if(!stop){
        rotateFI(map(speed/speedMaximum, 1, 0, 0, 5)/500);
        if(speed > 0){
          speed-=(speedMaximum/4)/frameRate; 
          if(speed >= 0){
            direction.y+=map(speed/speedMaximum, 1, 0, 0, 10);
          }
        }else if(speed<0){
          if(!stop){
            if(direction.y<2000)direction.y+=10;
          }
        }
      
        direction.x = (1-ratio)*location.x + ratio*direction.x;
        direction.y = (1-ratio)*location.y + ratio*direction.y;
        direction.z = (1-ratio)*location.z + ratio*direction.z;
      }
    }
    
  }
  
  float[] getChunk(){
    float[] chunkNum = new float[2];
    if(direction.x>=0){
      chunkNum[0] = floor((chunkSize + direction.x)/chunkSize);
    }else{
      chunkNum[0] = ceil(direction.x/chunkSize);
    }
    if(direction.z>=0){
      chunkNum[1] = floor(direction.z/chunkSize);
    }else{
      chunkNum[1] = ceil((-chunkSize + direction.z)/chunkSize);
    }
    return chunkNum;
  }

  float getSpeed(){
    return this.speed;
  }
  
  float getMaximumSpeed(){
    return this.speedMaximum;
  }

  PVector getLocation(){
    return this.location;
  }
  
  PVector getDirection(){
    return this.direction;
  }
  
  float getRadius(){
    return this.radius;
  }
 
  
}
 
