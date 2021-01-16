import toxi.geom.*;

class Chunk{
  PVector position;
  Vec3D[][] vecs = new Vec3D[vertecies+1][vertecies+1];
  
  PShape chunkShape = createShape();
  PShape[] rows = new PShape[vertecies];
  
  Water water;
  
  public Chunk(PVector position){
    this.position = position.copy();
    water = new Water(position);
    noiseDetail(20);
    noStroke();
    
    for(int z = 0; z <= vertecies; z++){
      for(int x = 0; x <= vertecies; x++){
        vecs[x][z] = new Vec3D(x*scale, calculateHeight((position.x + x*scale)/(chunkSize*3), (position.z + z*scale)/(chunkSize*3)), z*scale);
        }
    }
    
    chunkShape.beginShape(TRIANGLES);
     for(int z = 0; z < vertecies; z++){
      for(int x = 0; x < vertecies; x++){
        if(vecs[x][z].y < -2500){
          chunkShape.fill(200);
        }else if(vecs[x][z].y < -150){
          chunkShape.fill(color(31, 97, 16));
        }else{
          chunkShape.fill(color(214, 175, 15));
        }
        chunkShape.vertex(vecs[x][z].x, vecs[x][z].y, vecs[x][z].z);
        chunkShape.vertex(vecs[x+1][z].x, vecs[x+1][z].y, vecs[x+1][z].z);
        chunkShape.vertex(vecs[x][z+1].x, vecs[x][z+1].y, vecs[x][z+1].z);
        chunkShape.vertex(vecs[x+1][z].x, vecs[x+1][z].y, vecs[x+1][z].z);
        chunkShape.vertex(vecs[x][z+1].x, vecs[x][z+1].y, vecs[x][z+1].z);
        chunkShape.vertex(vecs[x+1][z+1].x, vecs[x+1][z+1].y, vecs[x+1][z+1].z);
        
      }
    }
    chunkShape.endShape(CLOSE);
  
  }

 
 float calculateHeight(float x, float z){
    float noiseLevel = noise(x*3,z*3);
    float value = map(noiseLevel, 0, 1, 2000, (-0.75)*chunkSize);
    return value;
  }
  
  void display(){
    //Goal is < 0.02s
    shapeMode(CORNER);
    pushMatrix();
    translate(position.x, position.y, position.z);
    shape(chunkShape);
    water.display();
    popMatrix();
    
  }
  
  PVector getVertex(int x, int y){
    return new PVector(vecs[x][y].x, vecs[x][y].y, vecs[x][y].z);
  }
  
  PVector getPosition(){
    return this.position;
  }
}
