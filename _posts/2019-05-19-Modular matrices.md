---
layout: post
title: "Modular matrices - HarekazeCTF 2019"
date: 2019-05-19
excerpt: "In this blogpost I'll be explaining how to find the inverse of a modular matrix as I solve one of the crypto challenges from HarekazeCTF 2019. Definitely for those who like math!"
tags: [CTF, Cryptography, Python, Matrices, Numpy]
comments: true
feature:
---

# Modular matrices - HarekazeCTF 2019

In this blogpost I will be writing about modular matrices, a topic I came across while doing one of the crypto challenges from HarekazeCTF 2019!


## Some background math

A modular matrix is simply a matrix in which each cell is under the modulo operator. For instance, here are two matrices that are congruent:

\begin{align}
\begin{pmatrix}
    1 & 8 \\\
    15 & 9 \\\
\end{pmatrix}
\equiv
\begin{pmatrix}
    1 & 0 \\\
    3 & 1 \\\
\end{pmatrix}
\pmod{4}
\end{align}

Now, modular matrices hold some properties. Whereas matrices in classic arithmetic can be multiplied with this formula:

\begin{align}
C_{ij} = \sum_{k=0}^n A_{ik}B_{kj}
\end{align}

In modular arithmetic we need to take the modulo of each term in the summation:

\begin{align}
C_{ij} = \sum_{k=0}^n [A_{ik}B_{kj} \pmod{x}]
\end{align}

## The challenge

We are given two files in the challenge:

* ```problem.py```:

```py
#!/usr/bin/python3
import random
import binascii
import re
from keys import flag

flag = re.findall(r'HarekazeCTF{(.+)}', flag)[0]
flag = flag.encode()
#print(flag)

def pad25(s):
    if len(s) % 25 == 0:
        return b''
    return b'\x25'*(25 - len(s) % 25)

def kinoko(text):
    text = text + pad25(text)
    mat = []
    for i in range(0, len(text), 25):
        mat.append([
            [text[i], text[i+1], text[i+2], text[i+3], text[i+4]],
            [text[i+5], text[i+6], text[i+7], text[i+8], text[i+9]],
            [text[i+10], text[i+11], text[i+12], text[i+13], text[i+14]],
            [text[i+15], text[i+16], text[i+17], text[i+18], text[i+19]],
            [text[i+20], text[i+21], text[i+22], text[i+23], text[i+24]],
            ])
    return mat

def takenoko(X, Y):
    W = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]
    for i in range(5):
        for j in range(5):
            for k in range(5):
              W[i][j] = (W[i][j] + X[i][k] * Y[k][j]) % 251

    return W

def encrypt(m1, m2):
    c = b""
    for each in m1:
        g = random.randint(0,1)
        if g == 0:
            mk = takenoko(m2, each)
        else:
            mk = takenoko(each, m2)
        for k in mk:
            c += bytes(k)

    return c


if __name__ == '__main__':
    m1 = kinoko(flag)
    m2 = [[1,3,2,9,4], [0,2,7,8,4], [3,4,1,9,4], [6,5,3,-1,4], [1,4,5,3,5]]


    print("Encrypted Flag:")
    enc_flag = binascii.hexlify(encrypt(m1, m2)).decode()
    print(enc_flag)
```

* ```result.txt```:

```
Encrypted Flag:
ea5929e97ef77806bb43ec303f304673de19f7e68eddc347f3373ee4c0b662bc37764f74cbb8bb9219e7b5dbc59ca4a42018
```

### Analysis of the Python script

In order to solve the challenge I started by inspecting the script, identifying what each function did:

* ```pad25(s)```: returns a string comprised of as many ``\x25``'s as characters needs the ```s``` argument to have a length that is a multiple of 25.

* ```kinoko(text)```: pads a the ```text``` argument to a multiple of 25 and then splits it into lists of 25 characters, which returns in a list themselves.

* ```takenoko(X, Y)```: here comes the (tricky) part of the challenge, recognising that this function performs a modular multiplication of the argument matrices.

* ```encrypt(m1, m2)```: calls the ```takenoko``` function to perform the multiplication on each of the one dimensional matrices of m1. Another tricky part is that it randomly chooses whether to do $A \cdot B$ or $B \cdot A$. We need to keep in mind that matrix multiplication is not commutative in most of the cases (hint: this is not one), and hence $A \cdot B \neq B \cdot A$. Finally, it returns the concatenation of the bytes resulting from each of the multiplications.

### Objective of the challenge

Given the functions, we only need to take a look at the main part of the script to realise what we need to do:

```py
if __name__ == '__main__':
    m1 = kinoko(flag)
    m2 = [[1,3,2,9,4], [0,2,7,8,4], [3,4,1,9,4], [6,5,3,-1,4], [1,4,5,3,5]]


    print("Encrypted Flag:")
    enc_flag = binascii.hexlify(encrypt(m1, m2)).decode()
    print(enc_flag)
```

```m1``` and ```m2``` are both matrices and ```encrypt(m1, m2)``` is the concatenation of the bytes contained in a matrix, let's call it ```m3```, that is the modular multiplication of ```m1``` and ```m2```. Therefore, what we need to do is, given ```m2``` and ```m3```, obtain ```m1```. i.e: obtain
$A$ from $A \cdot B = C$ given $B$ and $C$.

