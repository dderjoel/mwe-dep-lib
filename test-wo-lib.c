#include "square.h"
#include <stdio.h>

int main() {
  for (int i = 0; i < 10; i++) {
    int res = square(i);
    int check = i * i;
    printf("%d^2 = %d (check: %d)\n", i, res, check);
  }
  return 0;
}
