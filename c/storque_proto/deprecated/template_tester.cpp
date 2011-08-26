/* -------------------------------------------------------------------- */
/* 
   Testing out templates ... trying to make a single heterogenous data type
   container for storque 'sensors'

   note: this is written by following Pete Becker's 'Containing ..
   .. Heterogenous Data Types' from The C/C++ Users Journal, Dec, 1999
   
   note: The containers need refinement, and need to be applying to 
         the Storque specific implementation ... but its a start!!
*/
/* -------------------------------------------------------------------- */

/* -------------------------------------------------------------------- */
/* Don't forget includes */
/* -------------------------------------------------------------------- */
#include <stdlib.h>
#include <iostream>

using namespace std;

/* -------------------------------------------------------------------- */
/* Define general type class, all types derived from it */
/* -------------------------------------------------------------------- */
class ident {
public:
  virtual ~ident() {}
};

/* -------------------------------------------------------------------- */
/* Define different types */
/* -------------------------------------------------------------------- */

/* Char  Type */
class char_val : public ident {
public:
  char_val(char i) : val(i) {}
  char get() { return val; }
private:
  char val;
};

/* Integer Type */
class int_val : public ident {
public:
  int_val(int i) : val(i) {}
  int get() { return val; }
private:
  int val;
};

/* Long Type */
class long_val : public ident {
public:
  long_val(long i) : val(i) {}
  long get() { return val; }
private:
  long val;
};

/* Float Type */
class float_val : public ident {
public:
  float_val(float i) : val(i) {}
  float get() { return val; }
private:
  float val;
};

/* Double  Type */
class double_val : public ident {
public:
  double_val(float i) : val(i) {}
  double get() { return val; }
private:
  double val;
};


/* -------------------------------------------------------------------- */
/* Define (void *) typesafe array and container */
/* -------------------------------------------------------------------- */
template<size_t sz> class void_array {
protected:
  void_array() : num(0) {}
  void add(void *obj) { if (num != sz) items[++num] = obj; }
  void *operator[](int pos) { return num <= pos ? 0 : items[pos]; }
private:
  int num;
  void *items[sz];
};

template<class T, size_t sz> class void_container : private void_array<sz> {
public:
  void add(T *obj) { return void_array<sz>::add(obj); } 
  T *operator[](int pos){
    return static_cast<T*>(void_array<sz>::operator[](pos));
  }
};

class property_list {
public:
  void add(char_val *cv) {data.add(cv);}
  /*  void add(int_val *iv) {data.add(iv);}
  void add(long_val *lv) {data.add(lv);}
  void add(float_val *fv) {data.add(fv);}
  void add(double_val *dv) {data.add(dv);}*/
  
  //ident *operator[](int pos){ return dynamic_cast<ident*>(data[pos]); }
  
  
  //  char_val *operator[](int pos){ return dynamic_cast<char_val*>(data[pos]); }
  char_val *operator[](int pos){ return (char_val*)(data[pos]); }
  //int_val *operator[](int pos){ return dynamic_cast<int_val*>(data[pos]); }
  

private:
  void_container<ident, 10> data;
};



/* -------------------------------------------------------------------- */
/* Test this stuff */
/* -------------------------------------------------------------------- */
int main(){
  
  property_list p;

  char_val c = 'i';
  int_val i = 4;
  long_val l = 45;
  float_val f = 3.3;
  double_val d = 4.44;

  p.add(&c);
  //p.add(&i);
  //p.add(&l);
  //p.add(&f);
  //p.add(&d);
  
  cout << p[0] << endl;
  /*  int j;
  for (j = 0; j < 5; ++j){
    cout << p[j] << endl;
    }*/
}
