/* Task Template class. Contains all major methods of a task, including 
   properties/data.
*/


/* ------------------------------------------------------------------- */
#ifndef TASK_TEMPLATE_H
#define TASK_TEMPLATE_H
/* ------------------------------------------------------------------- */

/* ------------------------------------------------------------------- */
/* Defines */
/* ------------------------------------------------------------------- */

/* ------------------------------------------------------------------- */
/* Task Template Class */
/* ------------------------------------------------------------------- */
class TaskTemplate {
 public:
  /* Standard property list */
  typedef struct properties {
    int a;
    unsigned int b;
    char c;
    int array[5];
  } properties_t;
  
  properties_t *property_list;
  properties_t property_temp;

 public:
  TaskTemplate(void);

};

TaskTemplate::TaskTemplate(){
  property_list = &property_temp;

  property_list->a = 1;
  property_list->b = 2;
  property_list->c = 5;
  property_list->array[0] = 0;
  property_list->array[0] = 2;
  property_list->array[0] = 5;
  property_list->array[0] = 4;
  property_list->array[0] = 5;
}


#endif TASK_TEMPLATE_H
