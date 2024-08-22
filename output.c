#include <stdio.h>

int main() {
int a;
int b = 30;
int c;
int d = 0;
int e;
int f;
a = 1 + 2;
b = 1 + 2 - 3;
c = a + 1;
d = c;
e = 30;
f = a > b;
if (a > 2) {
b = 30;
a = a + b;
}
if (b != 3) {
a = 3;
}
if (a + 1 <= 3 + 4) {
c = a + 1;
}
if (a + 2 == 71) {
d = a + 3;
}
if (23 <= d + c) {
c = a + 1;
}
if (10 <= e + f <= 100) {
c = a + 50;
}
if (b < a) {
a = b;
} else {
b = a;
}
return 0;
}
