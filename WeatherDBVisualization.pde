//2007年1月1日～12月1日（1か月刻み）の最高気温の様子を都道府県別にヒートマップチックに表示するプログラム
//塩出研史 Kenshi Shiode <http://solt9029.com>

import de.bezier.data.sql.*;
SQLite db;

final int MONTH_NUM=12;//Jan-Dec total 12
final int PREFE_NUM=47;//the number of prefectures in Japan

int month=1;//default setting, 1(January)

PImage mapImage;

//Not a cool idea to use dim in this case, issue
float [] maxTemps;
float [] minTemps;
float [][] highestTemps;
int [] xs;
int [] ys;

void setup() {
  db=new SQLite(this, "weather.db");
  if(!db.connect()){
    exit();//hundle with exceptions of database connection
  }
  
  size(700, 755);
  mapImage=loadImage("japan_map.gif");
  
  maxTemps=new float[MONTH_NUM];
  minTemps=new float[MONTH_NUM];
  highestTemps=new float [MONTH_NUM][PREFE_NUM];
  xs=new int[PREFE_NUM];
  ys=new int[PREFE_NUM];
  
  for(int m=0; m<MONTH_NUM; m++){
    maxTemps[m]=getMaxTemp(m+1);
    minTemps[m]=getMinTemp(m+1);
    for(int p=0; p<PREFE_NUM; p++){
      highestTemps[m][p]=getHighestTemp(m+1,p+1);
    }
  }
  
  for(int p=0; p<PREFE_NUM; p++){
    xs[p]=getX(p+1);
    ys[p]=getY(p+1);
  }
}

void draw() {
  background(255);

  image(mapImage, 0, 0);
  
  float max=maxTemps[month-1];
  float min=minTemps[month-1];
  
  for(int p=0; p<PREFE_NUM; p++){
    float highest=highestTemps[month-1][p];
    float colorProp=510*((highest-min)/(max-min));
    fill(colorProp,510-colorProp,0);
    ellipse(xs[p],ys[p],20,20);
  }
  
  //display the text 
  fill(0);
  textSize(20);
  text("(2007."+month+".1) Highest Temperature Heat Map",0,30);
}

void keyPressed(){
  if(keyCode==UP && month<MONTH_NUM){
    month++;
  }
  if(keyCode==DOWN && month>1){
    month--;
  }
}


float getMaxTemp(int _month){
  String stmt="select max(highest) from weather_table,prefecture_table";
  stmt+=" where weather_table.prefecture_id=prefecture_table.id and year=2007 and month="+_month+" and day=1";
  db.query(stmt);
  while(db.next()){
    return db.getFloat("max(highest)");
  }
  return float(0);
}

float getHighestTemp(int _month, int _prefeId){
  String stmt="select highest from weather_table,prefecture_table";
  stmt+=" where weather_table.prefecture_id=prefecture_table.id and year=2007 and month="+_month+" and day=1"+" and prefecture_table.id="+_prefeId;
  db.query(stmt);
  while(db.next()){
    return db.getFloat("highest");
  }
  return float(0);
}


float getMinTemp(int _month){
  String stmt="select min(highest) from weather_table,prefecture_table";
  stmt+=" where weather_table.prefecture_id=prefecture_table.id and year=2007 and month="+_month+" and day=1";
  db.query(stmt);
  while(db.next()){
    return db.getFloat("min(highest)");
  }
  return float(0);
}

int getX(int _prefeId){
  String stmt="select * from prefecture_table";
  stmt+=" where id="+_prefeId;
  db.query(stmt);
  while(db.next()){
    return db.getInt("x");
  }
  return int(0);
}

int getY(int _prefeId){
  String stmt="select * from prefecture_table";
  stmt+=" where id="+_prefeId;
  db.query(stmt);
  while(db.next()){
    return db.getInt("y");
  }
  return int(0);
}