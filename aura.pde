/*
Aura
 ICM Final Project
 Johann Diedrick
 
 with help from Danny Rozin, Greg Borenstein, Calli Higgins and innumerable others within the ITP community
 
 11.28.11
 -add in minim featuers
 -refine radiating effect
 -use minim to dynamically change threshold
 -scaling from the center of the blob?
 
 
 11.30.11
 -work on opencv capture scaling
 
 */

//libraries
import hypermedia.video.*; //import hypermedia video library
import java.awt.*; //import java library


float scaleFactor = 1;
float shiftX = 0;
float shiftY = 0;

float hypotenuse;
float jumpFactorX = 0;
float jumpFactorY = 0;



//global variables for display and opencv
OpenCV opencv; //declare OpenCV object to variable opencv
int widthDisplay = 1280;//1280; // set width of display. full screen is approx 1280
int heightDisplay =960;// 960; // set height of display. full screen is approx 800;
int widthCapture = 1280; // set width of opencv capture
int heightCapture = 960; // set height of opencv capture
int threshold = 100; // set default threshold value

//global variables for looping the stroke outline of the blob contour
int redValue = 255; // set initial value of red
int blueValue = 0; // set initial value of blue
int greenValue = 0; // set initial value of green

//global variables for scaling
float scaleValue=1.0; // set initial scale value
float scaleAdditive = 0.01; // set initial scale additive value

//global variables for debugging
boolean debug = false; // set default value for debug mode
boolean find=true; // not sure...?
PFont font; // font for debugging text, turned off for now


boolean jump = false;
boolean clear= false;

/*SETPUP*/
void setup() {

  size( widthDisplay, heightDisplay ); // set display size

  opencv = new OpenCV( this ); // initialize opencv variable
  opencv.capture(widthCapture, heightCapture); // set capture size. should be 320 x 240

  font = loadFont( "AndaleMono.vlw" ); // load display font
  textFont( font );

  println( "Drag mouse inside sketch window to change threshold" ); // print line instructions for threshold
  println( "Press space bar to record background image" ); // print line instructions for reference frame
  println( "Z to zoom in, z to zoom out" ); // print line instructions for reference frame
  println( "X to move right, x to move left" ); // print line instructions for reference frame
  println( "Y to move up, y to move down" ); // print line instructions for reference frame
  background(255); //set background color
  
}

/*DRAW*/
void draw() {


  // translate(shiftX,shiftY);

 // jumpFactorX = 0;
 // jumpFactorY = 0;

fill(0);
ellipse(width/2, height/2, 5, 5);
  //set up transparent rectangle for fading effect
  fill(255, 0);
  rect(0, 0, widthDisplay, heightDisplay);

  //clear screen
  if (clear) {
    fill(255);
    rect(0, 0, widthDisplay, heightDisplay);
  }
  else

      //opencv
    opencv.read();
  opencv.flip( OpenCV.FLIP_HORIZONTAL ); // flip image for rear projection

  //debug mode code
  if (debug) {
    image( opencv.image(OpenCV.MEMORY), 0, 0 ); // image in memory
  } 
  else {


    opencv.absDiff();
    opencv.threshold(threshold);

    // working with blobs
    Blob[] blobs = opencv.blobs( 200, width*height -50, 100, true );

    //translate coordiate plane to the center for radial scaling
    translate(widthDisplay/2 + shiftX, heightDisplay/2 + shiftY);

    scale(scaleFactor);


    //scale up blobs for radiating effect (might be better to do in begin shape loop?
    if ( scaleValue>2.3) {
      //scaleAdditive = scaleAdditive*-1; // scale back down
      scaleValue=1.0; // scale back to 1.0
    }
    else if (scaleValue<1.0) scaleAdditive = 0.001; 
    scale(scaleValue);
    scaleValue = scaleValue + scaleAdditive;
    //  println(scaleValue); // print scale value

      //translate back


    translate(-widthDisplay /2+ shiftX, -heightDisplay/2 + shiftY);

    pushMatrix(); //still not sure how this works...

    //draw blobs
    for ( int i=0; i<blobs.length; i++ ) {

      Point[] points = blobs[i].points;
      Point centroid = blobs[i].centroid;

      //fill(0); //black fill for blobs if necessary 

      //dynamic stroke color (i should be able to write this into a function...)  
      stroke(redValue, greenValue, blueValue);
      //start at red and go to yellow
      if ( greenValue<255 && redValue==255 && blueValue==0) {
        greenValue++;
      }

      //go from yellow to pure green
      if (greenValue == 255 && redValue>0) {
        //redToGreen = false;
        redValue--;
      }

      //go from green to cyan/bluish-green
      if (redValue==0 && greenValue==255 && blueValue<255) {

        blueValue++;
      }

      //go from bluish-green to blue
      if (blueValue==255 && greenValue>0) {
        greenValue--;
      }
      // go from blue to violet
      if (redValue < 255 && greenValue==0 && blueValue==255) {
        redValue++;
      }
      //go from violet to red
      if (redValue == 255 && blueValue>0) {
        blueValue--;
      }
      //pushMatrix();


      //translate(centroid.x, centroid.y);//translation with centroids
      //popMatrix();//pop matrix

      //draw blob shape 
      if ( points.length>0 ) {
        beginShape();

        for ( int j=1; j<points.length; j++ ) {
          float x =  lerp(points[j-1].x, points[j].x, .01); // lerp for cleaner lines, from calli
          float y=   lerp(points[j-1].y, points[j].y, .01); // lerp for cleaner lines, from calli


          if (jump) {

            hypotenuse=  sqrt((x*x)+(y*y));

            jumpFactorX = x/hypotenuse*20;
            jumpFactorY = y/hypotenuse*20;



            if (x<width/2) {
              jumpFactorX = jumpFactorX*-1;
            }
            if (y<height/2) {
              jumpFactorY = jumpFactorY*-1;
            }


            // println("jump factor x: " + jumpFactorX + "jump factor y :" + jumpFactorY); // for debugging
            vertex(x + jumpFactorX, y + jumpFactorY);
            x++;
            y++;
          }
          else

              //println("point:" + points[j-1] + "x: " + x + " y: " + y );    

            vertex(x, y);
        }
        endShape(CLOSE);
      }
    }

    popMatrix(); // still not sure what this does
  }
}
/*END DRAW*/

//save frame to opencv buffer
void keyPressed() {
  if ( key==' ' ) {
    println("saving");
    opencv.remember();
  }

  //switch to debug mode
  if (key == 'd') {
    println("debug: " + debug);
    debug = !debug;
  }

  if (key == 'j') {
    println("jump: " + jump);
    jump = !jump;
  }


  if (key=='c') {
    println("clearing screen");
    scaleValue=1.0;
    clear= !clear;
  }


  if (key == 'z') {
    scaleFactor -= 0.01;
  }

  if (key == 'Z') {
    scaleFactor += 0.01;
  }

  if (key == 'x') {
    shiftX -= 1.0;
  }

  if (key == 'X') {
    shiftX += 1.0;
  }


  if (key == 'Y') {
    shiftY -= 1.0;
  }

  if (key == 'y') {
    shiftY += 1.0;
  }
}


//change threshold against x axis
void mouseDragged() {
  threshold = int( map(mouseX, 0, width, 0, 255) );
  println("threshold is: " + threshold);
}

//stop everything
public void stop() {
  opencv.stop();
  super.stop();
}

