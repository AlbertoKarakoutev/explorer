import processing.sound.*;

PVector[] points = new PVector[10];
PVector sunLocation;
PVector sunLocationNormal;

float offset = 0;
float[] playerChunk = {1, 0};

int chunkNumber = 3;

Player player;

Menu pauseMenu;

OpenSimplex2F simplexNoise;

Chunk targetChunk;
Chunk[][] chunks;
ChunkThread thread;

boolean stop = true;
boolean maintainSpeed = false;
boolean updatingChunks = false;

static int vertecies = 200;
static float chunkSize = 20000;
static float scale = chunkSize/vertecies;
static final int textureSize = 200;

PShape bird;
PImage loading;
PImage grass;
PImage rock;
PImage snow;
PImage sand;
PImage sea;

SoundFile windSound;
SoundFile soundtrack;

boolean simulating = false;

void settings(){
 //fullScreen(P3D, 1);
 size(1000, 1000, P3D);
 smooth(8);  
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
  snow = loadImage("images/snow.jpg");
  sand = loadImage("images/sand.jpg");
  sea = loadImage("images/sea.jpg");
  grass.resize(textureSize, textureSize);
  rock.resize(textureSize, textureSize);
  snow.resize(textureSize, textureSize);
  sand.resize(textureSize, textureSize);
  sea.resize(textureSize, textureSize);
    
  bird = loadShape("models/Bird.obj");
  bird.scale(0.5);
    
  player = new Player();

  pauseMenu = new Menu();
  pauseMenu.addButton("Resume");
  pauseMenu.addButton("Settings");

  chunks = new Chunk[chunkNumber][chunkNumber];
  
  sunLocation = new PVector(500000, -1000000, 0);
  sunLocationNormal = sunLocation.copy().normalize();
  
  initializeChunks();
  
  windSound = new SoundFile(this, "sounds/wind.wav");
  soundtrack = new SoundFile(this, "sounds/soundtrack.wav");
  soundtrack.amp(0.5);
  //soundtrack.loop();
}

void draw() {
  //run();
  if(!simulating){
    pause();
  }else{
    run();
  }

}

void run(){
  pauseMenu.setShowing(false);
  background(168, 231, 252);
  perspective(map(player.getVelocity(), 0, player.getMaximumVelocity(), PI/2, PI/(1.98)), float(width)/float(height), (height/2) / tan((PI/3)/2)/10, chunkSize*100); 
  noStroke();
  
  if((int)playerChunk[0] != (int)player.getChunk()[0] || (int)playerChunk[1] != (int)player.getChunk()[1]){
    updateChunks();
 
  }
  playerChunk = player.getChunk();
  player.update();

  push();
  translate(sunLocation.x, sunLocation.y, sunLocation.z);
  fill(255, 255, 255);
  emissive(248, 252, 217);
  sphere(100000);
  pop();
  
  lightSpecular(248, 252, 217);
  //pointLight(215, 217, 184, player.getLocation().x, -2000, player.getLocation().z);
  directionalLight(255, 255, 255, sunLocationNormal.x, -sunLocationNormal.y, sunLocationNormal.z);
  
  ambientLight(100, 100, 100);
  
  for(int i = 0; i < chunks.length; i++){
    for(int j = 0; j < chunks[0].length; j++){
      chunks[i][j].display();
    }
  }
  
  //new Water(newChunks[0][0].getPosition()).display();
}

void pause(){
  pauseMenu.show();
  pauseMenu.setShowing(true);
}

void initializeChunks(){
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
      chunks[i][j] = new Chunk(chunkPos);
    }
  }
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
  
  ChunkThread[] threads = new ChunkThread[chunkNumber];
  
  switch(movementDirection){
    
    case "west":
      for(int i = 1; i < chunks.length; i++){
        for(int j = 0; j < chunks[0].length; j++){
           chunks[i-1][j] = chunks[i][j]; 
           if(i == chunks.length-1){
             PVector chunkPos = new PVector();
             chunkPos.x = playerChunkCoordinates.x + (i-2)*chunkSize;
             chunkPos.z = playerChunkCoordinates.z + (j-1)*chunkSize;
             
             threads[j] = new ChunkThread(chunkPos, i, j);
             threads[j].start();
           }
        }
      }
      
      break;
      
    case "east":
      for(int i = chunks.length-2; i >= 0; i--){
        for(int j = 0; j < chunks[0].length; j++){
           chunks[i+1][j] = chunks[i][j]; 
           if(i == 0){
             PVector chunkPos = new PVector();
             chunkPos.x = playerChunkCoordinates.x - 2*chunkSize;
             chunkPos.z = playerChunkCoordinates.z + (j-1)*chunkSize;
             
             threads[j] = new ChunkThread(chunkPos, i, j);
             threads[j].start();
           }
        }
      }
      break;
      
    case "south":
      for(int i = 0; i < chunks.length; i++){
        for(int j = 1; j < chunks[0].length; j++){
           chunks[i][j-1] = chunks[i][j]; 
        }
        PVector chunkPos = new PVector();
        chunkPos.x = playerChunkCoordinates.x + (i-2)*chunkSize;
        chunkPos.z = playerChunkCoordinates.z + (chunks.length-2)*chunkSize;
        
        threads[i] = new ChunkThread(chunkPos, i, chunks.length-1);
        threads[i].start();
      }
      break;
      
    case "north":
      for(int i = 0; i < chunks.length; i++){
        for(int j = chunks.length-2; j >= 0; j--){
           chunks[i][j+1] = chunks[i][j]; 
        }
        PVector chunkPos = new PVector();
        chunkPos.x = playerChunkCoordinates.x + (i-2)*chunkSize;
        chunkPos.z = playerChunkCoordinates.z - chunkSize;
        
        threads[i] = new ChunkThread(chunkPos, i, 0);
        threads[i].start();
      }
      break;
  } 
  
  for(ChunkThread thread : threads){
    try{
      thread.join(); 
    }catch(Exception e){
      e.printStackTrace(); 
    }
  }
  
  float timeTaken = millis() - now;
  println("This took " + timeTaken/1000 + " seconds.");
}


void keyPressed(){
  if(keyCode == ENTER){
    maintainSpeed = !maintainSpeed;
  }
}

void mousePressed() {
  if(pauseMenu.getShowing()){
    if(pauseMenu.getButton(0).mouseHovering()){
      stop = !stop;
      simulating = !simulating;
    }
  }else{
    stop = !stop;
    simulating = !simulating;
  }
}
