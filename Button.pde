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

    void show(Menu menu, PVector location){
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

    boolean mouseHovering(){
        return mouseX > location.x && mouseX < location.x+size.x && mouseY > location.y && mouseY < location.y+size.y;
    }

    int coloring(){
        if(mouseHovering()){
            return color(100, 100, 100);
        }else{
            return color(255, 255, 255);
        }
    }

}