### Back to math

Having $A \cdot B = C$ and given $B$, $C$, it is possible to recover $A$ if $B$ is invertible: $C \cdot B^{-1} = A$, where $B^{-1}$ is the inverse matrix of $B$.

In classic arithmetic, the inverse matrix $B^{-1}$ of $B$ can be obtained the following way:

\begin{align}
B^{-1} = \frac{1}{det(B)} \cdot \left(B^{*}\right)^{t}
\end{align}

where

        det($B$) is the determinant of $B$ \\
        $B^{\*}$ is the adjoint matrix of $B$ \\
        $\left(B^{*}\right)^{t}$ is the traspose of the adjoint matrix

However, in modular arithmetic things are a bit different. Let's say we want to find the inverse matrix of $B \pmod{x}$. We need to follow a series of steps:

* First we need to find det$(B)$. If det$(B)$ is coprime to $x$, then $B$ is invertible modulo $x$. This is necessary, since only coprime numbers to $x$ will have a modular inverse modulo $x$.

* Next, we need to find the modular inverse of det$(B)$ $\pmod{x}$, which we will denote as $($det$(B))^{-1}$. Recall that this number satisfies that det$(B)$ $\cdot$ $($det$(B))^{-1} \equiv 1 \pmod{x}$.

* Then, we calculate the traspose of the adjoint matrix, which is calculated normally. We will name it as before, $\left(B^{*}\right)^{t}$.

* Finally, the matrix obtained from $($det$(B))^{-1}$ $\cdot$ $\left(B^{*}\right)^{t}$ is the inverse of $B \pmod{x}$. Lastly, we take the modulo of each cell in order to ensure that the integers range from $0$ to $x$.

### Solution of the challenge

Now we just need to put this into code to solve the challenge and retrieve the challenge, easy right? (It wasn't)

First thing I did was put back the result of the multiplications, which was encoded as hex, into the original format:

```py
encrypted = "ea5929e97ef77806bb43ec303f304673de19f7e68eddc347f3373ee4c0b662bc37764f74cbb8bb9219e7b5dbc59ca4a42018"

text = binascii.unhexlify(encrypted)

m3 = []

for i in range(0, len(text), 25):
    submat = []
    for x in range(0, 25, 5):
        submat.append([ord(text[i+x]), ord(text[i+x+1]), ord(text[i+x+2]), ord(text[i+x+3]), ord(text[i+x+4])])
    m3.append(submat)
```

Then, using numpy to make things easier I calculated the inverse of ```m2```. I needed to use ```int()``` to get rid of floating point residues when getting the determinant and also multiply by the determinant, given that ``np.linalg.inv(m2)`` divides the traspose by it:

```py
det = int(np.linalg.det(m2))
Bprime = (np.linalg.inv(m2) * det * modinv(det, 251)) % 251
```

After that, we need to guess the order of the multiplication. This wasn't difficult and could be done manually, since ``m3`` only had two matrices and so there were 4 possibilities. It turned out to be this one:

```py
m1_1 = np.dot(m3[0], Bprime)
m1_2 = np.dot(m3[1], Bprime)
```

Finally, we extract the numbers from the matrices taking modulo 251 and join them in a string to get the flag. It was necessary to use the ```round``` function, as ``int()`` rounds down the numbers (1.9 should be 2 and not 1).

```py
s = ""

for i in m1_1:
    print i
    for x in i:
        s += chr(int(round(x)) % 251)

for i in m1_2:
    for x in i:
        s += chr(int(round(x)) % 251)
```

Flag: ```Op3n_y0ur_3y3s_1ook_up_t0_th3_ski3s_4nd_s33```.

Here is the whole script in case you are interested:

```py
import binascii
import numpy as np

def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m


m1 = ""
m2 = [[1,3,2,9,4], [0,2,7,8,4], [3,4,1,9,4], [6,5,3,-1,4], [1,4,5,3,5]]

encrypted = "ea5929e97ef77806bb43ec303f304673de19f7e68eddc347f3373ee4c0b662bc37764f74cbb8bb9219e7b5dbc59ca4a42018"

text = binascii.unhexlify(encrypted)

m3 = []

for i in range(0, len(text), 25):
    submat = []
    for x in range(0, 25, 5):
        submat.append([ord(text[i+x]), ord(text[i+x+1]), ord(text[i+x+2]), ord(text[i+x+3]), ord(text[i+x+4])])
    m3.append(submat)

det = int(np.linalg.det(m2))
Bprime = (np.linalg.inv(m2) * det * modinv(det, 251)) % 251

m1_1 = np.dot(m3[0], Bprime)
m1_2 = np.dot(m3[1], Bprime)

s = ""

for i in m1_1:
    print i
    for x in i:
        s += chr(int(round(x)) % 251)

for i in m1_2:
    for x in i:
        s += chr(int(round(x)) % 251)

print s
```

I hope this article was useful, see you next time!

---

<center>
<i>Diego Bernal Adelantado</i>
</center>
