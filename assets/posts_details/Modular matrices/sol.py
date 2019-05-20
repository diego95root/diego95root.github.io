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


# check that it is m3
#print np.dot(m2, m1_1)
#print np.dot(m1_2, m2)

#print m1_1
#print m1_2
