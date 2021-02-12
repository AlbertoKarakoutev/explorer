
import java.util.*; 

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
  
  PShape getBlendedShape(){
      
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
