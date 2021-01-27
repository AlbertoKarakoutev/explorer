class ChunkThread extends Thread{
 
  PVector playerChunkCoordinates;
  
  public ChunkThread(PVector playerChunkCoordinates){
    this.playerChunkCoordinates = playerChunkCoordinates;
  }
  
  void run(){
    
    for(int i = 0; i < chunks.length; i++){ //<>//
      for(int j = 0; j < chunks[0].length; j++){
        PVector chunkPos = new PVector(0, 0, 0);
        chunkPos.x = playerChunkCoordinates.x + (i-(1+floor(chunks.length/2)))*chunkSize;
        chunkPos.z = playerChunkCoordinates.z + (j-floor(chunks.length/2))*chunkSize;
        newChunks[i][j] = new Chunk(chunkPos);
        
        println("chunk creation" + i + j);
      }
    }
    
    for(int i = 0; i < newChunks.length; i++){
      arrayCopy(newChunks[i], chunks[i]);
    }
    
    updatingChunks = false;
  }
  
}
