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


int sup_sum(boolean[] array) {
  int summ = 0;
  for (int i = 0; i < AMOUNT; i++) {
    if (array[i]) {
      summ++;
    }
  }
  return summ;
}

void settings() {
  size(windowW, windowH);
  smooth(7);    // сглаживание
}

void setup() {  
  frameRate(fps);
  background(#ffffff);

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

    if (SHOP_AMOUNT > 0) resource[i] = (int)random(200, 1500);
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

  Font1 = createFont("Noto Sans", 18);
  textFont(Font1);
  strokeWeight(3);

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

void keyPressed() {  // Обновление команды
  if (keyCode == 16) {
  } else if (key == '\n') { // Если Enter - обрабатываем команду
    if (keyboard.length() > 5 && keyboard.substring(0, 4).equals("home")) {
      HOME_SIZE = int(keyboard.substring(5));
      for (int i =0; i<AMOUNT; i++) {
        homeSize[i] = HOME_SIZE;
      }
    } else if (keyboard.length() > 6 && keyboard.substring(0, 5).equals("dzone")) {
      DANGER_ZONE = int(keyboard.substring(6));
    } else if (keyboard.length() > 6 && keyboard.substring(0, 5).equals("infec")) {
      INFECTION_PROB = int(keyboard.substring(6));
    } else if (keyboard.length() > 6 && keyboard.substring(0, 5).equals("death")) {
      DEATH_PROB = int(keyboard.substring(6));
    } else if (keyboard.length() > 7 && keyboard.substring(0, 6).equals("isolat")) {
      ISOLATION_SIZE = int(keyboard.substring(7));
    } else if (keyboard.length() > 7 && keyboard.substring(0, 6).equals("shop_p")) {
      SHOP_PROB = int(keyboard.substring(7));
    } else if (keyboard.length() > 10 && keyboard.substring(0, 9).equals("time_shop")) {
      TIME_IN_SHOP = int(keyboard.substring(10));
    } else if (keyboard.length() > 10 && keyboard.substring(0, 9).equals("dead_time")) {
      deadCount = int(keyboard.substring(10));
    } else if (keyboard.length() > 11 && keyboard.substring(0, 10).equals("infec_time")) {
      infectTime = int(keyboard.substring(11));
    } else if (keyboard.length() > 11 && keyboard.substring(0, 10).equals("graph_time")) {
      graph_time = int(keyboard.substring(11));
    } else if (keyboard.length() > 10 && keyboard.substring(0, 9).equals("mask_prob")) {
      MASK_PROB = int(keyboard.substring(10));

      for (int i = 0; i < AMOUNT; i+=FAMILY_SIZE) {
        boolean mask_fam_bool = random(100) < MASK_PROB;

        for (int j = 0; j < FAMILY_SIZE; j++) {
          int k = i+j;
          if (k < AMOUNT) mask_bool[k] = mask_fam_bool;
        }
      }
    }

    keyboard = ""; // Обнуляем команду
  } else if  (keyCode == 8) { // Backspace
    keyboard = keyboard.substring(0, keyboard.length()-1);
  } else { // Добавляем кнопку
    keyboard += key;
  }
}

void draw() {
  stroke(#000000);  
  fill(#ffffff);
  rect(border, border, windowW-border - marginR, windowH-border*2); // Прямоугольник с частицами
  noStroke();
  moveObj(); // Двигаем частицы и инфо
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
    stroke(#ffffff);
    line(maxPosX + 2*border, 140+plotCount*4, maxPosX + 2*border +(float)(marginR - 2*border), 140+plotCount*4);   
    stroke(#505050);
    line(maxPosX + 2*border, 140+plotCount*4, maxPosX + 2*border +(float)(marginR - 2*border)*infectedAmount/AMOUNT, 140+plotCount*4);  
    noStroke();
    plotCount++;
    if (4*plotCount > (windowH-160)) plotCount = 0;

    logs.println(str(time)+","+str(infectedAmount)+","+str(deadAmount)+","+str(immunityAmount)+","+str(infectedAmount-lastInfectedAmount));
    lastInfectedAmount = infectedAmount;
    logs.flush();
  }

  fill(#ffffff);
  rect(windowW - marginR + border, 0, marginR, 130); // Очищаем поле для информации

  fill(#666666);
  text("Команда:", windowW - marginR + border, 25); // "Команда"
  text(keyboard, windowW - marginR+90+border, 25); // Команда

  fill(#ff0000);
  text("Больные:", windowW - marginR + border, 50); // "Инфецированные"
  text(infectedAmount, windowW - marginR+90+border, 50); // Их количество

  fill(#505050);
  text("Умершие:", windowW - marginR + border, 75); // "Умершие"
  text(deadAmount, windowW - marginR+100+border, 75); // Их количество

  fill(#00ff00);
  text("Вылечившиеся:", windowW - marginR + border, 100); // "Вылечившиеся"
  text(immunityAmount, windowW - marginR+150+border, 100); // Их количество

  fill(#0000ff);
  text("Время:", windowW - marginR + border, 125); // "Время"
  text(time, windowW - marginR + border + 70, 125);

  if (time == measPeriod) for (;; ); // Тупо зацикливание
  if (infectedAmount == 0 || infectedAmount+deadAmount == AMOUNT) for (;; );
}
