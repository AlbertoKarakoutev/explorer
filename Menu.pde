class Menu{

    PGraphics panel;

    boolean showing = false;

    Map<String, Button> buttons = new LinkedHashMap<String, Button>();
    Map<String, Checkbox> checkboxes = new LinkedHashMap<String, Checkbox>();

    PVector buttonSize = new PVector (400, 50);
    float checkboxSize = 40; 
    int buttonLocationX = width/2-200;
    int checkboxLocationX = width/2+200;

    public Menu(){
        addButton("Resume");
    }

    void show(){
        setShowing(true);
        panel = createGraphics(width, height);
        panel.beginDraw();
        panel.fill(0, 0, 0);
        panel.rect(0, 0, width, height);
        panel.endDraw();

        int counter = 0;
        int items = buttons.size() + checkboxes.size();
        for (String key : buttons.keySet()) {
            int buttonLocationY = (counter+1)*(height/(items+1));
            buttons.get(key).show(this, buttonLocationY);
            counter++;
        }

        int checkboxCounter = counter;
        for (String key : checkboxes.keySet()) {
            int checkboxLocationY = (checkboxCounter+1)*(height/(items+1));
            checkboxes.get(key).show(this, new PVector(checkboxLocationX, checkboxLocationY));
            checkboxCounter++;
        }
        
        background(panel); 
    }

    void addButton(String name){
        buttons.put(name, new Button(name));
    }

    void addCheckbox(String name, boolean attribute){
        checkboxes.put(name, new Checkbox(name, checkboxSize, attribute));
    }

    Button getButton(String button){
        return buttons.get(button);
    }

    Checkbox getCheckbox(String checkbox){
        return checkboxes.get(checkbox);
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

    boolean mouseHovering(String name, boolean isButton){
        if(isButton){
            try{
                Button button = getButton(name);
                return mouseX > width/3 && mouseX <2*width/3 && mouseY > button.yLocation && mouseY < button.yLocation+50;
            }catch(Exception e){}
        }else{
            try{
                Checkbox checkbox = getCheckbox(name);
                return mouseX > checkbox.location.x && mouseX < checkbox.location.x+checkboxSize && mouseY > checkbox.location.y && mouseY < checkbox.location.y+checkboxSize;
            }catch(Exception e){}
        }
        return false;
    }

}
