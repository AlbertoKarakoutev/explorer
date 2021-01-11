PVector[] points = new PVector[10];
float[] colors = new float[10];
Player player;
float[] playerChunk = {1, 0};
Chunk[][] chunks;
int chunkNumber = 4;

Chunk targetChunk;

static final float chunkSize = 1000;

//coloring not right 
//slight lag when loading new chunks

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
 
  background(50);
  perspective(PI/3, float(width)/float(height), (height/2) / tan((PI/3)/2)/10, 30000); 
  noStroke();
   //<>//
  if((int)playerChunk[0] != (int)player.getChunk()[0] || (int)playerChunk[1] != (int)player.getChunk()[1]){
    updateChunks();
    //calculateChunks();
  }
  playerChunk = player.getChunk();
  player.update();
  
  lights();
  
  for(int i = 0; i < chunks.length; i++){
    for(int j = 0; j < chunks[0].length; j++){
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
          for(int j = 0; j < chunks.length; j++){
            PVector chunkPos = new PVector(0, 0, 0); //<>//
            chunkPos.x = playerChunkCoordinates.x + (chunks.length-3)*chunkSize;
            chunkPos.z = playerChunkCoordinates.z + (j-1)*chunkSize;
            chunks[chunks.length-1][j] = new Chunk(chunkPos);
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
          }
          for(int i = 0; i < chunks.length; i++){
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
          }
          for(int i = 0; i < chunks.length; i++){
            PVector chunkPos = new PVector(0, 0, 0);
            chunkPos.x = playerChunkCoordinates.x + (i-2)*chunkSize;
            chunkPos.z = playerChunkCoordinates.z - chunkSize;
            chunks[i][0] = new Chunk(chunkPos);
          }
          break;
      }
  
    //println(movementDirection);
}
  
void mouseWheel(MouseEvent event){
  if(event.getCount()<0){
    player.radius-=50;
  }else{
    player.radius+=50;
  }
}

void keyPressed(){
 if(key == '1'){
  targetChunk = chunks[0][0];
  println("Target is [0][0]");
 }
 if(key == '2'){
  targetChunk = chunks[0][1];
  println("Target is [0][1]");
 }
 if(key == '3'){
  targetChunk = chunks[0][2];
  println("Target is [0][2]");
 }
 if(key == '4'){
  targetChunk = chunks[0][3];
  println("Target is [0][3]");
 }
 if(key == '5'){
  targetChunk = chunks[1][0];
  println("Target is [1][0]");
 }
 if(key == '6'){
  targetChunk = chunks[1][1];
  println("Target is [1][1]");
 }
 if(key == '7'){
  targetChunk = chunks[1][2];
  println("Target is [1][2]");
 }
 if(key == '8'){
  targetChunk = chunks[1][3];
  println("Target is [1][3]");
 }
 if(key == '9'){
  targetChunk = chunks[2][0];
  println("Target is [2][0]");
 }
 if(key == '0'){
  targetChunk = chunks[2][1];
  println("Target is [2][1]");
 }
 if(key == 'q'){
  targetChunk.getPosition().y+=1; 
  println(targetChunk.getPosition().y); 
 }
 if(key == 'e'){
  targetChunk.getPosition().y-=1; 
  println(targetChunk.getPosition().y); 
 }
}

void mousePressed() {
  player.stop = !player.stop;
}
