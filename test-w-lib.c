#include <dlfcn.h>
#include <stdio.h>

int main() {
  void *handle = dlopen("./libsquare.so", RTLD_NOW);
  int (*sq)(int) = dlsym(handle, "square");
  if (sq == NULL) {
    printf("square not found in lib");
  }

  for (int i = 0; i < 10; i++) {
    int res = sq(i);
    int check = i * i;
    printf("%d^2 = %d (check: %d)\n", i, res, check);
  }

  dlclose(handle);
}
