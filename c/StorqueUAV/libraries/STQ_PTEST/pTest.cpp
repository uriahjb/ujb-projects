/* CPP tester */

#include "WProgram.h"
#include <IOManager.h>
#include "pTest.h"

pTest_Class::pTest_Class(): p(3, "Test") {};

void pTest_Class::Init(){

  /*
  int len_a = 3;
  a = (int*)malloc(len_a*sizeof(int));
  a[0] = 1;
  a[1] = 1;
  a[2] = 2;
  */

  a = 1;
  b = 'b';

  p.Set(0, Int, 1, &a, "a");
  p.Set(1, Char, 1, &b, "b");
  
  IOManager.Append(&p);
}

pTest_Class pTest;
  
