import processing.sound.*;

PVector[] points = new PVector[10];

float offset = 0;
float[] playerChunk = {1, 0};

int chunkNumber = 3;

Player player;

OpenSimplex2F simplexNoise;

Chunk targetChunk;
Chunk[][] chunks;
Chunk[][] newChunks;
ChunkThread thread;

boolean stop = true;
boolean maintainSpeed = false;
boolean updatingChunks = false;

static int vertecies = 300;
static float chunkSize = 40000;
static float scale = chunkSize/vertecies;

PShape bird;
PImage loading;
PImage grass;
PImage rock;
PImage sand;
PImage sea;

PShader landscape;

SoundFile windSound;
SoundFile soundtrack;

void settings(){
 //fullScreen(P3D, 1);
 size(1000, 1000, P3D);
 //smooth(8);  
}

void setup() {
  
  hint(ENABLE_STROKE_PURE);
  
  noiseSeed(125);
  
  noiseDetail(6);
  simplexNoise = new OpenSimplex2F(125);
  
  loading = loadImage("images/loading.png");
  loading.resize(width,height);
  background(loading);
  
  grass = loadImage("images/grass.jpg");
  rock = loadImage("images/rock.jpg");
  sand = loadImage("images/sand.jpg");
  sea = loadImage("images/sea.jpg");
  grass.resize(200, 200);
  rock.resize(200, 200);
  sand.resize(200, 200);
  sea.resize(200, 200);
    
  bird = loadShape("models/Bird.obj");
  bird.scale(0.3);
    
  player = new Player();
  chunks = new Chunk[chunkNumber][chunkNumber];
  newChunks = new Chunk[chunkNumber][chunkNumber];
  
  landscape = loadShader("landscape.glsl");
  landscape.set("resolution", float(width), float(height));  
  
  initialCalculations();
  
  windSound = new SoundFile(this, "sounds/wind.wav");
  soundtrack = new SoundFile(this, "sounds/soundtrack.wav");
  soundtrack.amp(0.5);
  //soundtrack.loop();
}

void draw() {
  
  //optimise();
  background(168, 231, 252);
  perspective(map(player.getSpeed(), 0, player.getMaximumSpeed(), PI/2, PI/(1.98)), float(width)/float(height), (height/2) / tan((PI/3)/2)/10, chunkSize*2); 
  noStroke();
  
  if((int)playerChunk[0] != (int)player.getChunk()[0] || (int)playerChunk[1] != (int)player.getChunk()[1]){
    //updatingChunks = true;
    updateChunks();
    //calculateChunks();
 
  }
  playerChunk = player.getChunk();
  player.update();
  
  shininess(50);
  lightSpecular(1, 1, 1);
  //pointLight(215, 217, 184, player.getLocation().x, -2000, player.getLocation().z);
  directionalLight(215, 217, 184, 0, 1, 0.5);
  
  if(!updatingChunks){ 
    for(int i = 0; i < chunks.length; i++){
      for(int j = 0; j < chunks[0].length; j++){
        newChunks[i][j].display();
      }
    }
  }else{
    for(int i = 0; i < chunks.length; i++){
      for(int j = 0; j < chunks[0].length; j++){
        chunks[i][j].display();
      }
    }
  }
  
  new Water(newChunks[0][0].getPosition()).display();
  //new Cloud(newChunks[0][0].getPosition()).display();
}

void initialCalculations(){
  scale = chunkSize/vertecies;
  PVector playerChunkCoordinates = new PVector();
  playerChunkCoordinates.x = player.getChunk()[0]*chunkSize;
  playerChunkCoordinates.y = 0;
  playerChunkCoordinates.z = player.getChunk()[1]*chunkSize;
  for(int i = 0; i < chunks.length; i++){
    for(int j = 0; j < chunks[0].length; j++){
      PVector chunkPos = new PVector(0, 0, 0);
      chunkPos.x = playerChunkCoordinates.x + (i-(1+floor(chunks.length/2)))*chunkSize;
      chunkPos.z = playerChunkCoordinates.z + (j-floor(chunks.length/2))*chunkSize;
      newChunks[i][j] = new Chunk(chunkPos);
      chunks[i][j] = new Chunk(chunkPos);
    }
  }
}

