import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.sound.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class explorer extends PApplet {



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

public void settings(){
 //fullScreen(P3D, 1);
 size(1000, 1000, P3D);
 smooth(8);  
}

public void setup() {
  
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
  bird.scale(0.5f);
    
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
  soundtrack.amp(0.5f);
  //soundtrack.loop();
}

public void draw() {
  //run();
  if(!simulating){
    pause();
  }else{
    run();
  }

}

public void run(){
  //optimise();
  background(168, 231, 252);
  perspective(map(player.getVelocity(), 0, player.getMaximumVelocity(), PI/2, PI/(1.98f)), PApplet.parseFloat(width)/PApplet.parseFloat(height), (height/2) / tan((PI/3)/2)/10, chunkSize*100); 
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

public void pause(){
  pauseMenu.show();
}

public void initializeChunks(){
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

public void updateChunks(){
  
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


public void keyPressed(){
  if(keyCode == ENTER){
    maintainSpeed = !maintainSpeed;
  }
}

public void mousePressed() {
  if(!simulating){
    if(pauseMenu.getButton(0).mouseHovering()){
      stop = !stop;
      simulating = !simulating;
    }
  }else{
    stop = !stop;
    simulating = !simulating;
  }
}
class Bird{
 
  PVector position;
  PVector velocity;
  PVector acceleration;
  
  float maxForce = 1;
  float maxSpeed = 1;
  
  Chunk chunk;
  
  public Bird(Chunk chunk){
    position = new PVector(random(chunkSize/2), random(-chunkSize/0.9f, -chunkSize), random(chunkSize/2)); 
    velocity = PVector.random3D();
    velocity.setMag(random(20, 40));
    this.chunk = chunk;
    acceleration = new PVector();
    
  }
  
  
  public void display(){
    update();

    float theta = atan(velocity.z/velocity.x);
    float fi = atan(velocity.y/velocity.x);
    if(velocity.x>=0)theta += PI/2; fi += PI/2;
    if(velocity.x<0)theta += PI*1.5f; fi += PI*1.5f;
    
    pushMatrix();
    translate(position.x, position.y, position.z);
    rotateY(-theta);
    shape(bird);
    popMatrix();
  }
  
  
  public void avoid() {
    
    PVector steering = new PVector();
    
    float db = dist(position.x, position.y, position.z, position.x, 0, position.z);
    float dt = dist(position.x, position.y, position.z, position.x, -chunkSize, position.z);
    float dl = dist(position.x, position.y, position.z, 0, position.y, position.z);
    float dr = dist(position.x, position.y, position.z, chunkSize, position.y, position.z);
    float df = dist(position.x, position.y, position.z, position.x, position.y, 0);
    float dba = dist(position.x, position.y, position.z, position.x, position.y, chunkSize);

    float min = 100;
 
    boolean headingForCollision = db<=min||dt<=min||dr<=min||dl<=min||df<=min||dba<=min;
    if(headingForCollision){
      float dist1 = min(db, dt, dl);
      float dist2 = min(dr, df, dba);
      float dist = min(dist1, dist2);
      for(PVector ray : rays()){
        
        if(isInside(PVector.add(position, ray), min)){
          ray.setMag(map(dist, 100, 0, 0, 3));
          acceleration.add(ray);
          break;
        }
      }
    }

    PVector birdVertex = new PVector();
    birdVertex.x = (position.x>0) ? round(abs((position.x%chunkSize)/scale)) : vertecies - round(abs((position.x%chunkSize)/scale));
    birdVertex.y = position.y;
    birdVertex.z = (position.z>0) ? round(abs((position.z%chunkSize)/scale)) : vertecies - round(abs((position.z%chunkSize)/scale));
    
    float terrainHeightAtBirdLocation = chunk.getVertex((int)birdVertex.x, (int)birdVertex.z).y;
    if(position.y > terrainHeightAtBirdLocation - 200 ){
      velocity.mult(-0.5f);
      position.y-=0.2f;
    }
  }
  
  
  public void alignment(Bird[] birds){
    float viewDistance = chunkSize/6;
    float total = 0;
    PVector direction = new PVector();
    for(Bird bird : birds){
      float d = dist(position.x, position.y, position.z, bird.position.x, bird.position.y, bird.position.z);
      if(bird != this && d < viewDistance){
        direction.add(bird.velocity);
        total++;
      }
    }
    if(total > 0){
      direction.div(total);
      direction.sub(velocity);
      direction.setMag(maxSpeed*2);
      direction.limit(maxForce);
    }
    acceleration.add(direction.mult(1));
  }
  
  
  public void cohesion(Bird[] birds){
    float viewDistance = chunkSize/5;
    float total = 0;
    PVector direction = new PVector();
    for(Bird bird : birds){
      float d = dist(position.x, position.y, position.z, bird.position.x, bird.position.y, bird.position.z);
      if(bird != this && d < viewDistance){
        direction.add(bird.position);
        total++;
      }
    }
    if(total > 0){
      direction.div(total);
      direction.sub(velocity);
      //direction.setMag(maxSpeed);
      direction.sub(position);
      direction.limit(maxForce);
    }
    acceleration.add(direction.mult(1));
  }
  
  
  public void separation(Bird[] birds){
    float viewDistance = chunkSize/20;
    float total = 0;
    PVector direction = new PVector();
    for(Bird bird : birds){
      float d = dist(position.x, position.y, position.z, bird.position.x, bird.position.y, bird.position.z);
      if(bird != this && d < viewDistance){
        PVector diff = PVector.sub(position, bird.position);
        //diff.div(viewDistance);
        direction.add(diff);
        total++;
      }
    }
    if(total > 0){
      direction.div(total);
      //direction.setMag(maxSpeed);
      direction.sub(velocity);
      direction.limit(maxForce);
    }
    acceleration.add(direction.mult(1));
  }
  
  public boolean isInside(PVector vector, float offset){
    if(vector.x <= offset || vector.x >= chunkSize-offset)return false;
    if(vector.y >= -offset || vector.y <= -chunkSize+offset)return false;
    if(vector.z <= offset || vector.z >= chunkSize-offset)return false;
    return true;
  }
    
  public PVector[] rays(){
    
    int numViewDirections = 25;
    PVector[] directions = new PVector[numViewDirections];

    float goldenRatio = (1 + sqrt(5)) / 2;
    float angleIncrement = PI * 2 * goldenRatio;
    
    float mult = 210;
    
    for (int i = 0; i < numViewDirections; i++) {
        float t = (float) i / numViewDirections;
        float fi = acos (1 - 2 * t);
        float theta = angleIncrement * i;

        float x = sin (fi) * cos (theta);
        float y = sin (fi) * sin (theta);
        float z = cos (fi);
        directions[i] = new PVector(x*mult, y*mult, z*mult);
    }
    return directions;
  }
  
  public void update(){
    float chance = random(1);
    if(chance > 0.8f){
      //acceleration = PVector.random3
    }
    velocity.limit(4);
    position.add(velocity);
    velocity.add(acceleration);
  }
  
}
class Button{

    PImage buttonTexture;
    String function;
    PVector location;
    PVector size;

    String name;

    public Button(String name, PVector size){
        this.name = name;
        this.size = size;
    }

    public void show(Menu menu, PVector location){
        this.location = location;

        PGraphics menuPanel = menu.getPanel();
        menuPanel.beginDraw();

        menuPanel.fill(coloring());
        menuPanel.rect(location.x, location.y, size.x, size.y);

        menuPanel.fill(0);
        menuPanel.textSize(50);
        menuPanel.text(name, location.x+(size.x-menuPanel.textWidth(name))/2, location.y+(size.y-10));

        menuPanel.endDraw();
    }

    public boolean mouseHovering(){
        return mouseX > location.x && mouseX < location.x+size.x && mouseY > location.y && mouseY < location.y+size.y;
    }

    public int coloring(){
        if(mouseHovering()){
            return color(100, 100, 100);
        }else{
            return color(255, 255, 255);
        }
    }

}
class Chunk{
  
  PVector position;
  PVector[][] vecs = new PVector[vertecies+1][vertecies+1];
  
  float birdsSpawnPercentage;
  float birdsSpawnPercentageMinimum;
  
  final float CHUNK_MIN = chunkSize/2;
  final float SEA_LEVEL = 0;
  final float SAND_LEVEL = SEA_LEVEL+1000;
  final float SAND_GRASS_LEVEL = -chunkSize/20;
  final float GRASS_LEVEL = -chunkSize/5;
  final float GRASS_ROCK_LEVEL = -chunkSize/3;
  final float ROCK_LEVEL = -chunkSize/2;
  final float CHUNK_MAX = -chunkSize;
  
  TerrainTransition sandToGrass;
  TerrainTransition grassToRock;
  TerrainTransition rockToSnow;
  
  PShape chunkShape = createShape(GROUP);
  
  PShape sandShape = createShape();
  PShape sandGrassShape = createShape();
  PShape grassShape = createShape();
  PShape grassRockShape = createShape();
  PShape rockShape = createShape();
  PShape rockToSnowShape = createShape();
  
  Bird[] flock;
  Cloud cloud;
  
  public Chunk(PVector position){
    this.position = position.copy();
    birdsSpawnPercentage = random(1);
    birdsSpawnPercentageMinimum = 0;
    if(birdsSpawnPercentage>birdsSpawnPercentageMinimum){
      flock = new Bird[40];
      for(int i = 0; i < flock.length; i++){
        flock[i] = new Bird(this);
      }
    }
    
    //cloud = new Cloud(position);
    
    float now = millis();
    //20-30 ms for this segment
    for(int z = 0; z <= vertecies; z++){
      for(int x = 0; x <= vertecies; x++){
        vecs[x][z] = new PVector(x*scale, calculateHeight(x, z), z*scale);
      }
    }
    
    
    sandToGrass = new TerrainTransition(SAND_LEVEL, SAND_GRASS_LEVEL, 10, vecs, sand, grass);
    grassToRock = new TerrainTransition(GRASS_LEVEL, GRASS_ROCK_LEVEL, 5, vecs, grass, rock);
    rockToSnow = new TerrainTransition(ROCK_LEVEL, CHUNK_MAX, 15, vecs, rock, snow);
    
    //40-50 ms for this segment
    sandGrassShape = sandToGrass.getBlendedShape();
    grassRockShape = grassToRock.getBlendedShape();
    rockToSnowShape = rockToSnow.getBlendedShape();
    
    sandShape.setTexture(sand);
    grassShape.setTexture(grass);
    rockShape.setTexture(rock);
    
    textureWrap(REPEAT);
    textureMode(NORMAL);
    
    sandShape.beginShape(QUADS);
    grassShape.beginShape(QUADS);
    rockShape.beginShape(QUADS);
    
  
    //20-30 ms for this segment
    for(int z = 0; z < vertecies; z++){
      for(int x = 0; x < vertecies; x++){
        addSurface(x, z);
      }
    }
    
    sandShape.endShape();
    grassShape.endShape();
    rockShape.endShape();
    
    chunkShape.addChild(sandShape);
    chunkShape.addChild(sandGrassShape);
    chunkShape.addChild(grassShape);
    chunkShape.addChild(grassRockShape);
    chunkShape.addChild(rockShape);
    chunkShape.addChild(rockToSnowShape);
     
    //println(millis()-now);
}


  public void addSurface(int x, int z){
    PShape thisShape = null;
    
    PVector n = PVector.sub(vecs[x][z], vecs[x+1][z], null).cross(PVector.sub(vecs[x][z+1], vecs[x+1][z], null));
    n.normalize();
    
    if(vecs[x][z].y >= SAND_LEVEL)thisShape = sandShape;
    if(vecs[x][z].y <= SAND_GRASS_LEVEL && vecs[x][z].y > GRASS_LEVEL)thisShape = grassShape;
    if(vecs[x][z].y <= GRASS_ROCK_LEVEL && vecs[x][z].y > ROCK_LEVEL)thisShape = rockShape;
    
    if(thisShape == null)return;
    
    float textureScale = chunkSize/100;
    
    thisShape.noStroke();
    
    thisShape.normal(n.x, -n.y, n.z);
    
    thisShape.vertex(vecs[x][z].x, vecs[x][z].y, vecs[x][z].z, (x*scale)/textureScale, (z*scale)/textureScale);
    thisShape.vertex(vecs[x+1][z].x, vecs[x+1][z].y, vecs[x+1][z].z, ((x+1)*scale)/textureScale, (z*scale)/textureScale);
    thisShape.vertex(vecs[x+1][z+1].x, vecs[x+1][z+1].y, vecs[x+1][z+1].z, ((x+1)*scale)/textureScale, ((z+1)*scale)/textureScale);
    thisShape.vertex(vecs[x][z+1].x, vecs[x][z+1].y, vecs[x][z+1].z, (x*scale)/textureScale, ((z+1)*scale)/textureScale);
    
  } 
  
  public float calculateHeight(float xInitial, float zInitial){
    float x = (this.position.x + xInitial*scale)/(chunkSize*3);
    float z = (this.position.z + zInitial*scale)/(chunkSize*3);
    
    float levelNoise = (float)simplexNoise.noise2(x*2,z*2);
    //float levelMultiplier = map(exp(5*(levelNoise-0.9)), 0, 1, 0, 1.2);
    float levelHeight = map(levelNoise, -10, 2, CHUNK_MIN, CHUNK_MAX) * exp(1*(levelNoise-0.9f));
    
    float detailNoise = noise(x*25,z*25);
    //float detailMultiplier = map(levelNoise, 1/7, 1, 0.1, 1);
    float detailHeight = map(detailNoise, -2, 1, CHUNK_MIN, CHUNK_MAX) * exp(1.5f*(levelNoise-0.9f));
    
    return (levelHeight + detailHeight)/2;
  }
  
  
  public void display(){
    //Goal is < 0.02s
    shapeMode(CORNER);
    pushMatrix();
    translate(position.x, position.y, position.z);
    pushStyle();
    ambient(255, 255, 255);
    shape(chunkShape);
    popStyle();
    //cloud.display();
    if(birdsSpawnPercentage>birdsSpawnPercentageMinimum)displayBirds();  
    popMatrix();
    
  }
  
  public void displayBirds(){
    for(int i = 0; i < flock.length; i++){
      flock[i].acceleration.set(0, 0, 0);
      flock[i].avoid();
      flock[i].velocity.setMag(10);
      flock[i].alignment(flock);
      flock[i].cohesion(flock);
      flock[i].separation(flock);
      flock[i].display();
    }
  }
  
  public PVector getVertex(int x, int y){
    return new PVector(vecs[x][y].x, vecs[x][y].y, vecs[x][y].z);
  }
  
  public PVector getPosition(){
    return this.position;
  }
  
}
class ChunkThread extends Thread{
 
  PVector chunkPos;
  
  int row, col;
  
  
  public ChunkThread(PVector chunkPos, int row, int col){
    this.chunkPos = chunkPos;
    this.row = row;
    this.col = col;
  }
  
  public void run(){
    chunks[row][col] = new Chunk(chunkPos); //<>//
  }
  
}
class Cloud{
  PVector position;
  
  int gridCells = 10;
  float scale = chunkSize/10;
  float cloudHeight = 500;
  
  PVector[][] points;
  
  public Cloud(PVector position){
   this.position = position; 
   points = new PVector[gridCells][gridCells];
   for(int row = 0; row < gridCells; row++){
      for(int col = 0; col < gridCells; col++){
        float rowRandom = random(row*scale, (row+1)*scale);   
        float colRandom = random(col*scale, (col+1)*scale);
        float heightRandom = random(-chunkSize-cloudHeight, -chunkSize);
        
        points[row][col] = new PVector(rowRandom, heightRandom, colRandom);
      }
    }
  }
  
  public void display(){
    for(int row = 0; row < gridCells; row++){
      for(int col = 0; col < gridCells; col++){
        pushStyle();
        stroke(255, 255, 255, 200);
        strokeWeight(16);
        point(points[row][col].x, points[row][col].y, points[row][col].z);
        popStyle();
        
      }
    }
  }
  
}
class Menu{

    PGraphics panel;

    boolean showing = false;

    ArrayList<Button> buttons;

    PVector buttonSize = new PVector (400, 50);
    int buttonLocationX = width/2-200;

    public Menu(){
        buttons = new ArrayList<Button>();
        
    }

    public void show(){
        panel = createGraphics(width, height);
        panel.beginDraw();
        panel.fill(0, 0, 0);
        panel.rect(0, 0, width, height);
        panel.endDraw();

        for(int i = 0; i < buttons.size(); i++){
            int buttonLocationY = (i+1)*(height/(buttons.size()+1));
            buttons.get(i).show(this, new PVector(buttonLocationX, buttonLocationY));
        }
        
        background(panel); 
    }

    public void addButton(String name){
        buttons.add(new Button(name, buttonSize));
    }
    public Button getButton(int index){
        return buttons.get(index);
    }

    public PGraphics getPanel(){
        return this.panel;
    }

}
class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  float lifespan;

  Particle(PVector l) {
    acc = new PVector(0, 0);
    float vx = randomGaussian()*0.2f;
    float vz = randomGaussian()*0.2f;
    vel = new PVector(vx, 0, vz);
    loc = l.copy();
    lifespan = random(50, 300);
  }

  public void run() {
    update();
    render();
  }
  
  public void update() {
    vel.add(acc);
    loc.add(vel);
    lifespan -= random(1.5f, 3.5f);
    acc.mult(0);
  }

  public void render() {
     pushStyle();
     stroke(100);
     strokeWeight(6);
     point(loc.x, loc.y, loc.z);
     popStyle();
  }

  public boolean isDead() {
    if (lifespan <= 0.0f) {
      return true;
    } else {
      return false;
    }
  }
}
class ParticleSystem {

  ArrayList<Particle> particles;
  PVector origin;    

  ParticleSystem(int num, PVector v) {
    particles = new ArrayList<Particle>();
    origin = v.copy();         
    for (int i = 0; i < num; i++) {
      particles.add(new Particle(origin));
    }
  }

  public void run(PVector newLocation) {
    origin = newLocation.copy();
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  public void applyForce(PVector dir) {
    for (Particle p : particles) {
      p.loc.add(dir);
    }
  }  

  public void addParticle() {
    particles.add(new Particle(origin));
  }
}
class Player{
 
  PVector cameraLocation;
  PVector location;
  PVector velocity;
  PVector weight;
  PVector playerVertexFloat;
  
  float viewFactor = 10;
  float radius = 3000/viewFactor;
  //float speedMaximum = (viewFactor > 2) ? 15/(viewFactor-2) : 15/viewFactor;
  float acceleration = 0;
  float maximumVelocity = 250;
  float theta;
  float fi;

  PShape airplane;
  
  ParticleSystem ps;
  ParticleSystem collisionExplosion;
  
  public Player(){
    
      airplane = loadShape("models/Plane.obj");
      playerVertexFloat = new PVector();
      airplane.scale(4/viewFactor);
      cameraLocation = new PVector(0,0,0);
      location = new PVector(chunkSize/2, -10000, chunkSize/2);
      velocity = new PVector();
      weight = new PVector(0, 1, 0);

      PVector psLocation = location.copy();
      psLocation.y +=10;
      ps = new ParticleSystem(200, psLocation);
      
  }
  
  
  public void update(){
   look();
   move();
  }
  
  
  public void look(){
      
      cameraLocation.x = location.x + radius * cos(theta) * sin(-fi);
      cameraLocation.z = location.z + radius * sin(theta) * sin(-fi);
      cameraLocation.y = location.y + radius * cos(-fi);
      
    pushMatrix();
    translate(location.x, location.y, location.z);
    //Rotate model in the proper direction
    rotateY(-theta);
    rotateZ(fi);
    rotateY(map(mouseX, 0, width, -1.5f, 1.5f));
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
     float damp = 0.05f;
     float mouseXCentered = map(mouseX, 0, width, -damp, damp);
     float mouseYCentered = map(mouseY, 0, height, -damp, damp);
     theta += mouseXCentered;
     if(theta > TWO_PI || theta < -TWO_PI)theta=0;
     rotateFI(mouseYCentered);
    }
    beginCamera();
    if(frameCount == 1){
      fi=2.4f;
    }
    camera(cameraLocation.x, cameraLocation.y, cameraLocation.z, location.x, location.y, location.z, 0, 1, 0);  
    
    endCamera();
  }




  public void move(){

    movementEffects();
    
    if(acceleration > maximumVelocity)acceleration = maximumVelocity;

    if(!stop){
      if(keyPressed){
        if (key == 'w') {
          acceleration+=1;
        }else{
          acceleration = (acceleration >= 0) ? acceleration-1 : 0;
        }
        if (keyCode == SHIFT) {
          maximumVelocity += 0.1f;
        }
        if(key == 'r'){
          location = new PVector(0, -5000, 0);
          initializeChunks();
        }
      }else{
        acceleration = (acceleration >= 0) ? acceleration-1 : 0;
      }
      
      velocity.x = acceleration * -cos(theta) * sin(-fi);
      velocity.z = acceleration * -sin(theta) * sin(-fi);
      velocity.y = acceleration * -cos(-fi);

      weight.mult(map(velocity.mag(), 0, maximumVelocity, maximumVelocity, 0));
      if(!isUnderground(PVector.add(velocity, weight).add(location).y))velocity.add(weight);

      if(velocity.mag() < 1){
        velocity.setMag(0);
      }
      
      if(isUnderground(location.y+velocity.y/10)){
        location.x+=velocity.x/10;
        location.z+=velocity.z/10;
        if(location.y+velocity.y < location.y)location.add(velocity.copy().div(10));
      }else{
        location.add(velocity.copy().div(10));
      }
      weight.set(0, 1, 0);
    }
  }
  
  
  public boolean isUnderground(float playerHeight){
    playerVertexFloat.x = (location.x>=0) ? (location.x%chunkSize)/scale : vertecies - (abs(location.x)%chunkSize)/scale;
    playerVertexFloat.z = (location.z>=0) ? (location.z%chunkSize)/scale : vertecies - (abs(location.z)%chunkSize)/scale;
    float terrainHeightAtPlayerLocation = chunks[floor(chunks.length/2)][floor(chunks.length/2)].calculateHeight(playerVertexFloat.x, playerVertexFloat.z);
    if(playerHeight > terrainHeightAtPlayerLocation){
      location.y = lerp(location.y, terrainHeightAtPlayerLocation, 0.3f);
      return true;
    }
    return false;
  }
    
  public void displayInformation(){
    textSize(200/viewFactor);
    noLights();
    pushStyle();
    //fill(255);
    rotateX(-HALF_PI);
    rotateZ(-HALF_PI);
    text((int)location.x + ", " + ((int)-location.y) + ", " + (int)location.z, -1000/viewFactor, -400/viewFactor, 0);
    text("Speed: " + round(velocity.mag()) + " km/h", -300, -200, 0);
    text("Maximum speed: " + round(maximumVelocity) + " km/h", -300, -240, 0);
    popStyle();
  }

  public void rotateFI(float amount){
    if(fi<3 && fi > 0.1f){
      fi += amount;
    }else{
      if(fi + amount < 3 && fi + amount > 0.1f){
        fi += amount;
      }
    }
    if(fi < 0.1f) fi=0.1f;
    if(fi > 3) fi=3;
  }

  public void movementEffects(){
    
    PVector wind = cameraLocation.copy();
    PVector psLocation = location.copy();
    
    psLocation.y +=10;
    ps.run(psLocation);
    
    wind.y-=500;
    if(velocity.mag()>0){
      windSound.amp(map(velocity.mag(), 0, maximumVelocity, 0, 0.1f));
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
  
  public PVector getCameraLocation(){
    return this.cameraLocation;
  }
  
  public PVector getLocation(){
    return this.location;
  }
  
  public float[] getChunk(){
    float[] chunkNum = new float[2];

    chunkNum[0] = (location.x>=0) ? floor((chunkSize + location.x)/chunkSize) : ceil(location.x/chunkSize);
    chunkNum[1] = (location.z>=0) ? floor(location.z/chunkSize) : ceil((-chunkSize + location.z)/chunkSize);
   
    return chunkNum;
  }

  public float getRadius(){
    return this.radius;
  }
 
  public float getVelocity(){
    return this.velocity.mag();
  }
  
  public float getMaximumVelocity(){
    return this.maximumVelocity;
  }

}
 

 

class TerrainTransition{
 
  float range;
  float start;
  float end;
  int blendLevel;
  
  PVector[][] points;
  
  PImage lower;
  PImage higher;
  
  PShape[] levels;
  
  PShape blendedShape = createShape(GROUP);
  
  public TerrainTransition(float start, float end, int blendLevel, PVector[][] points, PImage lower, PImage higher){
    this.start = start;
    this.end = end;
    range = abs(start-end);
    this.blendLevel = blendLevel;
    this.points = points;
    this.lower = lower.copy();
    this.higher = higher.copy();
    
    levels = new PShape[blendLevel];
    for(int i = 0; i < levels.length; i++){
      levels[i] = createShape();
    }
  }
  
  public PShape getBlendedShape(){
      
    float now = millis();
    for(int i = 0; i < levels.length; i++){
      int[] maskArray = new int[textureSize*textureSize];
      int[] reverseMaskArray = new int[textureSize*textureSize];
      Arrays.fill(maskArray, (i+1)*(255/(blendLevel+1)));
      Arrays.fill(reverseMaskArray, 255 - (i+1)*(255/(blendLevel+1)));
      
      PImage higherWithAlpha = higher.copy();
      PImage lowerWithHigher = lower.copy();
      
      higherWithAlpha.mask(maskArray);
      lowerWithHigher.mask(reverseMaskArray);
      
      lowerWithHigher.blend(higherWithAlpha, 0, 0, textureSize, textureSize, 0, 0, textureSize, textureSize, BLEND);
      levels[i].setTexture(lowerWithHigher);
      
      levels[i].beginShape(QUADS);
    }
    
    for(int z = 0; z < points.length-1; z++){
      for(int x = 0; x < points[z].length-1; x++){
        for(int i = 0; i < levels.length; i++){
          if(points[x][z].y <= start-i*(range/blendLevel) && points[x][z].y > start-(i+1)*(range/blendLevel)){
            PVector n = PVector.sub(points[x][z], points[x+1][z], null).cross(PVector.sub(points[x][z+1], points[x+1][z], null));
            n.normalize();
            
            float textureScale = chunkSize/100;
            
            levels[i].normal(n.x, -n.y, n.z);
            levels[i].noStroke();
            levels[i].vertex(points[x][z].x, points[x][z].y, points[x][z].z, (x*scale)/textureScale, (z*scale)/textureScale);
            levels[i].vertex(points[x+1][z].x, points[x+1][z].y, points[x+1][z].z, ((x+1)*scale)/textureScale, (z*scale)/textureScale);
            levels[i].vertex(points[x+1][z+1].x, points[x+1][z+1].y, points[x+1][z+1].z, ((x+1)*scale)/textureScale, ((z+1)*scale)/textureScale);
            levels[i].vertex(points[x][z+1].x, points[x][z+1].y, points[x][z+1].z, (x*scale)/textureScale, ((z+1)*scale)/textureScale);
            
          }
        }
      }
    }
    //println(millis() - now + "ms");
    
    for(int i = 0; i < levels.length; i++){
      levels[i].endShape();
      blendedShape.addChild(levels[i]);
    }
    
    return blendedShape;
    
  }
  
}
class Water{
  PVector position;
  
  int wavePoints = 90;
  float scale = (chunkSize*3)/wavePoints;
  float[][] waves = new float[wavePoints+1][wavePoints+1];
  
  public Water(PVector position){
     this.position = position;
  }
  
  
  public void display(){
    offset+=0.001f;
    offset=offset%10000000;
    shapeMode(CORNER);
    for(int i = 0; i < waves.length; i++){
      for(int j = 0; j < waves[i].length; j++){
        waves[i][j] = getHeight((position.x + i*scale)/chunkSize, offset+(position.z + j*scale)/chunkSize);
      }
    }
    pushMatrix();
    translate(position.x, position.y, position.z);
    pushStyle();
    textureWrap(REPEAT);
    textureMode(NORMAL);
    tint(0, 130, 255, 150);
    shininess(20);
    specular(1, 1, 1);
    for(int z = 0; z < waves.length-1; z++){
      PShape row = createShape();
      beginShape(TRIANGLES);
      
      texture(sea);
      for(int x = 0; x < waves[z].length-1; x++){
        vertex(x*this.scale, waves[x][z], z*this.scale, 0, 0);
        vertex(x*this.scale, waves[x][z+1], (z+1)*this.scale, 0, 1);
        vertex((x+1)*this.scale, waves[x+1][z], z*this.scale, 1, 1);
        
        vertex(x*this.scale, waves[x][z+1], (z+1)*this.scale, 0, 1);
        vertex((x+1)*this.scale, waves[x+1][z+1], (z+1)*this.scale, 1, 1);
        vertex((x+1)*this.scale, waves[x+1][z], z*this.scale, 1, 0);
      }
      endShape();
    }
    popStyle();
    popMatrix();  
  }
  
  public float getHeight(float x, float y){
    float noise = noise(x*6, y*6);
    float value = map(noise, 0, 1, 0, -600);
    return value;
  }
  
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "explorer" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
