int AMOUNT = 2500;                // Количество частиц
int HOME_SIZE = 12;               // Домашняя зона частицы (-1 чтобы отключить)
int ISOLATION_SIZE = 6;           // Самоизоляционная (если частица знает) зона частицы (-1 чтобы отключить)

int DANGER_ZONE = 4;              // Радиус заражения частицы
int INFECTION_PROB = 8;           // Вероятность заражения
int DEATH_PROB = 6;               // Вероятность смерти (иначе - выздоровление)
byte SHOP_AMOUNT = 2;             // Количество магазинов
int SHOP_SIZE = 120;              // Размер магазинов (длина и ширина)
int SHOP_PROB = 18;               // Процент людей, которые ходят в магазины
int TIME_IN_SHOP = 200;           // Сколько времени в магазине проводит частица
byte FAMILY_SIZE = 3;             // Средний размер семьи
int MASK_PROB = 10;               // Процент частиц, носящих  маски (они заражаются, но носят маски и не заражают других)

int measPeriod = -1;              // Продолжительность симуляции (-1 чтобы отключить)
int deadCount = 1500;             // Смерть/выздоровление заражённого через (-1 чтобы отключить) 
int infectTime = 800;             // Время, через которое пациент узнает, что он болен 

int fps = 60;                     // FPS симуляции
boolean emoji = false;            // Эмодзи вместо точек (папка img)
boolean immunity_bool = true;     // Приобретается ли иммунитет после выздоровления?
String log_name = "";             // Имя логов? Если "", то название автоматическое

int objSize = 9;                  // Диаметр частицы
int windowW = 1600;               // Ширина окна программы
int windowH = 900;                // Высота окна программы
int marginR = 300;                // Ширина информации справа
int graph_time = 20;              // Как часто снимать показания зараженных


// Переменыые разработчика
int time = 0; // Время симуляции (ВСЕ ВРЕМЯ В ПРОГРАММЕ ИЗМЕРЯЕТСЯ В ЦИКЛАХ)
int infectedAmount = 1; // Количество зараженных
int deadAmount = 0;// Количество умерших
int immunityAmount = 0; // Количество переболевших (с имунитетом)
int lastInfectedAmount = 0;
int border = 10;
int minPos = border+objSize/2;
int maxPosY = windowH-border-objSize/2;
int maxPosX = windowW-marginR-objSize/2;
int plotCount = 0;
int value = 0;
boolean pause = false;
String keyboard = "";

int[] homeX = new int[AMOUNT];
int[] homeY = new int[AMOUNT];
int[] homeX_start = new int[AMOUNT];
int[] homeY_start = new int[AMOUNT];
int[] homeSize = new int[AMOUNT];

float[] velX = new float[AMOUNT];
float[] velY = new float[AMOUNT];
float[] posX = new float[AMOUNT];
float[] posY = new float[AMOUNT];

int[] shopsX = new int[SHOP_AMOUNT];
int[] shopsY = new int[SHOP_AMOUNT];

int[] ill_time = new int[AMOUNT];
int[] shop_time = new int[AMOUNT];
int[] shop_time_need = new int[AMOUNT];
int[] resource = new int[AMOUNT];

boolean[] dead = new boolean[AMOUNT];
boolean[] infected = new boolean[AMOUNT];
boolean[] immunity = new boolean[AMOUNT];
boolean[] in_shop = new boolean[AMOUNT];
boolean[] mask_bool = new boolean[AMOUNT];

PFont Font1;
PImage mask;
PImage virus;
PrintWriter logs;
PrintWriter config;

import controlP5.*;
ControlP5 cp5;


void settings() {
  size(windowW, windowH);
  smooth(7);    // сглаживание
}

