---
layout: post
title: "RITSEC CTF: CictroHash write-up"
date: 2018-11-18
excerpt: "Combining Python and C to write a sponge function and then brute-forcing a collision. Had you ever seen that? I hadn't..."
tags: [Crypto, Python, C]
categories: [CTF, Cryptography]
comments: true
feature: /assets/posts_details/RITSECCTF/sponge.png
---

# RITSEC CTF: CictroHash write-up

![Img](/assets/posts_details/RITSECCTF/description.png "img")

After having a look at the attached [pdf file](/assets/posts_details/RITSECCTF/description.pdf) we can clearly see that we need to implement a sponge function, which includes XORs and a function <i>f</i> that is comprised of four composite functions. So I'll start by writing the four functions first.

*Visual representation of the sponge function*

![Img](/assets/posts_details/RITSECCTF/sponge.png "img")

*Mathematical definition of <i>f</i>*

![Img](/assets/posts_details/RITSECCTF/function1.png "img")

![Img](/assets/posts_details/RITSECCTF/function2.png "img")

## Functions

All of them will have as an argument a matrix of 2x4, as defined in the PDF:

![Img](/assets/posts_details/RITSECCTF/matrix.png "img")

I will not be passing the matrix as an argument and then returning it. Instead, I will be modifying it right from within the functions.

### Alpha(w)

The first function was a simple swap, so I just needed to do:

```c
void alpha(unsigned arr[2][4]){
  unsigned x[4];
  for (int i = 0; i<4; i++) x[i] = arr[0][i];
  for (int i = 0; i<4; i++) arr[0][i] = arr[1][i];
  for (int i = 0; i<4; i++) arr[1][i] = x[i];
}
```

### Beta(w)

Beta consisted of XORing one of the elements of the matrix to another:

```c
void beta(unsigned arr[2][4]){
  for (int i = 0; i<4; i++){
    arr[0][i] ^= arr[1][3-i];
  }
}
```

### Gamma(w)

In gamma we find that we need to do some variable assignations (we need to take into account that ``a -> b`` means store a into b, not the other way around).

```c
void gamma(unsigned arr[2][4]){
  unsigned w,x,y,z;
  x = arr[1][3];
  y = arr[1][2];
  z = arr[0][3];
  w = arr[1][1];
  arr[0][3] = arr[0][0];
  arr[1][2] = arr[0][1];
  arr[1][3] = arr[0][2];
  arr[1][1] = z;
  arr[0][1] = arr[1][0];
  arr[1][0] = w;
  arr[0][2] = y;
  arr[0][0] = x;
}
```

### Delta(w)

Finally, in delta there are some bitwise rotations that we can do with right and left shifts and masks (to get only the first byte).

```c
unsigned rotate_left(unsigned x){
  return 0xff & ((x << 1)|(x >> 7));
}

unsigned rotate_right(unsigned x){
  return 0xff & ((x >> 1)|(x << 7));
}

void delta(unsigned arr[2][4]){
  arr[0][0] = rotate_left(arr[0][0]);
  arr[1][0] = rotate_left(arr[1][0]);
  arr[0][2] = rotate_left(arr[0][2]);
  arr[1][2] = rotate_left(arr[1][2]);
  arr[0][1] = rotate_right(arr[0][1]);
  arr[1][1] = rotate_right(arr[1][1]);
  arr[0][3] = rotate_right(arr[0][3]);
  arr[1][3] = rotate_right(arr[1][3]);
}
```

### The sponge function

After doing the composite function <i>f</i> we need to understand how the sponge function works.

![Img](/assets/posts_details/RITSECCTF/sponge.png "img")

It starts with 8 bytes, 4 in <i>r</i> and 4 in <i>c</i>. What we need to do is divide our message in 4-bit chunks (padding it with 0s at the end if needed) and then XOR each chunk with <i>r</i>. Then, we apply <i>f</i> and start again.

For example, if we had "HELLOWORLD" we would divide our message in "HELL", "OWOR", "LD" + 00. They would be P<sub>0</sub>, P<sub>1</sub> and P<sub>2</sub> respectively.

I transformed this into code the following way:

```c
void tests(char stri[], int len){
  unsigned w[2][4] = {31,56,156,167,38,240,174,248};
  for (int i=0; i<len/4; i+=1){
    for (int j=0; j<4; j++){
      w[0][j] ^= stri[j+(4*i)];
    }
    f(w);
  }
  if (len%4!=0){
    for (int j=0; j<len%4; j++){
      w[0][j] ^= stri[j+(4*(len/4))];
    }
    for (int j=4-(len%4); j<4; j++){
      w[0][j] ^= 0;
    }
    f(w);
  }
  printf("0x%x%x%x%x\n", w[0][0], w[0][1], w[0][2], w[0][3]);
}
```

