class Menu{

    PGraphics panel;

    boolean showing = false;

    ArrayList<Button> buttons = new ArrayList<Button>();

    PVector buttonSize = new PVector (400, 50);
    int buttonLocationX = width/2-200;

    void show(){

        panel = createGraphics(width, height);
        panel.beginDraw();
        panel.fill(0, 0, 0);
        panel.rect(0, 0, width, height);
        panel.endDraw();

        for(int i = 0; i < buttons.size(); i++){
            int buttonLocationY = (i+1)*(height/(buttons.size()+1));
            buttons.get(i).show(this, new PVector(buttonLocationX, buttonLocationY));
        }
        
        background(panel); 
    }

    void addButton(String name){
        buttons.add(new Button(name, buttonSize));
    }
    Button getButton(int index){
        return buttons.get(index);
    }

    PGraphics getPanel(){
        return this.panel;
    }

    boolean getShowing(){
        return this.showing;
    }

    void setShowing(boolean showing){
        this.showing = showing;
    }

}