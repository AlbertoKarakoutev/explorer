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
  
  void display(){
    for(int row = 0; row < gridCells; row++){
      for(int col = 0; col < gridCells; col++){
        pushMatrix();
        translate(points[row][col].x, points[row][col].y, points[row][col].z);
        fill(0);
        box(1000);
        popMatrix();
        
      }
    }
  }
  
}
