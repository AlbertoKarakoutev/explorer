PVector[] points = new PVector[10];
float[] colors = new float[10];
Player player;
float[] playerChunk = {1, 0};
Chunk[][] chunks;
int chunkNumber = 4;
float offset = 0;

Chunk targetChunk;

static int vertecies = 30;
static final float chunkSize = 20000;

void settings(){
  
 fullScreen(P3D);
 smooth(8); 
}

void setup() {
  
  noiseSeed(123);

  player = new Player();
  chunks = new Chunk[chunkNumber][chunkNumber];
  calculateChunks();
  
  for (int i = 0; i < colors.length; i++) {
    colors[i] = random(100, 150);
  }
}

void draw() {
 
  background(0, 255, 255, 200);
  perspective(PI/3, float(width)/float(height), (height/2) / tan((PI/3)/2)/10, 30000); 
  noStroke();
   //<>//
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
      //blendMode(REPLACE);
      chunks[i][j].display();
    }
  }
  
  
  fill(255,0,0);
  box(50);
  stroke(255, 0, 0);
  strokeWeight(4);
  line(-500/2, 0, 0, 500, 0, 0);
  stroke(0, 255, 0);
  line(0, -500, 0, 0, 500, 0);
  stroke(0, 0, 255);
  line(0, 0, -500, 0, 0, 500);
  
  //println("Radius: " + player.getRadius());
  //println("Location: " + player.getLocation());
  //println("Direction: " + player.getDirection());
  //println("Center chunk: " + chunks[1][1].getPosition());
  //println("Player chunk: " + player.getChunk()[0] + " " + player.getChunk()[1]);
  //println("Stopped: " + player.stop);
  //println(" ");
}

void calculateChunks(){
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
          } //<>//
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
  
    println(movementDirection);
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

void mousePressed() {
  player.stop = !player.stop;
}
