/* MultiMarker class function test program */

//Rappresentare tutti i tipi di robot con un solido 3D

float angolo0X = PI/2;
float angolo0Y = -PI/2;

float angoloX = PI/2;
float angoloY = -PI/2;

int mouseHold;
float xRot0 = 0.0;
float yRot0 = 0.0;

int robot = 2;
int giunto = 1;

float q1ref = 0;
float q2ref = 0;
float q3ref = 0;
float q4ref = 0;
float q5ref = 0;
float q6ref = 0;
float q1 = 0;
float q2 = 0;
float q3 = 0;
float q4 = 0;
float q5 = 0;
float q6 = 0;

float L1 = 100.0;
float L2 = 150.0;
float L3 = 50.0;
float L4 = 50.0;
float L5 = 50.0;
float L6 = 50.0;

float D1 = 60.0;
float D2 = 60.0;
float D3 = 60.0;
float D4 = 60.0;
float D5 = 0.0;
float D6 = 0.0;

float lunghezza = 100;
float sezione = 10;

float [][] tabellaDH = new float [3][4];

color blu = color(33, 83 ,147);
color grigio = color(165, 237, 235);
color sfondo = color(165, 237, 235, 0);
color blu2 = color(165, 237, 235);
color base = color(255, 255, 255);

int done=0;

//////////////////////////////////////////////////////////////////

import processing.video.*;
import jp.nyatla.nyar4psg.*;
import processing.opengl.*;

PFont font=createFont("FFScala", 32);
Capture cam;
MultiMarker nya;

//Libreria e variabili di rete
import processing.net.*; 
Client myClient; 
String dataIn;
String [] input;
 
ArrayList<TrackData> track = new ArrayList();
//ArrayList<String> dati = new ArrayList();
ArrayList<PVector> scritta = new ArrayList<PVector>();

int count = 0;

void setup() {
  size(640,480,P3D);
  colorMode(RGB, 100);
  
  //<lista webcam pc
  String[] cameras = Capture.list();
  
  cam = new Capture(this, cameras[0]);
  //cam=new Capture(this,width,height,cameras[0]);
  nya=new MultiMarker(this,width,height,"camera_para.dat",new NyAR4PsgConfig(NyAR4PsgConfig.CS_RIGHT_HAND,NyAR4PsgConfig.TM_NYARTK));
  nya.setARClipping(100,1000);
  nya.setConfidenceThreshold(0.3);
  nya.addARMarker("patt.hiro",80);
  nya.addARMarker("patt.kanji",80);
  nya.addNyIdMarker(31,80);
  println(nya.VERSION); //バージョンの表示
  cam.start();
  
  //Connessione al server sulla porta 8080
  //myClient = new Client(this, "192.168.1.73", 1337);
  myClient = new Client(this, "192.168.43.1", 1337);
  if(myClient != null)
    print("Client connesso\n");
  
}
int c=0;
PVector p1;
PVector p10 = new PVector(0,0,0);
int aaaa= 0;
float corr;

