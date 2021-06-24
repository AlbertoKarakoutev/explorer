import processing.sound.*; //<>//

PVector[] points = new PVector[10];
PVector sunLocation;
PVector sunLocationNormal;
float sunFI = 3;

float offset = 0;
float[] playerChunk = {1, 0};

int chunkNumber = 3;

Player player;

Menu menu;
MenuActions ma;

OpenSimplex2F simplexNoise; //<>//

Chunk[][] chunks;

static boolean stop = true;

static boolean areBirdsVisible = false;
static boolean isWaterVisible = false;
static boolean areDetailsVisible = true;
static boolean isGravityActive = true;

static int lowestPoint = -5;

static int vertecies = 100;
static float chunkSize = 40000;
static float scale = chunkSize/vertecies;
static final int textureSize = 200;

PShape bird;
PImage grass; 
PImage rock;
PImage snow;
PImage sand;
PImage sea;

SoundFile windSound;
SoundFile soundtrack;

boolean simulating = false;

void settings(){
 size(1000, 1000, P3D);
}

void setup() {
  /*Setup textures*/
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
      
  noiseSeed(125);
  noiseDetail(6);
  simplexNoise = new OpenSimplex2F(125);
  
  player = new Player();

  /*Setup menu*/
  menu = new Menu();
  menu.addButton("Resume");
  menu.addButton("Settings");
  menu.addButton("Exit");
  ma = new MenuActions();

  chunks = new Chunk[chunkNumber][chunkNumber];
  
  sunLocation = new PVector(1000000, -1000000, 0);
  sunLocationNormal = sunLocation.copy().normalize();
  
  initializeChunks();
  
  /*Setup sound files*/
  windSound = new SoundFile(this, "sounds/wind.wav");
  soundtrack = new SoundFile(this, "sounds/soundtrack.wav");
  soundtrack.amp(0.5);
  //soundtrack.loop();
}

void draw() {
  if(!simulating){
    pause();
  }else{
    run();
  }
}

void run(){
  menu.setShowing(false);
    
  updateBackground();

  perspective(map(player.getVelocity(), 0, player.getMaximumVelocity(), PI/2, PI/(1.98)), float(width)/float(height), 5, chunkSize*100); 
  noStroke();
  
  /*Update chunks if a player passes a chunk border*/
  if((int)playerChunk[0] != (int)player.getChunk()[0] || (int)playerChunk[1] != (int)player.getChunk()[1]){
    updateChunks();
  }

  //displayLaunchTrack();

  playerChunk = player.getChunk();
  player.update();

  updateSun();

  /*Display the chunks*/
  for(int i = 0; i < chunks.length; i++){
    for(int j = 0; j < chunks[0].length; j++){
      chunks[i][j].display();
    }
  }
  
  if(isWaterVisible)new Water(chunks[0][0].getPosition()).display();
}

void pause(){
  menu.show();
  menu.setShowing(true);
}

/*
  Initialization for the 9 chunks around the player, while he is always in the center chunk.
*/
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

/*
  Determine player movement direction and load 3 new chunks in front by using multithreading. 
  Remove the 3 chunks behind the player.
*/
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

/*Handle the sun's location and lighting*/
void updateSun(){
  sunFI += 0.001;
  sunFI = sunFI%TWO_PI;
  sunLocation.x = player.getLocation().x + 1000000 * cos(0) * sin(sunFI);
  sunLocation.z = player.getLocation().z + 1000000 * sin(0) * sin(sunFI);
  sunLocation.y = player.getLocation().y + 1000000 * cos(sunFI);
  sunLocationNormal = sunLocation.copy().normalize();

  push();
    translate(sunLocation.x, sunLocation.y, sunLocation.z);
    fill(255, 255, 255);
    emissive(248, 252, 217);
    shapeMode(CENTER);
    sphere(100000);
  pop();

  directionalLight(255, 255, 255, sunLocationNormal.x, -sunLocationNormal.y, sunLocationNormal.z);
  
  ambientLight(50, 50, 50);
  
}

/*Set the sky colors*/
void updateBackground(){
   
  float bgRed = map(sunLocation.y, 450000, -200000, 0, 168);
  float bgGreen = map(sunLocation.y, 400000, -200000, 0, 231);
  float bgBlue = map(sunLocation.y, 400000, -200000, 0, 252);
  bgRed = limit(bgRed, 168);
  bgGreen = limit(bgGreen, 231);
  bgBlue = limit(bgBlue, 252);
  background(bgRed, bgGreen, bgBlue);
  
}

float limit(float bgColor, float max){
  return (bgColor<max)?bgColor:max;
}

/*Handle menu actions*/ 
void mousePressed() {
  if(menu.getShowing()){
    
    if(menu.mouseHovering("Resume", true)){
      ma.resume();
    }else if(menu.mouseHovering("Settings", true)){
      ma.settings();
    }else if(menu.mouseHovering("Save", true)){
      ma.save();
    }else if(menu.mouseHovering("Exit", true)){
      ma.exitSimulator();
    }else if(menu.mouseHovering("Birds", false)){
      ma.check("Birds");
    }else if(menu.mouseHovering("Water", false)){
      ma.check("Water");
    }else if(menu.mouseHovering("Terrain Details", false)){
      ma.check("Terrain Details");
    }else if(menu.mouseHovering("Gravity", false)){
      ma.check("Gravity");
    }
  }
}

void keyPressed() {
  if (key == ESC) {
    key = 0;
    if(menu.getShowing()){
        ma.resume();
        return;
    }
    stop = !stop;
    simulating = !simulating;
  }
}

void mouseWheel(MouseEvent event){
  if(event.getCount()<0){
    player.radius -= 10;
  }else{
    player.radius += 10;
  }
}


// void displayLaunchTrack(){
//   push();

//   translate(chunkSize/4, -chunkSize/10, chunkSize/2);
//   shapeMode(CENTER);
//   fill(170);
//   strokeWeight(10);
//   stroke(0);
  
//   shininess(20);
//   specular(1, 1, 1);
//   box(0.8*chunkSize, chunkSize/10, chunkSize*0.1);

//   pop();
// }
