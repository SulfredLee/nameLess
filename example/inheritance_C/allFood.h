#include "food.h"

typedef struct{
    printNameFun printName;
    int nNumber;
} apple;

food* createApple();

typedef struct{
    printNameFun printName;
    int nPrice;
} orange;

food* createOrange();
