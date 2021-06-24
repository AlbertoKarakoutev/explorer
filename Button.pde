class Button{

    PImage buttonTexture;
    float yLocation;
    PVector size;

    String name;

    public Button(String name){
        this.name = name;
    }

    void show(Menu menu, float yLocation){
        
        this.yLocation = yLocation;
        
        PGraphics menuPanel = menu.getPanel();
        menuPanel.beginDraw();

        menuPanel.fill(coloring());
        menuPanel.rect(width/3, yLocation, width/3, 50);

        menuPanel.fill(0);
        menuPanel.textSize(50);
        menuPanel.text(name, width/3+(width/3-menuPanel.textWidth(name))/2, yLocation+40);

        menuPanel.endDraw();
    }

    int coloring(){
        if(mouseHovering()){
            return color(100, 100, 100);
        }else{
            return color(255, 255, 255);
        }
    }

    boolean mouseHovering(){
        return mouseX > width/3 && mouseX < 2*width/3 && mouseY > yLocation && mouseY < yLocation+50;
        
    }

}
