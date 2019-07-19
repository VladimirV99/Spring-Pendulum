import g4p_controls.*;

GCustomSlider sliderCoefficient;
GCustomSlider sliderMass;
GCustomSlider sliderLength;
GCustomSlider sliderZoom;

GButton bShowVelocityVector;
GButton bShowAccelerationVector;
GButton bShowAngle;
GButton bModeRope;
GButton bModeSpring;

int lastTime = 0;
int delta = 0;

boolean showVelocityVector = false;
boolean showAccelerationVector = false;
boolean showAngle = false;
boolean modeRope = false;

float zoom = 1;

Pendulum pendulum;

void setup(){
    fullScreen();
    pendulum = new Pendulum(10, 300, 20);
    frameRate(100);
    
    sliderCoefficient = createSlider("Elasticity Coefficient", 190, 30, 500, 50, 0.2, 400, pendulum.k);
    sliderMass = createSlider("Mass", 190, 80, 500, 50, 1, 150, pendulum.mass);
    sliderLength = createSlider("Length", 190, 130, 500, 50, 10, 500, pendulum.baseLength);
    sliderZoom = createSlider("Zoom", 190, 180, 500, 50, 0.5, 1.5, zoom);
    
    bShowVelocityVector = new GButton(this, 20, 35, 150, 30, "Show Velocity Vector");
    bShowAccelerationVector = new GButton(this, 20, 75, 150, 30, "Show Acceleration Vector");
    bShowAngle = new GButton(this, 20, 115, 150, 30, "Show Angle");
    bModeRope = new GButton(this, 20, 155, 150, 30, "Rope Mode");
    bModeSpring = new GButton(this, 20, 195, 150, 30, "Spring Mode");
    
    lastTime = millis();
};

void handleButtonEvents(GButton button, GEvent event){
    if(event == GEvent.CLICKED) {
        if(button == bShowVelocityVector){
            showVelocityVector = !showVelocityVector;
        } else if(button == bShowAccelerationVector){
            showAccelerationVector = ! showAccelerationVector;
        } else if(button == bShowAngle){
            showAngle = !showAngle;
        } else if(button == bModeRope){
            modeRope = true;
        } else if(button == bModeSpring){
            modeRope = false;
        }
    }
}

void handleSliderEvents(GValueControl slider, GEvent event) {
    if(event == GEvent.VALUE_STEADY) {
        if(slider == sliderCoefficient) {
            pendulum.setK(sliderCoefficient.getValueF());
        } else if(slider == sliderMass) {
            pendulum.setMass(sliderMass.getValueF());
        } else if (slider == sliderLength) {
            pendulum.setBaseLength(sliderLength.getValueF());
        } else if (slider == sliderZoom) {
            zoom = sliderZoom.getValueF();
        }
    }
}

void drawArrow(float x1, float y1, float x2, float y2, int r, int g, int b) {
    fill(r, g, b);
    stroke(r, g, b);
    strokeWeight(2);
    line(x1, y1, x2, y2);
    
    pushMatrix();
    translate(x2, y2);
    float a = atan2(x1-x2, y2-y1);
    rotate(a);
    line(0, 0, -10, -10);
    line(0, 0, 10, -10);
    popMatrix(); 
    
    text(vecToString(new PVector(x1, x2)), x2, y2);
}

String vecToString(PVector v){
    return "(" + nf(v.x, 1, 2) + ", " + nf(v.y, 1, 2) + ")";
}

class Pendulum{
    private PVector pos;
    private float baseLength;
    private float currentLength;
    private float k;
    private float mass;
    private float theta;
   
    private PVector springForce;
    private PVector velocity;
    private PVector acceleration;
    
    private final PVector gravity;
 
    Pendulum(float mass, float baseLength, float k){
        this.mass = mass;
        this.baseLength = baseLength;
        this.currentLength = baseLength;
        this.pos = new PVector(0, currentLength);
        this.k = k;
        this.theta = 0;
        
        this.velocity = new PVector(0, 0);
        this.acceleration = new PVector(0, 0);
        
        this.springForce = new PVector(0, 0);
        this.gravity = new PVector(0, 40);
    };
   
    void setK(float value){
        this.k = value;
    }
   
    void setMass(float value){
        this.mass = value;
    }
   
    void setBaseLength(float value){
        this.baseLength = value;
    }
   
    void calculateSpringForce(){
        if(modeRope && currentLength < baseLength){ 
            springForce.set(0, 0);
        } else {
            float ox = -k*(currentLength-baseLength)*sin(theta);
            float oy = -k*(currentLength-baseLength)*cos(theta);
           
            springForce.set(ox, oy);
        }
    }
   
