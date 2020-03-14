import controlP5.*; //UI lib
ControlP5 cp5;
int sliderXTranslate = 0;
int sliderYTranslate = 0;
int sliderZTranslate = 0;

float sliderXScale = 1.f;
float sliderYScale = 1.f;
float sliderZScale = 1.f;

float sliderXRotate = 0.f;
float sliderYRotate = 0.f;
float sliderZRotate = 0.f;
//new identity matrix
PMatrix3D colorTransform = new PMatrix3D(1,0,0,0,
                                    0,1,0,0,
                                    0,0,1,0,
                                    0,0,0,1);
PImage img;
PGraphics recieverGraphics;

void setup()
{
  img = loadImage("grimes-vogue2012-Laurie-Bartley.jpg");
  size(1000,1000,P3D);//(displayHeight-150)*img.width/img.height,displayHeight-150,P3D);
  recieverGraphics = createGraphics(img.width,img.height,P3D);
  initControls();
}

//create p5 controls for the transform
void initControls()
{
  
  sliderXTranslate = 0;
  sliderYTranslate = 0;
  sliderZTranslate = 0;
  
  sliderXScale = 1.f;
  sliderYScale = 1.f;
  sliderZScale = 1.f;
  
  sliderXRotate = 0.f;
  sliderYRotate = 0.f;
  sliderZRotate = 0.f;
  cp5 = new ControlP5(this);
  
  cp5.remove("sliderXTranslate");
  cp5.remove("sliderYTranslate");
  cp5.remove("sliderZTranslate");
  cp5.remove("sliderXScale");
  cp5.remove("sliderYScale");
  cp5.remove("sliderZScale");
  cp5.remove("sliderXRotate");
  cp5.remove("sliderYRotate");
  cp5.remove("sliderZRotate");
  float top = 20;
  float left = 15;
  //translations
  cp5.addSlider("sliderXTranslate")
               .setPosition(left,top)
               .setRange(-280,280)
               .setWidth(400);
               top+=10;
  cp5.addSlider("sliderYTranslate")
               .setPosition(left,top)
               .setRange(-280,280)
               .setWidth(400);
               top+=10;
  cp5.addSlider("sliderZTranslate")
               .setPosition(left,top)
               .setRange(-280,280)
               .setWidth(400);
               top+=15;

  //Scaling
  cp5.addSlider("sliderXScale")
               .setPosition(left,top)
               .setRange(-1.5,1.5)
               .setWidth(400);
               top+=10;
  cp5.addSlider("sliderYScale")
               .setPosition(left,top)
               .setRange(-1.5,1.5)
               .setWidth(400);
               top+=10;
  cp5.addSlider("sliderZScale")
               .setPosition(left,top)
               .setRange(-1.5,1.5)
               .setWidth(400);
               top+=15;

  //rotations
  cp5.addSlider("sliderXRotate")
               .setPosition(left,top)
               .setRange(0,TWO_PI)
               .setWidth(400);
               top+=10;
  cp5.addSlider("sliderYRotate")
               .setPosition(left,top)
               .setRange(0,TWO_PI)
               .setWidth(400);
               top+=10;
  cp5.addSlider("sliderZRotate")
               .setPosition(left,top)
               .setRange(0,TWO_PI)
               .setWidth(400);
  colorTransform = new PMatrix3D(1,0,0,0,
                                 0,1,0,0,
                                 0,0,1,0,
                                 0,0,0,1);
}

void handleASyncFileInput()
{
    if(newLoad != null)
  {
    img = loadImage(newLoad);
    recieverGraphics = createGraphics(img.width,img.height,P3D);
    initControls();
    newLoad= null;
  }
}
void draw()
{
  
  handleASyncFileInput();
  
  background(180);
  updateMatrix();
  renderImg();
  image(recieverGraphics,0,150,width,height-150);

 drawTransforms();
 textSize(25);
 text("click and drag bars above to alter coloration",10,145);
 textSize(32);
  text("press 's' to save, 'o' to open a new file, 'r' to reset colors",10,height-40);
}

//apply the transforms from the sliders to our matrix
void updateMatrix()
{
  //initialize as identity
  colorTransform.set(1,0,0,0,
                     0,1,0,0,
                     0,0,1,0,
                     0,0,0,1);
  colorTransform.translate(sliderXTranslate,sliderYTranslate,sliderZTranslate);
  colorTransform.rotateX(sliderXRotate);
  colorTransform.rotateY(sliderYRotate);
  colorTransform.rotateZ(sliderZRotate);
  colorTransform.scale(sliderXScale,sliderYScale,sliderZScale);
}

//use the transfrom matrix to alter the colors in the image
void renderImg()
{
//  colorMode(HSB, 255);
  recieverGraphics.beginDraw();
  recieverGraphics.loadPixels();
  img.loadPixels();
  for(int i = 0; i < recieverGraphics.pixels.length; i++)
  {
    int pc = img.pixels[i];
//    PVector c = new PVector(hue(pc),saturation(pc),brightness(pc));
    PVector c = new PVector(red(pc),green(pc),blue(pc));
    float a = alpha(pc);
    PVector out = new PVector();
    colorTransform.mult(c,out);
    recieverGraphics.pixels[i] = color(out.x,out.y,out.z,a);
}
  recieverGraphics.updatePixels();
  recieverGraphics.endDraw();
}

//draw the boxes to help visualize the 3-space transformation
void drawTransforms()
{
  float boxSz = 255;
  pushStyle();
    stroke(255);
    noFill();
    pushMatrix();
      translate(width/2,height/2,200);
      rotateY(millis()/5000.f);
      translate(-boxSz/2,-boxSz/2,-boxSz/2);
      pushMatrix();
        translate(boxSz/2,boxSz/2,boxSz/2);
        box(boxSz);
      popMatrix();
      drawBasis();
      
      pushMatrix();
        applyMatrix(colorTransform);
        pushMatrix();
          translate(boxSz/2,boxSz/2,boxSz/2);
          box(boxSz);
        popMatrix();
        drawBasis();
      popMatrix();
    popMatrix();
  popStyle(); 
}

//draw a simple set x-y-z 'unit' lines 
void drawBasis()
{
  pushStyle();
    strokeWeight(5);
    stroke(255,0,0);
    line(0,0,0,20,0,0);
    
    stroke(0,255,0);
    line(0,0,0,0,20,0);
    
    stroke(0,0,255);
    line(0,0,0,0,0,20);
  popStyle(); 
}

void keyPressed() {
  
  if (key == 's' ) {
    String className = this.getClass().getSimpleName();
String savePath = "renders/" + className+"-"+year()+"-"+month()+"-"+day()+"."+hour()+"."+minute()+"."+second()+"."+millis() +".png";
  println("Saving to: " + savePath);
    recieverGraphics.save(savePath);    
  }
  if (key=='o')
  {
    selectInput("Select an image file to process:", "fileSelected");
  }
    if (key=='r')
  {
    initControls();
  }
}

String newLoad ="grimes-vogue2012-Laurie-Bartley.jpg" ;
void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
      println("User selected " + selection.getAbsolutePath());
      newLoad = selection.getAbsolutePath();
  }
}