float fc = 0.3;
void draw() {
  
  //Ricezione dati
  receiveData();
  
  
  c++;
  if (cam.available() !=true) {
    return;
  }
  background(255);
  cam.read();
  //バックグラウンドを描画
  nya.drawBackground(cam);
  nya.detect(cam);
  // marker[0]->Hero
  if(nya.isExistMarker(0)){
    nya.beginTransform(0);//マーカ座標系に設定
    {
      
      pushMatrix();
      // disegniamo il sistema di riferimento inerziale
      noStroke();
      
      tabellaDH = selectDH(robot);
      refFrame(); //R0
      
      drawRobot(tabellaDH);   
      
      popMatrix();
       
             
      if(done == 1){
        p10 = nya.screen2MarkerCoordSystem(0,int(p1.x),int(p1.y));  
        muoviRobot(p10.x, p10.y);
        follow(p10.x,p10.y,0);
        
      }
      //drawMarkerXYPos(0);
      
    }
    nya.endTransform();  //マーカ座標系を終了
    //drawMarkerPatt(0);
    //drawVertex(0);
    //マーカのスクリーン座標を中心に円を書く
    PVector p=nya.marker2ScreenCoordSystem(0,0,0,0); //prende le coord del marker e me le trasforma rispetto allo scermo
    noFill();
    fill(#FFFFFF);
    textFont(font,20.0);
    text("("+floor(getAngle(0))+"°)",p.x,p.y+40);
    //ellipse(p.x,p.y,200,200);
  }
  if(nya.isExistMarker(1)){
    nya.beginTransform(1);//マーカ座標系に設定
    {
      //drawBox(0,255,0);
      //drawMarkerXYPos(1);
      
      drawBoxMy(255,0,0);
    }
    nya.endTransform();  //マーカ座標系を終了
    //drawMarkerPatt(1);
    //drawVertex(1);
    
    
    PVector p=nya.marker2ScreenCoordSystem(1,0,0,0); //metto le coord del marker 1 in p
    noFill();
    fill(#FFFFFF);
    textFont(font,20.0);
    text("("+floor(getAngle(1))+"°)",p.x,p.y+40);
    //ellipse(p.x,p.y,200,200);
    
    p1 = p; //assegno p a p1 che uso per dare le coordinate del marker 1 al marker 0
    
  }
  if(nya.isExistMarker(2)){
    nya.beginTransform(2);//マーカ座標系に設定
    {
      
      drawBox(0,0,255);
      drawMarkerXYPos(2);
      println(nya.getLife(2));
      
    }
    nya.endTransform();  //マーカ座標系を終了
    drawMarkerPatt(2);
    drawVertex(2);
  }
  
  /*
  // sistemi a tempo discreto per rendere più fluido il movimento
  q1=q1-0.3*(q1-q1ref);
  q2=q2-0.3*(q2-q2ref);
  q3=q3-0.3*(q3-q3ref);
  q4=q4-0.3*(q4-q4ref);
  q5=q5-0.3*(q5-q5ref);
  q6=q6-0.3*(q6-q6ref);
  */
}

void stop(){
  myClient.clear();
  myClient.stop();
}

//mi restituiscono l'orientamento del marker
public float getAngle(int id){
  PVector[] i_v=nya.getMarkerVertex2D(id);
  return  -atan((i_v[1].y-i_v[0].y)/(i_v[1].x-i_v[0].x))*(180/PI); //v[] vertici del marker
}

public float getAngle2(int id){
  PVector[] i_v=nya.getMarkerVertex2D(id);
  return  -atan2((i_v[1].y-i_v[0].y),(i_v[1].x-i_v[0].x))*(180/PI);
}

//Funzioni realtà aumentata
void drawBox(int ir,int ig,int ib)
{
  pushMatrix();
  drawgrid();
  fill(ir,ig,ib);
  stroke(255,200,0);
  box(40);  
  noFill();
  translate(0,0,0);
  rect(-40,-40,80,80); 
  popMatrix();
}

void drawBoxMy(int ir,int ig,int ib)
{
  pushMatrix();
  drawgrid();
  fill(ir,ig,ib);
  stroke(255,200,0);
  
  // INIZIO LAVAGNA //
  pushMatrix();
    //translate(p10.x,p10.y,0);
    //rotateX(PI/2);
    
    float a0 = getAngle(0);//*(PI/180); //angolo marker 0
    float a1 = getAngle(1);//*(PI/180);  //angolo marker 1
    
    //println("a1: "+a1+" a0: "+a0+" diff: "+abs(a1-a0));
    //println("a1: "+abs(a1-a0)*(2*PI/360)+" a0: "+abs(a1*(2*PI/360)-a0*(2*PI/360)));
    
    float corr = abs(a1*(2*PI/360)-a0*(2*PI/360));
    //corr = corr-0.7*(corr-corrnew);
    if(a1>a0)
      rotateZ(-corr);
    else if(a1<a0)
      rotateZ(corr);
    /*
    println(aaaa);
    println(aaaa*(PI/180));
    rotateZ(aaaa*(PI/180));
    */
    
    translate(0,0,80);
  //box(40);
    //fill(255,0,0);
    stroke(#83E087,50);
    fill(#83E087,50);
    //fill(131,224,135);  
    box(1800*fc, 10, 700*fc);    
    //rect(-400, 0, 800, 600, 7);
  popMatrix();
  // FINE LAVAGNA //
  
  noFill();
  translate(0,0,0);
  rect(-40,-40,80,80); 
  popMatrix();
}

//この関数は、マーカパターンを描画します。
void drawMarkerPatt(int id)
{
  PImage p=nya.pickupMarkerImage(id,
    40,40,
    -40,40,
    -40,-40,
    40,-40,
    100,100);
//  PImage p=nya.pickupRectMarkerImage(id,-40,-40,80,80,100,100);
  image(p,id*100,0);
}

//この関数は、マーカ平面上の点を描画します。
void drawMarkerXYPos(int id)
{
  pushMatrix();
    PVector pos=nya.screen2MarkerCoordSystem(id,mouseX,mouseY);
    translate(pos.x,pos.y,0);
    noFill();
    stroke(0,0,100);
    ellipse(0,0,20-c%20,20-c%20);
  popMatrix();
}

void drawMarkerXYPosMy(int id, int id2)
{
  pushMatrix();
    PVector pos=nya.screen2MarkerCoordSystem(id,mouseX,mouseY);
    translate(pos.x,pos.y,0);
    noFill();
    stroke(0,0,100);
    ellipse(0,0,20-c%20,20-c%20);
  popMatrix();
}

//この関数は、マーカ頂点の情報を描画します。
void drawVertex(int id)
{
  PVector[] i_v=nya.getMarkerVertex2D(id);
  textFont(font,10.0);
  stroke(100,0,0);
  for(int i=0;i<4;i++){
    fill(100,0,0);
    ellipse(i_v[i].x,i_v[i].y,6,6);
    fill(0,0,0);
    text("("+i_v[i].x+","+i_v[i].y+")",i_v[i].x,i_v[i].y);
  }
}

void drawgrid()
{
  pushMatrix();
  stroke(0);
  strokeWeight(2);
  line(0,0,0,100,0,0);
  textFont(font,20.0); text("X",100,0,0);
  line(0,0,0,0,100,0);
  textFont(font,20.0); text("Y",0,100,0);
  line(0,0,0,0,0,100);
  textFont(font,20.0); text("Z",0,0,100);
  popMatrix();
}


//Funzioni robot
void drawRobot(float tab[][]){
  
  braccioDH(tab[0][0], tab[0][1], tab[0][2], tab[0][3]);
  refFrame(); //R1
  braccioDH(tab[1][0], tab[1][1], tab[1][2], tab[1][3]);
  refFrame(); //R2
  braccioDH(tab[2][0], tab[2][1], tab[2][2], tab[2][3]);
  refFrame(); //R3
  
  if(robot == 8 || robot == 9){
    braccioDH(tab[3][0], tab[3][1], tab[3][2], tab[3][3]);
    refFrame(); //R4
    braccioDH(tab[4][0], tab[4][1], tab[4][2], tab[4][3]);
    refFrame(); //R5
    braccioDH(tab[5][0], tab[5][1], tab[5][2], tab[5][3]);
    refFrame(); //R6
  }
  
}

void braccioDH(float thetaA, float dA, float alphaA, float aA){
  noStroke();   
  braccio(dA, 1);
  rotateZ(thetaA); //sarebbe Z nel sistema destrorso
  braccio(aA, 0); 
  rotateX(alphaA);
}


void braccio(float lunghezza, int asse){
  
  fill(blu2);
  noStroke();  //nessun bordo
  //pushMatrix();  //salvo il sdr
  
  fill(blu);
  sphere(sezione+5); //creo una sfera nel punto di partenza
  
  if(asse == 0){
    fill(blu2);
    translate(lunghezza/2, 0, 0);
    pushMatrix();
    rotateZ(PI/2);
    cylinder(sezione, lunghezza-sezione-5, 100);
    popMatrix();
    translate(lunghezza/2, 0, 0);
  }else{
    fill(blu2);//fill(255,102,51); //rosso chiaro
    translate(0, 0, lunghezza/2);
    pushMatrix();
    rotateX(-PI/2);
    cylinder(sezione, lunghezza-sezione-5, 100);
    popMatrix();
    translate(0, 0, lunghezza/2);
  }
  fill(blu);
  sphere(sezione+5); //creo una sfera nel punto finale

}

//scaricato da WIKI di processing, disegna un cilindro lungo l'asse y centrato nel baricentro
void cylinder(float w, float h, int sides)
{
  float angle;
  float[] x = new float[sides+1];
  float[] z = new float[sides+1];
 
  //get the x and z position on a circle for all the sides
  for(int i=0; i < x.length; i++){
    angle = TWO_PI / (sides) * i;
    x[i] = sin(angle) * w;
    z[i] = cos(angle) * w;
  }
 
  //draw the top of the cylinder
  beginShape(TRIANGLE_FAN);
 
  vertex(0, -h/2, 0);
 
  for(int i=0; i < x.length; i++){
    vertex(x[i], -h/2, z[i]);
  }
 
  endShape();
 
  //draw the center of the cylinder
  beginShape(QUAD_STRIP); 
 
  for(int i=0; i < x.length; i++){
    vertex(x[i], -h/2, z[i]);
    vertex(x[i], h/2, z[i]);
  }
 
  endShape();
 
  //draw the bottom of the cylinder
  beginShape(TRIANGLE_FAN); 
 
  vertex(0,   h/2,    0);
 
  for(int i=0; i < x.length; i++){
    vertex(x[i], h/2, z[i]);
  }
 
  endShape();
}


float [][] selectDH(int robot){
  //restituisce la matrice di DH relativa al robot scelto
  
  float [][] tabDH = {};
  switch(robot)
  { 
    case 1: // "3 DOF Planare"
    float [][] tabellaDHd={{q1,D1,0,L1},{q2,0,0,L2},{q3,0,0,L3}};
    tabDH = tabellaDHd;
    q1=0; q2=0; q3=0; q4=0; q5=0; q6=0;
    break;
    case 2: // "Robot Cartesiano"
    // moltiplichiamo per 30 le variabili di giunto di tipo trapezioidali così da renderle notabili
    float [][] tabellaDHp={{0,q1,-PI/2,0},{PI/2,q2,-PI/2,0},{0,q3,0,0}/*,{30*q4,0,-PI/2,0},{30*q5,0,PI/2,0},{30*q6,L6,0,0}*/};
    tabDH = tabellaDHp;
    //q1=2; q2=4; q3=4; q4=0; q5=0; q6=0;
    break;
    case 3: // "Robot Cilindrico"
    float [][] tabellaDHc={{q1,D1,0,0},{0,q2,-PI/2,0},{0,q3,0,0}/*,{30*q4,0,-PI/2,0},{30*q5,0,PI/2,0},{30*q6,L6,0,0}*/};
    tabDH = tabellaDHc;
    //q1=0; q2=4; q3=4; q4=0; q5=0; q6=0;
    break;
    case 4: // "Robot SCARA"
    float [][] tabellaDHs={{q1,D1,0,L1},{q2,0,0,L2},{0,30*q3,0,0}/*,{30*q4,0,-PI/2,0},{30*q5,0,PI/2,0},{30*q6,L6,0,0}*/};
    tabDH = tabellaDHs;
    q1=2; q2=0; q3=0; q4=0; q5=0; q6=0;
    break;
    case 5: // "Robot Sferico (tipo I)"
    float [][] tabellaDHt={{q1,D1,PI/2,0},{q2,0,PI/2,L2},{0,q3,0,0}/*,{30*q4,0,-PI/2,0},{30*q5,0,PI/2,0},{30*q6,L6,0,0}*/};
    tabDH = tabellaDHt;
    //q1=2; q2=0; q3=3; q4=0; q5=0; q6=0;
    break;
    case 6: // "Robot Sferico (tipo Stanford)"
    float [][]tabellaDHf={{q1,D1,-PI/2,0},{q2,D2,PI/2,0},{0,q3,0,0}};
    tabDH = tabellaDHf;
    //q1=1; q2=2; q3=3; q4=0; q5=0; q6=0;
    break;
    case 7: // "Robot Antropomorfo"
    float [][] tabellaDHa={{q1,D1,PI/2,L1},{q2,0,0,L2},{q3,0,0,L3}};
    tabDH = tabellaDHa;
    q1=1; q2=2; q3=3; q4=0; q5=0; q6=0;
    break;
    case 8: // "Robot Puma(Antopomorfo+Polso)"
    float [][] tabellaDHpuma={{q1,D1,PI/2,0},{q2,0,0,L2},{q3,0,-PI/2,0},{q4,D4,-PI/2,0},{q5,0,PI/2,0},{q6,D6,0,0}};
    tabDH = tabellaDHpuma;
    q1=1; q2=2; q3=3; q4=0; q5=0; q6=0;
    break;
    case 9: // "Robot Stanford+Polso"
    float [][] tabellaDHstanfordpolso={{q1,D1,-PI/2,0},{q2,D2,PI/2,0},{0,30*q3,0,0},{q4,D4,-PI/2,0},{q5,0,PI/2,0},{q6,D6,0,0}};
    tabDH = tabellaDHstanfordpolso;
    q1=1; q2=2; q3=3; q4=0; q5=0; q6=0;
    break;
  }
  return tabDH;
}

void refFrame(){
  stroke(255, 0, 0);
  strokeWeight(2);
  line(0, 0, 0, 40, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 40, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 40);
}

//####################FUNZIONE MOSTRA LEGENDA

void showLegend(int robot){
  
  fill(0);
  textAlign(LEFT);
  text("a: 3 DOF planare",             10,80);
  text("b: Cartesiano",                10,110);
  text("c: Cilindrico",                10,140);
  text("d: SCARA",                     10,170);
  text("e: Sferico di tipo I",         10,200);
  text("f: Sferico di tipo Stanford",  10,230);
  text("g: Antropomorfo",              10,260);
  text("h: Puma",                      10,290);
  text("i: Stanford+Polso",            10,320);
  
  
  textAlign(RIGHT);
  text("q1: "+q1, 750,80);
  text("q2: "+q2, 750,110);
  text("q3: "+q3, 750,140);
  
  if(robot == 8 || robot == 9){
    text("q4: "+q4, 750,170);
    text("q5: "+q5, 750,200);
    text("q6: "+q6, 750,230);
  }

  fill(0);
  textAlign(CENTER);
  switch (robot)
  {
    case 1 : 
      text("3 DOF Planare",330,30);
      break;
    case 2 :
      text("Robot Cartesiano",322,30);
      break;
    case 3 :
      text("Robot Cilindrico",322,30);
      break;
    case 4 :
      text("Robot SCARA",332,30);
      break;
    case 5:
      text("Robot Sferico (tipo I)",305,30);
      break;
    case 6 :
      text("Robot Sferico (tipo Stanford)",290,30);
      break;
    case 7:
      text("Robot Antropomorfo",305,30);
      break;
    case 8:
      text("Robot Puma",305,30);
      break;
    case 9:
      text("Robot Stanford+Polso",305,30);
      break;
  }
  
}

//############################FUNZIONI DI COMANDO

void keyReleased ()
{
  if (keyCode=='1') giunto=1;
  if (keyCode=='2') giunto=2;
  if (keyCode=='3') giunto=3;
  if (keyCode=='4') giunto=4;
  if (keyCode=='5') giunto=5;
  if (keyCode=='6') giunto=6;
}

void keyPressed () 
{
  // selezione del tipo di robot
  if (key=='a') {robot=1;}
  if (key=='b') {robot=2;}
  if (key=='c') {robot=3;}
  if (key=='d') {robot=4;}
  if (key=='e') {robot=5;}
  if (key=='f') {robot=6;}
  if (key=='g') {robot=7;}
  if (key=='h') {robot=8;}
  if (key=='i') {robot=9;}
  if (key=='j') {done=1;}
  if (key=='k') {done=0;}
  if (key=='l') {count = (count+1)%scritta.size();}
  //if (key=='s') {muoviRobot();}
  if (key=='n') {aaaa=aaaa+1;}
  if (key=='m') {aaaa=aaaa-1;}
  // increment o devremento delle variabili di giunto
  
  if (giunto==1) 
  {
    if (keyCode==UP) q1=q1+0.5;
    if (keyCode==DOWN) q1=q1-0.5;
  }
  if (giunto==2) 
  {
    if (keyCode==UP) q2=q2+0.5;
    if (keyCode==DOWN) q2=q2-0.5;
  }
  if (giunto==3) 
  {
    if (keyCode==UP) q3=q3+0.5;
    if (keyCode==DOWN) q3=q3-0.5;
  }
  /*
  // increment o devremento delle variabili di giunto
  if (giunto==1) 
  {
    if (keyCode==UP) q1ref=q1ref+0.1;
    if (keyCode==DOWN) q1ref=q1ref-0.1;
  }
  if (giunto==2) 
  {
    if (keyCode==UP) q2ref=q2ref+0.1;
    if (keyCode==DOWN) q2ref=q2ref-0.1;
  }
  if (giunto==3) 
  {
    if (keyCode==UP) q3ref=q3ref+0.1;
    if (keyCode==DOWN) q3ref=q3ref-0.1;
  }
  */
  if (giunto==4) 
  {
    if (keyCode==UP) q4ref=q4ref+0.1;
    if (keyCode==DOWN) q4ref=q4ref-0.1;
  }
  if (giunto==5) 
  {
    if (keyCode==UP) q5ref=q5ref+0.1;
    if (keyCode==DOWN) q5ref=q5ref-0.1;
  }
  if (giunto==6) 
  {
    if (keyCode==UP) q6ref=q6ref+0.1;
    if (keyCode==DOWN) q6ref=q6ref-0.1;
  }
}

void mousePressed () // vogliamo spostare la grafica solo quando il mouse è cliccato
{
  mouseHold=1;
  xRot0=mouseX;
  yRot0=mouseY;
}

void mouseReleased () // quando il mouse viene rilasciato blocchiamo lo spostamento
{
  mouseHold=0;
  // al successivo click del mouse ripartiamo dall'ultimo valore in modo da avere continuità
  angolo0X=angoloX;
  angolo0Y=angoloY;  
}