    void draw(){
        if(modeRope){
            stroke(255, 0, 0);
        } else{
            stroke(0, 0, 255);
        }
        strokeWeight(3);
        line(0, 0, pos.x, pos.y);
 
        stroke(0);
        strokeWeight(2);
        fill(175);
        float z = 50 + 2*mass/3;
        ellipse(pos.x, pos.y, z, z);
        
        if(showVelocityVector){
            drawArrow(pendulum.pos.x, pendulum.pos.y, pendulum.pos.x + pendulum.velocity.x, pendulum.pos.y + pendulum.velocity.y, 0, 0, 255);
        }  
        if(showAccelerationVector){
            drawArrow(pendulum.pos.x, pendulum.pos.y, pendulum.pos.x + pendulum.acceleration.x, pendulum.pos.y + pendulum.acceleration.y, 255, 0, 0);
        }
        if(showAngle){
            float startAngle = PI/2;
            float endAngle = PI/2 - theta;
            
            if(theta > 0){
                startAngle = PI/2-theta;  
                endAngle = PI/2;
            }
  
            stroke(0);
            strokeWeight(2);
            if(pos.x < 0) {
                fill(255, 120, 120, 100);
            } else {
                fill(120, 120, 255, 100);
            }
            
            arc(0, 0, 150,150, startAngle, endAngle);
            fill(0);
            text(String.format("%.2f", 180/PI*theta) + "°", 0,0);
        }  
    };
    
    void drawHUD() {
        stroke(0);
        fill(0);
        strokeWeight(2);
        
        text("Length: ", 20, 20);
        text(currentLength, 70, 20);
        
         text("Angle: ", 170, 20);
        text(degrees(theta), 220, 20);
        
        text("Spring Force: ", 300, 20);
        text(vecToString(pendulum.springForce), 400, 20);
    }
   
    void calculateAngle(){
        theta = atan2(pos.x, pos.y);
    };
   
    void setPosition(PVector newPos){
        pos = newPos;        
        currentLength = pos.mag();
        calculateAngle();
        calculateSpringForce();
    };
 
    void update(float delta){
        acceleration.mult(0);
        
        applyForce(PVector.mult(gravity, mass));
        applyForce(springForce);
        velocity.add(PVector.mult(acceleration, delta));
        setPosition(PVector.add(pos, PVector.mult(velocity, delta)));
    }
 
    void applyForce(PVector sila){
        acceleration.add(PVector.div(sila, mass));
    }
    
    void reset() {
        acceleration.set(0, 0);
        velocity.set(0, 0);
    }
 
};

void draw(){
    delta = millis() - lastTime;
  
    translate(width/2, height/2);
    scale(zoom);
    background(255);
   
    pendulum.update(delta/100f);
    pendulum.draw();
    
    scale(1/zoom);
    translate(-width/2, -height/2);
    
    pendulum.drawHUD();
    
    lastTime = millis();  
};

GCustomSlider createSlider(String label, int x, int y, int sliderWidth, int sliderHeight, float min, float max, float value) {
    GCustomSlider slider = new GCustomSlider(this, x, y, sliderWidth, sliderHeight, null);
    slider.setShowDecor(false, true, true, true);
    slider.setLimits(value, min, max);
    
    GLabel sliderLabel = new GLabel(this, x + sliderWidth + 10, y, 150, sliderHeight);
    sliderLabel.setText(label);
    
    return slider;
}

boolean insideControl(GAbstractControl control, int x, int y) {
  return x >= control.getX() && x <= control.getX()+control.getWidth() &&
      y >= control.getY() && y <= control.getY()+control.getHeight();
}

void mouseClicked(){  
    if(!insideControl(bShowVelocityVector, mouseX, mouseY) && !insideControl(bShowAccelerationVector, mouseX, mouseY) && !insideControl(bShowAngle, mouseX, mouseY) && 
      !insideControl(bModeRope, mouseX, mouseY) && !insideControl(bModeSpring, mouseX, mouseY) &&
      !insideControl(sliderCoefficient, mouseX, mouseY) && !insideControl(sliderMass, mouseX, mouseY) && !insideControl(sliderLength, mouseX, mouseY) && !insideControl(sliderZoom, mouseX, mouseY)
    ){
        pendulum.setPosition(new PVector((mouseX-width/2)/zoom, (mouseY-height/2)/zoom));
        pendulum.reset();
    }
}
