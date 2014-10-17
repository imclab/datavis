/**************************************************/
// Libraries
/**************************************************/
import processing.opengl.*;
import javax.media.opengl.*;
import peasy.*;
import peasy.org.apache.commons.math.*;
import controlP5.*;

/**************************************************/
// Setup
/**************************************************/
void setup()
{
  ///Set up Canvas 
  size(1280, 800, OPENGL);       
  hint(DISABLE_OPENGL_2X_SMOOTH);
  hint(ENABLE_OPENGL_4X_SMOOTH); 

  smooth();
  colorMode(HSB, 360, 100, 100, 100);
  frameRate(1000);

  loadData(); // load fp data

    EPICENTER_X = 0; // center of grid
  EPICENTER_Y = 0;  

  cam = new PeasyCam(this, 0, 0, 0, 2400);
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(5000);

  //println(nTransactions);
  // give nodes a variable display to declutter
  variance = new float[nTransactions];
  varianceIntegrator = new Integrator[nTransactions];

  for (int i = 0; i < variance.length; i++) 
  {
    variance[i] = random(-100, 100); //random positioning
    varianceIntegrator[i] = new Integrator(variance[i], 0.3, 0.8);
  }

  idx = 0; // variance index  

  g3 = (PGraphics3D)g;
  slide = new Integrator(-80, 0.3, 0.8);
  setupGUI();

  // colors
  bgColor = color(351, 86, 20);
  treeColor = color(0, 0, 100, 30);  
  nodeColor = color(0, 0, 100, 100);
  labelColor = color(0, 0, 100, 100);  
  pyramidColor = color(0, 0, 100, 50);
}


/**************************************************/
// draw
/**************************************************/
void draw() 
{
  background(bgColor); 

  slide.update();

  for (int i = 0; i < varianceIntegrator.length; i++) 
  {
    varianceIntegrator[i].update();
  }  

  //background(mouseX%360, 86, 99);  
  //background(213, 86, 99); // lt blue color

  //background(348, 86, 99); // pink/red color
  //println(mouseX%360);

  // draw GUI
  if (displayGUI) 
  {
    //this moves the interface up and down
    if ((mouseY > 1) && (mouseY < 40)) // as long as the mouse gets within 60 from the top, open GUI
    {
      slide.target(0);
      lockGUI = true;
      cam.setActive(false); // disable peasycam while gui is open
    } 
    else if (mouseY > 100) {
      slide.target(-80);
      cam.setActive(true);
    }

    if (lockGUI == false)
    {
      slide.target(-80);
    }

    // set position of gui panel
    if (l.position().y != slide.value)
    {
      l.position().y = slide.value;
    }
  }


  // peasy cam  
  peasyCamPosition = cam.getPosition(); // get position
  // rotations = cam.getRotations(); // get rotations

  if (rotateCam) 
  {
    // constant rotation
    cam.rotateY(camRotationRate);

    float[] rot = cam.getRotations(); // get rotations
    xRotation = rot[0];
    yRotation = rot[1];
    zRotation = rot[2];
    xRotationTarget = rot[0];
    yRotationTarget = rot[1];
    zRotationTarget = rot[2];
  } 
  else {
    float f = 10.0; // the higher the value, the slower it rotates
    xRotation = xRotation + ((xRotationTarget-xRotation)/f);
    yRotation = yRotation + ((yRotationTarget-yRotation)/f);
    zRotation = zRotation + ((zRotationTarget-zRotation)/f);

    // if mouse pressed, stop setting rotations
    if (!mousePressed) 
    { 
      cam.setRotations(xRotation, yRotation, zRotation);
    }
  }

  //use HUD to write stuff that is stationary in relation to the camera
  if (displayHUD) 
  {
    cam.beginHUD();
    //    textFont(font);
    //    textSize(20);
    //    textAlign(LEFT, TOP);
    //    fill(0, 0, 0);  
    //    text("xRotation: " + xRotationTarget + " yRotation: " + yRotationTarget + " zRotation: " + zRotationTarget, 10, 10);
    //    text("xPos: " + peasyCamPosition[0] + "     yPos: "+ peasyCamPosition[1] + "     zPos: " + peasyCamPosition[2], 10, 30);

    // Active Dataset 
    fill(0, 0, 100);
    textAlign(RIGHT, BOTTOM);
    textFont(font);  
    textSize(40);
    text("SPACETIME", width-10, height);

    cam.endHUD();
  }

  idx = 0; // idx for variance

  // draw everything else
  if (displayGrid) 
  {
    drawPolarGrid();
    //drawPolarPlot();
  }


  drawData();

  if (displayGUI)
  {
    drawGUI();
  }

  // set camera to
  // 270
  // 2000
  // 0
}


void drawData()
{ 

  //  pushMatrix();
  //  rotateX(rotations[0]);        
  //  rotateY(rotations[1]);        
  //  rotateZ(rotations[2]);        
  //
  //  fill(0, 0, 100);
  //  textAlign(CENTER, CENTER);
  //  textFont(font);  
  //  text("WATER", 0, 0, 1);
  //  popMatrix();
  //(Node t, int wide, int deep, int siblings, float currentRotation)
  // first node, number of levels out, depth of this branch, number of siblings
  fp.graphViz(fp.root, 0, 1, fp.root.child.size(), 0.0);
  fp.graphViz2(fp.root, 0, 1, fp.root.child.size(), 0.0);
}
