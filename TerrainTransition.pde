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
    this.range = abs(start-end);
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
            new Chunk().addSurfaceToShape(levels[i], points, x, z);
          }
        }
      }
    }
    
    for(int i = 0; i < levels.length; i++){
      levels[i].endShape(CLOSE);
      blendedShape.addChild(levels[i]);
    }
    
    return blendedShape;
    
  }
  
}
