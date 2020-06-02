int AMOUNT = 500;        // количество частиц
int HOME_SIZE = 25;       // домашняя зона частицы
int DANGER_ZONE = 10;      // зона заражения частицы
int INFECTION_PROB = 40;  // вероятность заражения

int measPeriod = -1;      // продолжительность симуляции (-1 чтобы отключить)
int deadCount = -1;       // смерть заражённого через (-1 чтобы отключить) 
int fps = 300;            // скорость симуляции
int randomMoving = 0;     // случайные перемещения заражённых (1 вкл, 0 выкл)
int checkResource = 0;    // проверка ресурса (1 вкл, 0 выкл)
int emoji = 1;            // эмодзи вместо точек (1 вкл, 0 выкл)

int objSize = 5;      // размер частицы
int windowW = 800;    // ширина окна программы
int windowH = 600;    // высота окна программы


// разраб
int time = 0;
int infectedAmount = 1;
int deadAmount = 0;
int lastInfectedAmount = 0;
int border = 10;
int minPos = border+objSize/2;
int maxPos = windowH-border-objSize/2-emoji*objSize*5;
int plotCount = 0;

int[] homeX = new int[AMOUNT];
int[] homeY = new int[AMOUNT];
float[] velX = new float[AMOUNT];
float[] velY = new float[AMOUNT];
float[] posX = new float[AMOUNT];
float[] posY = new float[AMOUNT];
int[] count = new int[AMOUNT];
boolean[] dead = new boolean[AMOUNT];
boolean[] infected = new boolean[AMOUNT];
int[] resource = new int[AMOUNT];

PFont Font1;
PImage mask;
PImage virus;


void settings() {
  size(windowW, windowH);
  smooth(8);    // сглаживание
}

void setup() {  
  frameRate(fps);
  background(#ffffff);
  mask = loadImage("mask.png");
  virus = loadImage("covirus.png");
  noStroke();
  infected[0] = true;
  for (int i = 0; i < AMOUNT; i++) {
    velX[i] = random(-0.5, 0.5);
    velY[i] = random(-0.5, 0.5);
    homeX[i] = (int)random(border+objSize, windowH-border*2-objSize*2);
    homeY[i] = (int)random(border+objSize, windowH-border*2-objSize*2);
    posX[i] = homeX[i];
    posY[i] = homeY[i];
    resource[i] = (int)random(200, 1500);
  }
  homeX[0] = (int)(border+objSize + (windowH-border*2-objSize*2)/2);
  homeY[0] = (int)(border+objSize + (windowH-border*2-objSize*2)/2);
  posX[0] = homeX[0];
  posY[0] = homeY[0];
  Font1 = createFont("Arial Bold", 18);
  textFont(Font1);
  strokeWeight(3);
}

void draw() {  
  //background(#ffffff);  // стереть фон
  stroke(#000000);  
  fill(#ffffff);
  rect(border, border, windowH-border*2, windowH-border*2);  
  noStroke();
  moveObj();
}

void moveObj() {

  // передача вируса
  for (int i = 0; i < AMOUNT; i++) {
    if (checkResource == 1) {
      resource[i]--;
      if (resource[i] < 0) dead[i] = true;
    }
    if (!infected[i] || dead[i]) continue;
    for (int j = 0; j < AMOUNT; j++) {
      if (
        !infected[j] &&
        abs(posX[i] - posX[j]) < DANGER_ZONE &&
        abs(posY[i] - posY[j]) < DANGER_ZONE && 
        (int)random(100-INFECTION_PROB) == 0
        ) {
        infected[j] = true;
        infectedAmount++;
      }
    }

    if (deadCount > 0) {
      if (++count[i] < deadCount) {
        count[i]++;
      } else {
        dead[i] = true;
        deadAmount++;
      }
    }
  }

  // движение
  for (int i = 0; i < AMOUNT; i++) {
    if (randomMoving == 1 && infected[i] && (int)random(12000) == 0) {
      homeX[i] = (int)random(border+objSize, windowH-border*2-objSize*2);
      homeY[i] = (int)random(border+objSize, windowH-border*2-objSize*2);
      posX[i] = homeX[i];
      posY[i] = homeY[i];
    }

    //posX[i] = homeX[i] + (int)((noise(i*2, counter)-0.5) * HOME_SIZE);
    //posY[i] = homeY[i] + (int)((noise(i*2+1.0, counter)-0.5) * HOME_SIZE);
    //posX[i] = constrain(posX[i], minPos, maxPos);
    //posY[i] = constrain(posY[i], minPos, maxPos);
    // движение по X
    float thisPos = posX[i] + velX[i];
    if (thisPos < minPos || thisPos < (homeX[i] - HOME_SIZE) ||
      thisPos >= (maxPos-objSize) || thisPos > (homeX[i] + HOME_SIZE))
      velX[i] = -velX[i];
    else
      posX[i] = thisPos;

    // движение по Y
    thisPos = posY[i] + velY[i];
    if (thisPos < minPos || thisPos < (homeY[i] - HOME_SIZE) ||
      thisPos >= (maxPos-objSize) || thisPos > (homeY[i] + HOME_SIZE))
      velY[i] = -velY[i];
    else
      posY[i] = thisPos;
  }  

  // отрисовка
  fill(#505050);
  for (int i = 0; i < AMOUNT; i++) {
    if (emoji == 0) {
      if (infected[i]) fill(#ff0000);
      else fill(#505050);
      if (!dead[i]) circle(posX[i], posY[i], objSize);
    } else {
      if (infected[i]) image(virus, posX[i], posY[i], objSize*5, objSize*5);
      else image(mask, posX[i], posY[i], objSize*5, objSize*5);
    }
  }
  time++;
  if (time % 50 == 0) { 
    //println(infectedAmount);    
    stroke(#505050);
    line(windowH, 80+plotCount*4, windowH+(float)150*infectedAmount/AMOUNT, 80+plotCount*4);   
    noStroke();
    plotCount++;
  }

  fill(#ffffff);
  rect(windowH, 0, windowH+150, 65);
  fill(#505050);
  text("infected:", windowH, 30);
  text(infectedAmount-deadAmount, windowH+80, 30);

  fill(#0000ff);
  text("time:", windowH, 60);
  text(time, windowH+50, 60);

  if (time == measPeriod) for (;; );
  if (infectedAmount == AMOUNT) for (;; );
}
