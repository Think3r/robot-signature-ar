class TrackData {
  Point point;
  int time;
  
  TrackData(Point p, int t){
    point = p;
    time = t;
  }
  
  public void setTime(int t){
    time = t;
  }
  
  public int getTime(){
    return time;
  }
  
  public void setPoint(Point p){
    point = p;
  }
  
  public Point getPoint(){
    return point;
  }
  
}

class Point {
  int x;
  int y;
  
  Point(int xx, int yy){
    x = xx;
    y = yy;
  }
  
  public int getX(){
    return x;
  }
  
  public int getY(){
    return y;
  }
  
  public void setX(int xx){
    x = xx;
  }
  
  public void setY(int yy){
    y = yy;
  }
   
}
