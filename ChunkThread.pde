class ChunkThread extends Thread{
 
  PVector chunkPos;
  
  int row, col;
  
  public ChunkThread(PVector chunkPos, int row, int col){
    this.chunkPos = chunkPos;
    this.row = row;
    this.col = col;
  }
  
  void run(){
    chunks[row][col] = new Chunk(chunkPos);
  }
  
}
