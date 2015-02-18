//Cinematica inversa robot
void follow(float x, float y, float z){
  /*
  if(robot ==2)
    CinInv2(x,y,z);
  */
  //movimento robot
  if(robot ==2)
    CinInv2(scritta.get(count).x,scritta.get(count).y,scritta.get(count).z);
  else if(robot == 3)
    CinInv3(scritta.get(count).x,scritta.get(count).y,scritta.get(count).z);
  else if(robot == 5)
    CinInv5(scritta.get(count).x,scritta.get(count).y,scritta.get(count).z);
  else if(robot == 6)
    CinInv6(scritta.get(count).x,scritta.get(count).y,scritta.get(count).z); 
   
   //scritta 
  for(int i=0; i<count; i++){    
    fill(0);
    stroke(255,0,0);
    strokeWeight(2);
    //se passano piu di 100 millisecondi da un punto al successivo non scrivo
    if(track.get(i+1).time - track.get(i).time < 100) {
      line(scritta.get(i).x,scritta.get(i).y,scritta.get(i).z,scritta.get(i+1).x,scritta.get(i+1).y,scritta.get(i+1).z);
    }  
  }
  
}

//Cinematica inversa cartesiano [OK]
void CinInv2(float x, float y, float z){
    
    float a1=sqrt(pow(tabellaDH[0][1],2)+pow(tabellaDH[0][3],2)); //L1
    float a2=sqrt(pow(tabellaDH[1][1],2)+pow(tabellaDH[1][3],2)); //L2
    float a3=sqrt(pow(tabellaDH[2][1],2)+pow(tabellaDH[2][3],2)); //L3  
    
    q1 = z;
    q2 = y;
    q3 = -x;
}

//Cinematica inversa cilindrico [OK]
void CinInv3(float x, float y, float z){
    
    float a1=sqrt(pow(tabellaDH[0][1],2)+pow(tabellaDH[0][3],2)); //L1
    float a2=sqrt(pow(tabellaDH[1][1],2)+pow(tabellaDH[1][3],2)); //L2
    float a3=sqrt(pow(tabellaDH[2][1],2)+pow(tabellaDH[2][3],2)); //L3  
    
    q2 = z-a1;
    q3 = sqrt(pow(x,2)+pow(y,2));
    q1 = atan2(-x/q3,y/q3);
}

//Cinematica inversa sferico [OK]
void CinInv5(float x, float y, float z){
    
  float a1=sqrt(pow(tabellaDH[0][1],2)+pow(tabellaDH[0][3],2)); //L1
  float a2=sqrt(pow(tabellaDH[1][1],2)+pow(tabellaDH[1][3],2)); //L2
  float a3=sqrt(pow(tabellaDH[2][1],2)+pow(tabellaDH[2][3],2)); //L3  
  
  q3 = sqrt(pow(x,2)+pow(y,2)+pow(z-a1,2)-pow(a2,2));
  q2 = atan2(a2*(z-a1)+q3*sqrt(pow(x,2)+pow(y,2)),q3*(a1-z)+a2*sqrt(pow(x,2)+pow(y,2)));
  q1 = atan2(y,x);
}

//Cinematica inversa stanford [OK]
void CinInv6(float x, float y, float z){
    
  float a1=sqrt(pow(tabellaDH[0][1],2)+pow(tabellaDH[0][3],2)); //L1
  float a2=sqrt(pow(tabellaDH[1][1],2)+pow(tabellaDH[1][3],2)); //L2
  float a3=sqrt(pow(tabellaDH[2][1],2)+pow(tabellaDH[2][3],2)); //L3  
  
  q3 = sqrt(pow(x,2)+pow(y,2)+pow(z-a1,2)-pow(a2,2));
  q2 = atan2(sqrt((pow(x,2)+pow(y,2)-pow(a2,2)))/q3, (z-a1)/q3);
  q1 = atan2(-x*a2+q3*sin(q2)*y, q3*sin(q2)*x+a2*y);
  
}

//con la pressione di 'ok' acquisisco la tripla x,y,tempo
void muoviRobot(float xMarker, float yMarker){
  
  //count = track.size();
  scritta = new ArrayList<PVector>();
  
  for(int i=0;i<track.size(); i++){
    
    TrackData tt = track.get(i); 
    Point pp = tt.getPoint();    // x,y punto
    
    //Ribalto la firma sul piano yz per scriverla a favore di utente
    scritta.add(new PVector((xMarker+pp.x-1000)*fc,(yMarker-20),fc*(-pp.y+700)));
    //scritta.add(new PVector(xMarker+pp.x-600,yMarker+20,-pp.y+800));
    //println("Dim scritta: "+scritta.size());
  }

}
