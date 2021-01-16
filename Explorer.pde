PVector[] points = new PVector[10]; //<>//

float offset = 0;
float[] playerChunk = {1, 0};

int chunkNumber = 4;

Player player;

Chunk targetChunk;
Chunk[][] chunks;

boolean stop = true;
boolean maintainSpeed = false;

static int vertecies = 200;
static float chunkSize = 5000;
static float scale = chunkSize/vertecies;

PImage loading;

void settings(){
 
 fullScreen(P3D);
 smooth(8); 
 
  
}


void setup() {
  noiseSeed(123);
  
  loading = loadImage("loading.png");
  loading.resize(width,height);
  background(loading);
    
  player = new Player();
  chunks = new Chunk[chunkNumber][chunkNumber];
   //<>//
}

void draw() {
  
  loadingScreen();
  
  float skyColor = map(player.getLocation().y, -3000, -30000, 255, 0);
  if(player.getLocation().y > -3000)skyColor = 255;
  background(color(0, skyColor, skyColor));
  perspective(map(player.getSpeed(), 0, player.getMaximumSpeed(), PI/2, PI/(1.9)), float(width)/float(height), (height/2) / tan((PI/3)/2)/10, 30000); 
  noStroke();
  
  
  if((int)playerChunk[0] != (int)player.getChunk()[0] || (int)playerChunk[1] != (int)player.getChunk()[1]){
    float now = millis();
    updateChunks();
    //calculateChunks();
    
    float timeTaken = millis() - now;
    println("This took " + timeTaken/1000 + " seconds.");
  }
  playerChunk = player.getChunk();
  player.update();
  
  lights();
  
  for(int i = 0; i < chunks.length; i++){
    for(int j = 0; j < chunks[0].length; j++){
      chunks[i][j].display();
    }
  }
  
  pushMatrix();
  translate(0, -3000, 0);
  fill(255,0,0);
  box(50);
  stroke(255, 0, 0);
  strokeWeight(4);
  line(-500/2, 0, 0, 500, 0, 0);
  stroke(0, 255, 0);
  line(0, -500, 0, 0, 500, 0);
  stroke(0, 0, 255);
  line(0, 0, -500, 0, 0, 500);
  popMatrix();
  
  //println("Radius: " + player.getRadius());
  //println("Location: " + player.getLocation());
  //println("Direction: " + player.getDirection());
  //println("Center chunk: " + chunks[1][1].getPosition());
  //println("Player chunk: " + player.getChunk()[0] + " " + player.getChunk()[1]);
  //println("Stopped: " + player.stop);
  //println(" ");
}

void calculateChunks(){
  
  scale = chunkSize/vertecies;
  PVector playerChunkCoordinates = new PVector();
  playerChunkCoordinates.x = player.getChunk()[0]*chunkSize;
  playerChunkCoordinates.y = 0;
  playerChunkCoordinates.z = player.getChunk()[1]*chunkSize;
  for(int i = 0; i < chunks.length; i++){
    for(int j = 0; j < chunks[0].length; j++){
      PVector chunkPos = new PVector(0, 0, 0);
      chunkPos.x = playerChunkCoordinates.x + (i-2)*chunkSize;
      chunkPos.z = playerChunkCoordinates.z + (j-1)*chunkSize;
      chunks[i][j] = new Chunk(chunkPos);
    }
  }
}

void updateChunks(){
  PVector playerChunkCoordinates = new PVector();
  playerChunkCoordinates.x = player.getChunk()[0]*chunkSize;
  playerChunkCoordinates.y = 0;
  playerChunkCoordinates.z = player.getChunk()[1]*chunkSize;
  String movementDirection = "";
  if(playerChunk[0] < player.getChunk()[0])movementDirection = "west";
  if(playerChunk[0] > player.getChunk()[0])movementDirection = "east";
  if(playerChunk[1] < player.getChunk()[1])movementDirection = "south";
  if(playerChunk[1] > player.getChunk()[1])movementDirection = "north";
  if(movementDirection.equals(""))movementDirection = "north";
      switch(movementDirection){
        
        case "west":
          for(int i = 1; i < chunks.length; i++){
            for(int j = 0; j < chunks[0].length; j++){
               chunks[i-1][j] = chunks[i][j]; 
            }
          }
          for(int i = 0; i < chunks.length; i++){
            PVector chunkPos = new PVector(0, 0, 0);
            chunkPos.x = playerChunkCoordinates.x + (chunks.length-3)*chunkSize;
            chunkPos.z = playerChunkCoordinates.z + (i-1)*chunkSize;
            chunks[chunks.length-1][i] = new Chunk(chunkPos);
          }
          break;
          
        case "east":
          for(int i = chunks.length-2; i >= 0; i--){
            for(int j = 0; j < chunks[0].length; j++){
               chunks[i+1][j] = chunks[i][j]; 
            }
          }
          for(int j = 0; j < chunks.length; j++){
            PVector chunkPos = new PVector(0, 0, 0);
            chunkPos.x = playerChunkCoordinates.x - 2*chunkSize;
            chunkPos.z = playerChunkCoordinates.z + (j-1)*chunkSize;
            chunks[0][j] = new Chunk(chunkPos);
          }
          break;
        case "south":
          for(int i = 0; i < chunks.length; i++){
            for(int j = 1; j < chunks[0].length; j++){
               chunks[i][j-1] = chunks[i][j]; 
            }
            PVector chunkPos = new PVector(0, 0, 0);
            chunkPos.x = playerChunkCoordinates.x + (i-2)*chunkSize;
            chunkPos.z = playerChunkCoordinates.z + (chunks.length-2)*chunkSize;
            chunks[i][chunks.length-1] = new Chunk(chunkPos);
          }
          break;
          
        case "north":
          for(int i = 0; i < chunks.length; i++){
            for(int j = chunks.length-2; j >= 0; j--){
               chunks[i][j+1] = chunks[i][j]; 
            }
            PVector chunkPos = new PVector(0, 0, 0);
            chunkPos.x = playerChunkCoordinates.x + (i-2)*chunkSize;
            chunkPos.z = playerChunkCoordinates.z - chunkSize;
            chunks[i][0] = new Chunk(chunkPos);
          }
          break;
      }
  
}
  
  
void loadingScreen(){
  if(frameCount == 1){
    calculateChunks();  
    float initialTime = 1000;
    while(initialTime > 20){
      float now = millis();
      updateChunks();
      initialTime = millis() - now;
      vertecies-=2;
    }
    
    println("Rendering at " + vertecies + " vertecies.");
    
    calculateChunks();  
  }
}
  
void mouseWheel(MouseEvent event){
  if(event.getCount()<0){
    vertecies+=10;
  }else{
    if(vertecies-10>0)vertecies-=10;
  }
  println("Vertecies: " + vertecies);
  calculateChunks();
}

void keyPressed(){
  if(keyCode == ENTER){
    maintainSpeed = !maintainSpeed;
  }
}

void mousePressed() {
  stop = !stop;
}