void calculateChunks(){
  scale = chunkSize/vertecies;
  PVector playerChunkCoordinates = new PVector();
  playerChunkCoordinates.x = player.getChunk()[0]*chunkSize;
  playerChunkCoordinates.y = 0;
  playerChunkCoordinates.z = player.getChunk()[1]*chunkSize;
  
  thread = new ChunkThread(playerChunkCoordinates); //<>//
  thread.start();
}


void updateChunks(){
  
  float now = millis();
  PVector playerChunkCoordinates = new PVector();
  playerChunkCoordinates.x = player.getChunk()[0]*chunkSize;
  playerChunkCoordinates.y = 0;
  playerChunkCoordinates.z = player.getChunk()[1]*chunkSize;
  String movementDirection = "west";
  if(playerChunk[0] < player.getChunk()[0])movementDirection = "west";
  if(playerChunk[0] > player.getChunk()[0])movementDirection = "east";
  if(playerChunk[1] < player.getChunk()[1])movementDirection = "south";
  if(playerChunk[1] > player.getChunk()[1])movementDirection = "north";
  PVector chunkPos = new PVector(0, 0, 0);
  switch(movementDirection){
    
    case "west":
      for(int i = 1; i < chunks.length; i++){
        for(int j = 0; j < chunks[0].length; j++){
           newChunks[i-1][j] = chunks[i][j]; 
           if(i == chunks.length-1){
             
             chunkPos.x = playerChunkCoordinates.x + (i-2)*chunkSize;
             chunkPos.z = playerChunkCoordinates.z + (j-1)*chunkSize;
             newChunks[i][j] = new Chunk(chunkPos);
           }
        }
      }
      break;
      
    case "east":
      for(int i = chunks.length-2; i >= 0; i--){
        
        for(int j = 0; j < chunks[0].length; j++){
           newChunks[i+1][j] = chunks[i][j]; 
           if(i == 0){
             chunkPos.x = playerChunkCoordinates.x - 2*chunkSize;
             chunkPos.z = playerChunkCoordinates.z + (j-1)*chunkSize;
             newChunks[i][j] = new Chunk(chunkPos);
           }
        }
      }
      break;
      
    case "south":
      for(int i = 0; i < chunks.length; i++){
        for(int j = 1; j < chunks[0].length; j++){
           newChunks[i][j-1] = chunks[i][j]; 
        }
        chunkPos.x = playerChunkCoordinates.x + (i-2)*chunkSize;
        chunkPos.z = playerChunkCoordinates.z + (chunks.length-2)*chunkSize;
        newChunks[i][chunks.length-1] = new Chunk(chunkPos);
      }
      break;
      
    case "north":
      for(int i = 0; i < chunks.length; i++){
        for(int j = chunks.length-2; j >= 0; j--){
           newChunks[i][j+1] = chunks[i][j]; 
        }
        chunkPos.x = playerChunkCoordinates.x + (i-2)*chunkSize;
        chunkPos.z = playerChunkCoordinates.z - chunkSize;
        newChunks[i][0] = new Chunk(chunkPos);
      }
      break;
  } 
  
    
  for(int i = 0; i < newChunks.length; i++){
    arrayCopy(newChunks[i], chunks[i]);
  }
  //delay(3000);
  updatingChunks = false;
  
  float timeTaken = millis() - now;
  println("This took " + timeTaken/1000 + " seconds.");
}
  
  
void optimise(){
  if(frameCount == 1){
    calculateChunks();  
    float initialTime = 1000;
    while(initialTime > 30 && vertecies > 20){
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
