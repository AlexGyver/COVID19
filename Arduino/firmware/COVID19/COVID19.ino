#define DISP_WIDTH   160
#define DISP_HEIGHT  128
#define AMOUNT 100          // количество частиц
#define INFECTION_PROB 5    // вероятность заразиться
#define DANGER_ZONE 10      // размер опасной зоны
#define HOME_SIZE 8         // размер дома

// === ДЛЯ РАЗРАБОВ ===
#include <FastLED.h>
#include <Adafruit_GFX.h>    // Core graphics library
#include <Adafruit_ST7735.h> // Hardware-specific library
#include <SPI.h>
#define TFT_CS  10
#define TFT_RST 8
#define TFT_DC  9
Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

// === ДАННЫЕ ===
uint8_t posX[AMOUNT];
uint8_t posY[AMOUNT];
int8_t velX[AMOUNT];
int8_t velY[AMOUNT];
uint8_t homeX[AMOUNT];
uint8_t homeY[AMOUNT];
bool infected[AMOUNT];
byte prob = (float)INFECTION_PROB / 100 * 255;
int lastInfectedAmount = 1;
int infectedAmount = 1;
uint32_t lastTime;

void setup() {
  tft.initR(INITR_BLACKTAB);                // инициализация
  tft.setRotation(tft.getRotation() + 3);   // крутим дисп
  tft.fillScreen(ST7735_BLACK);             // чисти чисти

  for (int i = 0; i < AMOUNT; i++) {
    homeX[i] = random(0, DISP_WIDTH);
    homeY[i] = random(0, DISP_HEIGHT);
    posX[i] = homeX[i];
    posY[i] = homeY[i];
    velX[i] = random(-3, 4);
    velY[i] = random(-3, 4);
  }
  homeX[0] = DISP_WIDTH / 2;    // тут живёт пациент 0
  homeY[0] = DISP_HEIGHT / 2;
  posX[0] = homeX[0];
  posY[0] = homeY[0];
  infected[0] = true;
  tft.setTextSize(1);     // размер текста
  tft.setTextWrap(true);  // какой-то костыль для текста
}

