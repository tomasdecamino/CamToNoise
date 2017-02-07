// @author: Tomas de Camino Beck
// Uses BlobDetection library and Processing Sound Library

import processing.video.*;
import blobDetection.*;
import processing.sound.*;

Capture cam;
BlobDetection theBlobDetection;
PImage img;
boolean newFrame=false;
int timeline=0;

//to store sawtoooth oscillators
int maxSaw =20;//maxplaying
ArrayList<SawOsc> saw = new ArrayList<SawOsc>();


void setup()
{
  // Size of applet
  size(640, 480);

  String[] cameras = Capture.list();
  for (int i = 0; i < cameras.length; i++) {
    println(i+" "+cameras[i]);
  }
  // start webcam change to wahtever webcam you want to use from the list
  cam = new Capture(this, cameras[14]);
  cam.start();

  // BlobDetection
  // imgage for blob detection
  img = new PImage(80, 60); 
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(false);
  theBlobDetection.setThreshold(0.3f); // Threshold for detecting dark objects;

  //start sawtooth oscillators
  for (int i=0; i<maxSaw; i++) {
    saw.add(new SawOsc(this));
  }
}

//Capture webcam
void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
}

//main
void draw()
{

  if (newFrame)
  {
    stopSounds();
    newFrame=false;
    image(cam, 0, 0, width, height);
    img.copy(cam, 0, 0, cam.width, cam.height, 
      0, 0, img.width, img.height);
    theBlobDetection.computeBlobs(img.pixels);
    drawBlobsAndEdges();
    playSound();
  }
  //moving line
  timeline=(timeline+30)%height;
  strokeWeight(10);
  stroke(255, 100);
  line(0, timeline, width, timeline);
}

//Drawing the blobs
void drawBlobsAndEdges() {

  noFill();
  Blob b;
  EdgeVertex eA, eB;
  for (int n=0; n<theBlobDetection.getBlobNb(); n++)
  {
    b=theBlobDetection.getBlob(n);
    if (b!=null) {
      // drawBlobs
      strokeWeight(8);
      stroke(255, 0, 0, 130);
      rect(b.xMin*width, b.yMin*height, b.w*width, b.h*height);
    }
  }
}

void playSound() {
  Blob b;
  for (int n=0; n<theBlobDetection.getBlobNb(); n++)
  {
    b=theBlobDetection.getBlob(n);
    SawOsc s;
    s= saw.get(n);
    s.stop();
    if (abs(timeline-b.yMin*height)<30) {
      if (n<maxSaw) { //<>//
        s.freq(map(b.xMin*width, 0, width, 60.0, 4000.0));
        s.play();
      }
    } else {
      s.stop();
    }
  }
}

void stopSounds() {
  int j = theBlobDetection.getBlobNb();
  for (int i=j; i<maxSaw; i++) {
    SawOsc s;
    s= saw.get(i);
    s.stop();
  }
}
