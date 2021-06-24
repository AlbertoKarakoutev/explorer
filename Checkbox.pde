class Checkbox{

    boolean checked;
    PVector location;
    float size;

    String name;

    public Checkbox(String name, float size, boolean attribute){
        this.name = name;
        this.size = size;
        this.checked = attribute;
    }

    void show(Menu menu, PVector location){
        this.location = location;
        this.location.x = 3*width/4;

        PGraphics menuPanel = menu.getPanel();
        menuPanel.beginDraw();

        menuPanel.fill(255);
            
        menuPanel.beginShape();
            /*Outer white square*/
            menuPanel.vertex(location.x, location.y);
            menuPanel.vertex(location.x + size, location.y);
            menuPanel.vertex(location.x + size, location.y + size);
            menuPanel.vertex(location.x, location.y + size);

            float off = size/5;
            
            /*Inner black hole*/
            menuPanel.beginContour();
                menuPanel.vertex(location.x + off, location.y + off);
                menuPanel.vertex(location.x + off, location.y + size - off);
                menuPanel.vertex(location.x + size - off, location.y + size - off);
                menuPanel.vertex(location.x + size - off, location.y + off);
            menuPanel.endContour();

        menuPanel.endShape(CLOSE);

        menuPanel.beginShape();
            if(checked){
                off = size/4;
                /*Inner white fill square*/
                menuPanel.vertex(location.x + off, location.y + off);
                menuPanel.vertex(location.x + size - off, location.y + off);  
                menuPanel.vertex(location.x + size - off, location.y + size - off);
                menuPanel.vertex(location.x + off, location.y + size - off);
            }
        menuPanel.endShape(CLOSE);

        menuPanel.textSize(50);
        menuPanel.text(name, width/4, location.y+(size-5));

        menuPanel.endDraw();
    }

    void setChecked(boolean checked){
        this.checked = checked;
    }

    boolean getChecked(){
        return this.checked;
    }

    void toggle(){
        checked = !checked;
    }

}