## Putting it all together

I ended with the following code, that took 2 arguments when run from the command line: a string and its length. The reason I did this was so that I could pass arguments from another program and then brute-force the solution.

```c
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

unsigned rotate_left(unsigned x){
  return 0xff & ((x << 1)|(x >> 7));
}

unsigned rotate_right(unsigned x){
  return 0xff & ((x >> 1)|(x << 7));
}

void alpha(unsigned arr[2][4]){
  unsigned x[4];
  for (int i = 0; i<4; i++) x[i] = arr[0][i];
  for (int i = 0; i<4; i++) arr[0][i] = arr[1][i];
  for (int i = 0; i<4; i++) arr[1][i] = x[i];
}

void beta(unsigned arr[2][4]){
  for (int i = 0; i<4; i++){
    arr[0][i] ^= arr[1][3-i];
  }
}

void gamma(unsigned arr[2][4]){
  unsigned w,x,y,z;
  x = arr[1][3];
  y = arr[1][2];
  z = arr[0][3];
  w = arr[1][1];
  arr[0][3] = arr[0][0];
  arr[1][2] = arr[0][1];
  arr[1][3] = arr[0][2];
  arr[1][1] = z;
  arr[0][1] = arr[1][0];
  arr[1][0] = w;
  arr[0][2] = y;
  arr[0][0] = x;
}

void delta(unsigned arr[2][4]){
  arr[0][0] = rotate_left(arr[0][0]);
  arr[1][0] = rotate_left(arr[1][0]);
  arr[0][2] = rotate_left(arr[0][2]);
  arr[1][2] = rotate_left(arr[1][2]);
  arr[0][1] = rotate_right(arr[0][1]);
  arr[1][1] = rotate_right(arr[1][1]);
  arr[0][3] = rotate_right(arr[0][3]);
  arr[1][3] = rotate_right(arr[1][3]);
}

void f(unsigned arr[2][4]){
  for (int i=0; i<50; i++){
    alpha(arr);
    beta(arr);
    gamma(arr);
    delta(arr);
  }
}

void tests(char stri[], int len){
  unsigned w[2][4] = {31,56,156,167,38,240,174,248};
  for (int i=0; i<len/4; i+=1){
    for (int j=0; j<4; j++){
      w[0][j] ^= stri[j+(4*i)];
    }
    f(w);
  }
  if (len%4!=0){
    for (int j=0; j<len%4; j++){
      w[0][j] ^= stri[j+(4*(len/4))];
    }
    for (int j=4-(len%4); j<4; j++){
      w[0][j] ^= 0;
    }
    f(w);
  }
  printf("0x%x%x%x%x\n", w[0][0], w[0][1], w[0][2], w[0][3]);
}

int main(int argc, char *argv[]){
  int x = strtol(argv[2], NULL, 10);
  char stri[x];
  strcpy(stri, argv[1]);
  tests(stri, x);
}

```

In order to get the flag I wrote a simple python script to generate permutations of letters, pass them as arguments to the C code and then retrieve the hash for comparisons.

```py
from itertools import product
import subprocess, os, sys

li = []

def allwords(chars, length):
    for letters in product(chars, repeat=length):
        yield ''.join(letters)

def main():
    letters = "abcdefghijklmnopqrstuvwxyz"
    global li
    for wordlen in range(1, 26):
        for word in allwords(letters, wordlen):
            print(word)
            hash = subprocess.Popen(["./Citro", word, str(len(word))], stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0].strip()
            print hash
            if hash in li:
                print li
                print word, hash
                sys.exit()
            else:
                li.append(hash)

if __name__=="__main__":
    main()
```

After running it for a few seconds we get our output back, a collision was found!

```
pa 0xba847264
ap 0xba847264
```

Therefore, I do the following Curl request and get the flag:

```
curl -X POST http://fun.ritsec.club:8003/checkCollision --header "Content-Type: application/json" --data '{"str1": "pa", "str2": "ap"}'
```

*Output*

```json
{
  "flag": "RITSEC{I_am_th3_gr3@t3st_h@XOR_3v@}",
  "success": true
}
```

---

<center>
<i>Diego Bernal Adelantado</i>
</center>
