// #ifndef FOOD_H
// #define

typedef void (*printNameFun)(const char* strIN);

typedef struct{
    printNameFun printName;
} food;
// #endif