void loop() {
  for (int i = 0; i < AMOUNT; i++) {
    if (!infected[i]) continue;
    for (int j = 0; j < AMOUNT; j++) {
      if (
        !infected[j] &&
        abs(posX[i] - posX[j]) < DANGER_ZONE &&
        abs(posY[i] - posY[j]) < DANGER_ZONE &&
        random8() < prob
      ) {
        infected[j] = true; // заразили
        infectedAmount++;   // количество зараженных +1
      }
    }
    }
  for (int i = 0; i < AMOUNT; i++) {
    // чистим старые
    tft.drawPixel(posX[i], posY[i], ST7735_BLACK);
    tft.drawPixel(posX[i] + 1, posY[i], ST7735_BLACK);
    tft.drawPixel(posX[i], posY[i] + 1, ST7735_BLACK);
    tft.drawPixel(posX[i] + 1, posY[i] + 1, ST7735_BLACK);

    //drawRect(homeX[i] - HOME_SIZE, homeY[i] - HOME_SIZE, HOME_SIZE * 2, ST7735_BLACK);      // дом
    //drawRect(posX[i] - DANGER_ZONE, posY[i] - DANGER_ZONE, DANGER_ZONE * 2, ST7735_BLACK);  // зона

    // движение по X
    int16_t thisPos = posX[i] + velX[i];
    int16_t newPos, newPos2;
    // вылет за пределы экрана
    if(thisPos < 0){// набежали пограничники
      velX[i] = -velX[i];
      newPos = -thisPos; // ((2*0) - (thisPos+0))-0
    }else if(thisPos + 1 >= DISP_WIDTH){// набежали пограничники
      velX[i] = -velX[i];
      newPos = ((2*DISP_WIDTH) - (thisPos+1)) - 1;
    }else
      newPos = thisPos;
    
    if(thisPos < homeX[i] - HOME_SIZE){// набежали полицаи
      velX[i] = -velX[i];
      newPos2 = 2*(homeX[i] - HOME_SIZE) - thisPos;
      if(newPos2<newPos){
        posX[i] = newPos2;
      }else{
        posX[i] = newPos;
      }
    }else if(thisPos + 1 >= homeX[i] + HOME_SIZE){// набежали полицаи
      velX[i] = -velX[i];
      newPos2 = ((2*(homeX[i] + HOME_SIZE)) - (thisPos+1)) - 1;
      if(newPos2>newPos){
        posX[i] = newPos2;
      }else{
        posX[i] = newPos;
      }
    }else
      posX[i] = thisPos;
    
    

    // движение по Y
    thisPos = posY[i] + velY[i];
    // вылет за пределы экрана
    if(thisPos < 0){// набежали пограничники
      velY[i] = -velY[i];
      newPos = -thisPos; // ((2*0) - (thisPos+0))-0
    }else if(thisPos + 1 >= DISP_HEIGHT){// набежали пограничники
      velY[i] = -velY[i];
      newPos = ((2*DISP_HEIGHT) - (thisPos+1)) - 1;
    }else
      newPos = thisPos;
    
    if(thisPos < homeY[i] - HOME_SIZE){// набежали полицаи
      velY[i] = -velY[i];
      newPos2 = 2*(homeY[i] - HOME_SIZE) - thisPos;
      if(newPos2<newPos){
        posY[i] = newPos2;
      }else{
        posY[i] = newPos;
      }
    }else if(thisPos + 1 >= homeY[i] + HOME_SIZE){// набежали полицаи
      velY[i] = -velY[i];
      newPos2 = ((2*(homeY[i] + HOME_SIZE)) - (thisPos+1)) - 1;
      if(newPos2>newPos){
        posY[i] = newPos2;
      }else{
        posY[i] = newPos;
      }
    }else
      posY[i] = thisPos;

    // рисуем
    tft.drawPixel(posX[i], posY[i], infected[i] ? ST7735_MAGENTA : ST7735_GREEN);
    tft.drawPixel(posX[i] + 1, posY[i], infected[i] ? ST7735_MAGENTA : ST7735_GREEN);
    tft.drawPixel(posX[i], posY[i] + 1, infected[i] ? ST7735_MAGENTA : ST7735_GREEN);
    tft.drawPixel(posX[i] + 1, posY[i] + 1, infected[i] ? ST7735_MAGENTA : ST7735_GREEN);

    //drawRect(homeX[i] - HOME_SIZE, homeY[i] - HOME_SIZE, HOME_SIZE * 2, ST7735_WHITE);    // дом
    //drawRect(posX[i] - DANGER_ZONE, posY[i] - DANGER_ZONE, DANGER_ZONE * 2, ST7735_RED);  // зона
  }

  tft.setCursor(0, 0);
  tft.setTextColor(ST7735_BLACK);
  tft.print(lastInfectedAmount);    // стираем старое количество
  lastInfectedAmount = infectedAmount;
  tft.setCursor(0, 0);
  tft.setTextColor(ST7735_GREEN);
  tft.print(infectedAmount);        // выводим актуальное

  tft.setCursor(0, 12);
  tft.setTextColor(ST7735_BLACK);
  tft.print(lastTime / 1000L);  // стираем старое время
  lastTime = millis();
  tft.setCursor(0, 12);
  tft.setTextColor(ST7735_GREEN);
  tft.print(lastTime / 1000L);      // выводим актуальное

}

void drawRect(int x, int y, int size, uint16_t color) {
  tft.drawFastHLine(x, y, size, color);
  tft.drawFastHLine(x, y + size, size + 1, color);
  tft.drawFastVLine(x, y, size, color);
  tft.drawFastVLine(x + size, y, size + 1, color);
}
