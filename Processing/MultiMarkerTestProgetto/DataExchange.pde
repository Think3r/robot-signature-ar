char delim = '*';
void receiveData(){

  if (myClient.available() > 0) { 
    //dataIn = myClient.readStringUntil(delim);
    dataIn = myClient.readStringUntil(10);
    //if(!dataIn.equals(null)){
      println(dataIn);
      //if(dataIn.charAt(dataIn.length()-1) == '\n')
      //print(dataIn.charAt(dataIn.length()-1));
      //print(dataIn.substring(0,5));
      
      if(dataIn.equals("OK\n")) {
        print(dataIn);
        //muoviRobot();
        done = 1;
      
      } else if(dataIn.substring(0,5).equals("ROBOT")){     
        robot = int(dataIn.substring(5,6));
        print(robot);
        
      } else {
        input = split(dataIn,';');
        
        /*
        if(input[0].substring(0,1).equals('\n'))
          input[0] = input[0].substring(1);      
        */
        for(int i=0; i<input.length; i=i+3){
          if(input.length != 0){
            int x = int(input[0]);
            int y = int(input[1]);
            input[2] = split(input[2],"\n")[0];
            int t = int(input[2]);
            //print("x: "+x+"\t y: "+y+"\t time:"+t+"\n");
            
            Point p = new Point(x,y);
            track.add(new TrackData(p, t));
            
            TrackData tt = track.get(track.size()-1);
            Point pp = tt.getPoint();
            
            print("x: "+pp.x+"\t y: "+pp.y+"\t time:"+tt.time+"\n");
            print("Dim track: "+track.size()+"\n");
          }
        }
      }  
    //}  
  }
}
