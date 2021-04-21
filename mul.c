#include "add.h"

int mul(int f1, int f2) {

  int result = 0;

  while (f1--) {
    result = add(result, f2);
  }
  return result;
}
