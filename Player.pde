
class Player{
 
  PVector location;
  PVector direction;
  
  float radius = 3000;
  float speed = 100;
  boolean stop = false;

  float theta;
  float fi;

  PShape airplane;
  
  public Player(){
    
      airplane = loadShape("Plane.obj");
      location = new PVector(0,0,0);
      direction = new PVector(0, -3000, 0);

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
    textSize(200);
    noLights();
    fill(255);
    rotateX(-HALF_PI);
    rotateZ(-HALF_PI);
    text((int)direction.x + ", " + (int)direction.y + ", " + (int)direction.z, -1000, -400, 0);
    //box(50);
    popMatrix();
    
    if(!stop){
     float damp = 0.05;
     float mouseXCentered = map(mouseX, 0, width, -damp, damp);
     float mouseYCentered = map(mouseY, 0, height, -damp, damp);
     theta += mouseXCentered;
     if(fi<3 && fi > 0.1){
       fi += mouseYCentered;
     }else{
       if(fi + mouseYCentered < 3 && fi + mouseYCentered > 0.1){
         fi += mouseYCentered;
       }
     }
     if(theta > TWO_PI || theta < -TWO_PI)theta=0;
     if(fi < 0.1) fi=0.1;
     if(fi > 3) fi=3;
    }
    beginCamera();
    if(frameCount == 1){
      fi=2.4;
    }
    camera(location.x, location.y, location.z, direction.x, direction.y, direction.z, 0, 1, 0);  
    
    endCamera();
}

  void move(){
 
    float ratio = (radius + speed)/radius;
    
    if(keyPressed){
      if (key == 'w') {
        
        direction.x = (1-ratio)*location.x + ratio*direction.x;
        direction.y = (1-ratio)*location.y + ratio*direction.y;
        direction.z = (1-ratio)*location.z + ratio*direction.z;
    
      }
      if (key == 's') { 
        direction.x = (ratio)*location.x + (1-ratio)*direction.x;
        direction.y = (ratio)*location.y + (1-ratio)*direction.y;
        direction.z = (ratio)*location.z + (1-ratio)*direction.z;
      }
      if(key == 'r'){
        direction = new PVector(0, 0, 0);
        calculateChunks();
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

  