void setup() {  
  frameRate(fps);
  background(#ffffff);
  Font1 = createFont("Noto Sans", 18);
  textFont(Font1);
  strokeWeight(3);

  // Добавляем элементы управления
  cp5 = new ControlP5(this);

  fill(#621cf2);
  text("Домашняя зона:", windowW - marginR + border, 135);
  cp5.addSlider("0").setPosition(maxPosX + 15, 140).setSize(marginR - 30, 30).setFont(Font1).setRange(-1, 50).setValue(HOME_SIZE).setId(0);  

  fill(#ff0055);
  text("Зона заражения:", windowW - marginR + border, 190);
  cp5.addSlider("1").setPosition(maxPosX + 15, 195).setSize(marginR - 30, 30).setFont(Font1).setRange(0, 20).setValue(DANGER_ZONE).setId(1);

  fill(#ff0000);
  text("Вероятность заражения:", windowW - marginR + border, 245); 
  cp5.addSlider("2").setPosition(maxPosX + 15, 250).setSize(marginR - 30, 30).setFont(Font1).setRange(0, 30).setValue(INFECTION_PROB).setId(2);

  fill(#000000);
  text("Вероятность смерти:", windowW - marginR + border, 300);
  cp5.addSlider("3").setPosition(maxPosX + 15, 305).setSize(marginR - 30, 30).setFont(Font1).setRange(0, 30).setValue(DEATH_PROB).setId(3);

  fill(#000000);
  text("Зона самоизоляции:", windowW - marginR + border, 355);
  cp5.addSlider("4").setPosition(maxPosX + 15, 360).setSize(marginR - 30, 30).setFont(Font1).setRange(0, 30).setValue(ISOLATION_SIZE).setId(4);

  fill(#000000);
  text("Процент ходящих в \"магазины\":", windowW - marginR + border, 410);
  cp5.addSlider("5").setPosition(maxPosX + 15, 415).setSize(marginR - 30, 30).setFont(Font1).setRange(0, 40).setValue(SHOP_PROB).setId(5);

  fill(#000000);
  text("Время в магазине:", windowW - marginR + border, 465);
  cp5.addSlider("6").setPosition(maxPosX + 15, 470).setSize(marginR - 30, 30).setFont(Font1).setRange(0, 500).setValue(TIME_IN_SHOP).setId(6);

  fill(#000000);
  text("Время смерти/выздоровления:", windowW - marginR + border, 520);
  cp5.addSlider("7").setPosition(maxPosX + 15, 525).setSize(marginR - 30, 30).setFont(Font1).setRange(0, 3000).setValue(deadCount).setId(7);

  fill(#ff8a32);
  text("Узнать о болезни через:", windowW - marginR + border, 575);
  cp5.addSlider("8").setPosition(maxPosX + 15, 580).setSize(marginR - 30, 30).setFont(Font1).setRange(0, 2000).setValue(infectTime).setId(8);

  fill(#000000);
  text("Строить график каждые:", windowW - marginR + border, 630);
  cp5.addSlider("9").setPosition(maxPosX + 15, 635).setSize(marginR - 30, 30).setFont(Font1).setRange(10, 200).setValue(graph_time).setId(9);
  
  fill(#3e97ff);
  text("Процент носящих маски:", windowW - marginR + border, 685);
  cp5.addSlider("10").setPosition(maxPosX + 15, 690).setSize(marginR - 30, 30).setFont(Font1).setRange(0, 80).setValue(MASK_PROB).setId(10);

  if (emoji) {
    mask = loadImage("img/mask.png");
    virus = loadImage("img/virus.png");
  }

  noStroke();
  if (HOME_SIZE == -1) HOME_SIZE = max(windowW, windowH);

  for (int i = 0; i < AMOUNT; i++) {
    velX[i] = random(-0.9, 0.9);
    velY[i] = random(-0.9, 0.9);

    shop_time_need[i] = (int)(random(0.6, 1.4)*TIME_IN_SHOP);

    if (SHOP_AMOUNT > 0) resource[i] = (int)random(0, 1000);
    immunity[i] = false;
    infected[i] = false;
  }

  for (int i = 0; i < AMOUNT; i+=FAMILY_SIZE) {
    int homeX_t = (int)random(border+objSize, maxPosX-objSize);
    int homeY_t = (int)random(border+objSize, maxPosY-objSize);

    boolean mask_fam_bool = random(100) < MASK_PROB;

    for (int j = 0; j < FAMILY_SIZE; j++) {
      int k = i+j;
      if (k < AMOUNT) {
        homeX[k] = homeX_t;
        homeY[k] = homeY_t;

        homeX_start[k] = homeX[k];
        homeY_start[k] = homeY[k];

        homeSize[k] = HOME_SIZE;

        posX[k] = homeX[k];
        posY[k] = homeY[k];

        mask_bool[k] = mask_fam_bool;
      }
    }
  }

  for (byte i = 0; i < SHOP_AMOUNT; i++) {
    shopsX[i] = (int)random(border+SHOP_SIZE, maxPosX-SHOP_SIZE);
    shopsY[i] = (int)random(border+SHOP_SIZE, maxPosY-SHOP_SIZE);
  }

  infected[0] = true;

  if (SHOP_AMOUNT > 0) {
    for (int j = 0; j < FAMILY_SIZE; j++) {
      homeX[j] = shopsX[0]; // Торговка летучими мышами на рынке
      homeY[j] = shopsY[0];
      posX[j] = homeX[j];
      posY[j] = homeY[j];
    }
  }

  if (log_name == "") {
    log_name = loadStrings("config.txt")[0];
    config = createWriter("config.txt");
    config.println(str(int(log_name)+1));
    config.flush();
  }

  logs = createWriter("logs/log"+log_name+".csv");
  logs.println("\"time\",\"infectedAmount\",\"deadAmount\",\"immunityAmount\",\"deltaInfectedAmount\"");
  logs.flush();
}

void keyPressed() {
  if (keyCode == 32) pause = !pause; // Пробел - пауза
}

void draw() {
  if (!pause) {
    stroke(#000000);  
    fill(#ffffff);
    rect(border, border, windowW-border - marginR, windowH-border*2); // Прямоугольник с частицами закрашиваем белым
    noStroke();
    moveObj(); // Двигаем частицы и инфо
  } else { // Если пауза нарисуем ее значок
    stroke(#505050);
    line(2*border, 2*border, 2*border, 2*border+20);  
    line(2*border+10, 2*border, 2*border+10, 2*border+20);
  }
}

void moveObj() {  
  // передача вируса
  for (int i = 0; i < AMOUNT; i++) {
    if (dead[i]) continue;

    if (SHOP_AMOUNT > 0) {
      if (resource[i] < 0) { // Частица в магазине
        if (shop_time[i] == 0) { // Частица только зашла в магазин (Выбор магазина - изменение координаты)
          if (random(100) < SHOP_PROB) {
            byte shop_num = (byte)random(SHOP_AMOUNT);
            in_shop[i] = true;
            homeX[i] = shopsX[shop_num];
            homeY[i] = shopsY[shop_num];
            posX[i] = homeX[i] + (int)random(-SHOP_SIZE/2, SHOP_SIZE/2);
            posY[i] = homeY[i] + (int)random(-SHOP_SIZE/2, SHOP_SIZE/2);
            homeSize[i] = SHOP_SIZE/2;
          } else {
            resource[i] = (int)random(200, 1500);
          }
        }
        if (in_shop[i] && ++shop_time[i]  == shop_time_need[i]) { // Частица полностью закупилась
          resource[i] = (int)random(200, 1500);
          shop_time_need[i] = (int)(random(0.6, 1.4)*TIME_IN_SHOP);
          shop_time[i] = 0;
          homeX[i] = homeX_start[i];
          homeY[i] = homeY_start[i];
          posX[i] = homeX[i];
          posY[i] = homeY[i];
          homeSize[i] = HOME_SIZE;
          in_shop[i] = false;
        }
      } else { // Частица тратит ресурс дома
        resource[i]--;
      }
    }

    if (!infected[i]) continue; // Если жив и не инфецирован продолжаем

    if (!mask_bool[i]) {
      for (int j = 0; j < AMOUNT; j++) { // Заражаем "всех" вокруг
        if (!infected[j] && !immunity[j] && !dead[j] && abs(posX[i] - posX[j]) < DANGER_ZONE && abs(posY[i] - posY[j]) < DANGER_ZONE && (int)random(100-INFECTION_PROB) == 0) {
          infected[j] = true;
          infectedAmount++;
        }
      }
    }

    if (deadCount > 0 && ++ill_time[i] > deadCount) { // Возможная смерть/выздоровление
      if (random(100) < DEATH_PROB) {
        if (deadCount > 0) { // Если разрешено умирать
          dead[i] = true;
          deadAmount++;
          infected[i] = false;
          infectedAmount--;
        }
      } else {
        infected[i] = false;
        infectedAmount--;
        ill_time[i] = 0;
        if (immunity_bool) {
          immunity[i] = true; 
          immunityAmount++;
        }
      }
    }

    if (!dead[i] && ill_time[i] > infectTime) {
      homeSize[i] = ISOLATION_SIZE;
    }
  }

  // движение
  for (int i = 0; i < AMOUNT; i++) {
    // Изменяем координату по X
    float thisPos = posX[i] + velX[i];
    if (thisPos < minPos || thisPos < (homeX[i] - homeSize[i]) || thisPos >= maxPosX || thisPos > (homeX[i] + homeSize[i])) velX[i] = -velX[i];
    else posX[i] = thisPos;

    // Изменяем координату по Y
    thisPos = posY[i] + velY[i];
    if (thisPos < minPos || thisPos < (homeY[i] - homeSize[i]) || thisPos >= maxPosY || thisPos > (homeY[i] + homeSize[i])) velY[i] = -velY[i];
    else posY[i] = thisPos;
  }  

  // Отрисовка магазинов
  stroke(#0885f9);  
  fill(#ffffff);
  for (byte i = 0; i < SHOP_AMOUNT; i++) {
    rect(shopsX[i]-SHOP_SIZE/2, shopsY[i]-SHOP_SIZE/2, SHOP_SIZE, SHOP_SIZE); // Прямоугольник с частицами
  }
  noStroke();

  // Отрисовка частиц
  fill(#505050);
  for (int i = 0; i < AMOUNT; i++) {
    if (emoji) {
      if (infected[i]) image(virus, posX[i]-objSize/2, posY[i]-objSize/2, objSize, objSize);
      else image(mask, posX[i]-objSize/2, posY[i]-objSize/2, objSize, objSize);
    } else {
      if (infected[i]) fill(#ff0000);
      else if (immunity[i]) fill(#00ff00);
      else if (mask_bool[i]) fill(#3e97ff);
      else fill(#505050);
      if (!dead[i]) circle(posX[i], posY[i], objSize);
    }
  }

  time++;
  if (time % graph_time == 0) { // Здесь мы выводим информацию о кол-ве зараженных (график) + логи
    //stroke(#ffffff);
    //line(maxPosX + 2*border, 140+plotCount*4, maxPosX + 2*border +(float)(marginR - 2*border), 140+plotCount*4);   
    //stroke(#505050);
    //line(maxPosX + 2*border, 140+plotCount*4, maxPosX + 2*border +(float)(marginR - 2*border)*infectedAmount/AMOUNT, 140+plotCount*4);  
    //noStroke();
    plotCount++;
    if (4*plotCount > (windowH-160)) plotCount = 0;

    logs.println(str(time)+","+str(infectedAmount)+","+str(deadAmount)+","+str(immunityAmount)+","+str(infectedAmount-lastInfectedAmount));
    lastInfectedAmount = infectedAmount;
    logs.flush();
  }

  fill(#ffffff);
  rect(windowW - marginR + border, 0, marginR, 105); // Очищаем поле для информации

  fill(#ff0000);
  text("Больные:", windowW - marginR + border, 25); // "Инфецированные"
  text(infectedAmount, windowW - marginR+90+border, 25); // Их количество

  fill(#505050);
  text("Умершие:", windowW - marginR + border, 50); // "Умершие"
  text(deadAmount, windowW - marginR+100+border, 50); // Их количество

  fill(#00ff00);
  text("Вылечившиеся:", windowW - marginR + border, 75); // "Вылечившиеся"
  text(immunityAmount, windowW - marginR+150+border, 75); // Их количество

  fill(#0000ff);
  text("Время:", windowW - marginR + border, 100); // "Время"
  text(time, windowW - marginR + border + 70, 100);

  if (time == measPeriod) for (;; ); // Тупо зацикливание
  if (infectedAmount == 0 || infectedAmount+deadAmount == AMOUNT) for (;; );
}

void controlEvent(ControlEvent theEvent) {
  switch(theEvent.getController().getId()) {
    case(0):
    HOME_SIZE = (int)(theEvent.getController().getValue());
    if (theEvent.getController().getValue() < 0) HOME_SIZE = max(windowW, windowH);

    for (int i =0; i<AMOUNT; i++) {
      homeSize[i] = HOME_SIZE;
    }
    break;
    case(1): 
    DANGER_ZONE = (int)(theEvent.getController().getValue()); 
    break;
    case(2): 
    INFECTION_PROB = (int)(theEvent.getController().getValue()); 
    break;
    case(3): 
    DEATH_PROB = (int)(theEvent.getController().getValue()); 
    break;
    case(4): 
    ISOLATION_SIZE = (int)(theEvent.getController().getValue()); 
    break;
    case(5): 
    SHOP_PROB = (int)(theEvent.getController().getValue()); 
    break;
    case(6): 
    TIME_IN_SHOP = (int)(theEvent.getController().getValue()); 
    break;
    case(7): 
    deadCount = (int)(theEvent.getController().getValue()); 
    break;
    case(8): 
    infectTime = (int)(theEvent.getController().getValue()); 
    break;
    case(9): 
    graph_time = (int)(theEvent.getController().getValue()); 
    break;
    case(10): 
    MASK_PROB = (int)(theEvent.getController().getValue()); 

    for (int i = 0; i < AMOUNT; i+=FAMILY_SIZE) {
      boolean mask_fam_bool = random(100) < MASK_PROB;

      for (int j = 0; j < FAMILY_SIZE; j++) {
        int k = i+j;
        if (k < AMOUNT) mask_bool[k] = mask_fam_bool;
      }
    }
    break;
  }
}
