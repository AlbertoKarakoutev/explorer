PVector[] points = new PVector[10];
float[] colors = new float[10];
PImage grass;
Player player;
float[] playerChunk = {0, 0};
Chunk[][] chunks;
int chunkNumber = 4;
static final float chunkSize = 15000;

void setup() {
  fullScreen(P3D);
  grass = loadImage("grass.jpeg");
  grass.resize(200, 200);
  
  noiseSeed(123);

  player = new Player();
  chunks = new Chunk[chunkNumber][chunkNumber];
  calculateChunks(chunks);
  
  for (int i = 0; i < colors.length; i++) {
    colors[i] = random(100, 150);
  }
}

void draw() {
 
  background(50);
  image(grass, 0, 0);
  perspective(PI/3, float(width)/float(height), (height/2) / tan((PI/3)/2)/10, 30000); 
  lights();
  noStroke();
  strokeWeight(1);
  
  if((int)playerChunk[0] != (int)player.getChunk()[0] || (int)playerChunk[1] != (int)player.getChunk()[1]){
    calculateChunks(chunks);
  }
  playerChunk = player.getChunk();
  player.update();
  
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
  
  pushMatrix();
  translate(0, 500, 0);
  sphere(40);
  popMatrix();
  
  
  //println("Radius: " + player.getRadius());
  //println("Location: " + player.getLocation());
  //println("Direction: " + player.getDirection());
  //println("Center chunk: " + chunks[1][1].getPosition());
  //println("Player chunk: " + player.getChunk()[0] + " " + player.getChunk()[1]);
  //println("Stopped: " + player.stop);
  //println(" ");

  //for (int i = 2; i < points.length; i++) {
  //  PVector cv = points[i];
  //  pushMatrix();
  //  translate(cv.x, cv.y, cv.z);
  //  noStroke();
  //  fill(colors[i]);
  //  ellipseMode(CENTER);
  //  sphere(4);
  //  popMatrix();
  //}
}

void calculateChunks(Chunk[][] chunks){
  PVector playerChunk = new PVector();
  playerChunk.x = player.getChunk()[0]*chunkSize;
  playerChunk.z = player.getChunk()[1]*chunkSize;
  for(int i = 0; i < chunks.length; i++){
    for(int j = 0; j < chunks[0].length; j++){
      PVector chunkPos = new PVector();
      chunkPos.x = playerChunk.x + (i-2)*chunkSize;
      chunkPos.z = playerChunk.z + (j-1)*chunkSize;
      color chunkColor = color(5, 59, 17);
      if(i==1 && j==1){
        //chunkColor = color(124, 148, 123);
      }
      float[] chunkID = {chunkPos.x/chunkSize, chunkPos.z/chunkSize};
      chunks[i][j] = new Chunk(chunkPos, chunkSize, chunkColor, chunkID, grass);
    }
  }
}
  
void mouseWheel(MouseEvent event){
  if(event.getCount()<0){
    player.radius-=50;
  }else{
    player.radius+=50;
  }
}

void mousePressed() {
  player.stop = !player.stop;
}
