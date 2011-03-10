/* For testing out property list stuffs */
#ifndef PTEST_H
#define PTEST_H

#include "WProgram.h"
#include <PropertyList.h>


class pTest_Class {
 public:
  
  /* Vals */
  int a;
  char b;
  PropertyList p;

  /* Methods */
  pTest_Class();
  void Init();
  
};

extern pTest_Class pTest;

#endif
  
  
