class MenuActions{

    void resume(){
        stop = !stop;
        simulating = !simulating;
        menu = new Menu();
        menu.addButton("Settings");
        menu.addButton("Exit");
    }

    void settings(){
        menu = new Menu();
        menu.addCheckbox("Birds", areBirdsVisible);
        menu.addCheckbox("Water", isWaterVisible);
        menu.addCheckbox("Terrain Details", areDetailsVisible);
        menu.addCheckbox("Gravity", isGravityActive);
        menu.addButton("Save");
    }

    void save(){
        
        boolean birdsTemp = areBirdsVisible;
        areBirdsVisible = menu.getCheckbox("Birds").getChecked();
        
        boolean waterTemp = isWaterVisible;
        isWaterVisible = menu.getCheckbox("Water").getChecked();
        lowestPoint = (isWaterVisible) ? -1 : -5;
        
        boolean detailsTemp = areDetailsVisible;
        areDetailsVisible = menu.getCheckbox("Terrain Details").getChecked();
        
        if(detailsTemp != areDetailsVisible || waterTemp != isWaterVisible || birdsTemp != areBirdsVisible){
            initializeChunks();
        }
        
        isGravityActive = menu.getCheckbox("Gravity").getChecked();
        
        resume();
    }
    
    void exitSimulator(){
        exit();   
    }

    void check(String name){
        menu.getCheckbox(name).toggle();
        println(name + ": " + menu.getCheckbox(name).getChecked());
    }
    
}
