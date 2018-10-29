---
layout: post
title: "BSides Delhi 2018: RSA_Baby [Crypto]"
date: 2018-10-14
excerpt: "RSA explanation algon with a cool problem from BSides Delhi 2018 that takes it one step further"
tags: [RSA, CTF, Python]
comments: true
feature: http://www.cse.chalmers.se/edu/course/TDA352/assets/images/avatar.jpg
---

# BSides Delhi 2018: RSA_Baby write-up

This was one of the crypto challenges from BSides Delhi. When we open the description we download a zip which contains two files: ``encrypt.py`` and ``ciphertext.txt``.

The contents of ``encrypt.py`` are:

```python
from Crypto.Util.number import *

modulus_list = [143786356117385195355522728814418684024129402954309769186869633376407480449846714776247533950484109173163811708549269029920405450237443197994941951104068001708682945191370596050916441792714228818475059839352105948003874426539429621408867171203559281132589926504992702401428910240117807627890055235377744541913L,
 73988726804584255779346831019194873108586184186524793132656027600961771331094234332693404730437468912329694216269372797532334390363774803642809945268154324370355113538927414351037561899998734391507272602074924837440885467211134022878597523920836541794820777951492188067045604789153534513271406458984968338509L,
 95666403279611361071535593067846981517930129087906362381453835849857496766736720885263927273295086034390557353492037703154353541274448884795437287235560639118986397838850340017834752502157881329960725771502503917735194236743345777337851076649842634506339513864285786698870866229339372558162315435127197444193L,
 119235191922699211973494433973985286182951917872084464216722572875998345005104112625024274855529546680909781406076412741844254205002739352725207590519921992295941563460138887173402493503653397592300336588721082590464192875253265214253650991510709511154297580284525736720396804660126786258245028204861220690641L]

e = [114194L, 130478L, 122694L, 79874L]

ciphertext = ['0c55bc89e3773d8e378121eced4f9300103a8696bc3f9a1542c5b1539442ca5de03a40ad564ab5c2e764b2f946058ec220abf20afc271896ff4ca1f4a2dd227405f221de51e097d6b9f270c4561cd25596e96efd7de1a0e65d37cbf6a73c62a7e323f48450b9dc75e3e738ec1c7e1ae9fc808da8c476e72aea9155125b815653',
'67caf9720696b1d0d589f053bb00ebe42b7b26fed38acb4012d29ddc55cd53da8398f042f22987453bdfa2ee8fb35ff121f81e96137995a8ca4daa1fbd88af3fd29138853d5fe98f9b983f67d6fd2b7ff6650228479ca6cac1d49572d28f01a659892b0799ca8202031a1ab37656331470d3ea5f221cc948636c1027bb6dd10f',
'65e1cffe93ebccd49a9d14c01b2583a5d5e3140bf38a768833aa494d2d879a2934dbc10a843ec834e9ade286824e68879cb09ac9bd67afd7318b74955e9aa66df5740e6dcc26ccc787f0b415bdc80c6468421c4d4ce615fa3d25350940c5004e9b480c86faebc31e809725a9a868c94e9f1eaac567b4672fe395a7b205775883',
'23108bb7f35d12b69bbe5e649ff47fb802b68f22045c484805040a3f4f8669acde8b04daba71190154aef4be9a0eafdebe31b5f96e8b01b5085f502fc0e12a326cc4d867f5317ac12bf16607765d99708934c35c4b9404747f69988ea7d3f4d8022cdfd81ada3aedb22d110db4aa81038aa151c9a4dbb5651757dc092b70b84d']


message = bytes_to_long(flag)
ciphertext = [pow(message, e[i], modulus_list[i]) for i in range(4)]
ciphertext = [long_to_bytes(ciphertext[i]) for i in range(4)]
ciphertext = [ciphertext[i].encode("hex") for i in range(4)]

obj1 = open("ciphertext.txt",'w')
obj1.write(str(ciphertext))

```

And the contents of ``ciphertext.txt`` are:

```
['0c55bc89e3773d8e378121eced4f9300103a8696bc3f9a1542c5b1539442ca5de03a40ad564ab5c2e764b2f946058ec220abf20afc271896ff4ca1f4a2dd227405f221de51e097d6b9f270c4561cd25596e96efd7de1a0e65d37cbf6a73c62a7e323f48450b9dc75e3e738ec1c7e1ae9fc808da8c476e72aea9155125b815653', '67caf9720696b1d0d589f053bb00ebe42b7b26fed38acb4012d29ddc55cd53da8398f042f22987453bdfa2ee8fb35ff121f81e96137995a8ca4daa1fbd88af3fd29138853d5fe98f9b983f67d6fd2b7ff6650228479ca6cac1d49572d28f01a659892b0799ca8202031a1ab37656331470d3ea5f221cc948636c1027bb6dd10f', '65e1cffe93ebccd49a9d14c01b2583a5d5e3140bf38a768833aa494d2d879a2934dbc10a843ec834e9ade286824e68879cb09ac9bd67afd7318b74955e9aa66df5740e6dcc26ccc787f0b415bdc80c6468421c4d4ce615fa3d25350940c5004e9b480c86faebc31e809725a9a868c94e9f1eaac567b4672fe395a7b205775883', '23108bb7f35d12b69bbe5e649ff47fb802b68f22045c484805040a3f4f8669acde8b04daba71190154aef4be9a0eafdebe31b5f96e8b01b5085f502fc0e12a326cc4d867f5317ac12bf16607765d99708934c35c4b9404747f69988ea7d3f4d8022cdfd81ada3aedb22d110db4aa81038aa151c9a4dbb5651757dc092b70b84d']
```

So apparently what we need to do is recover the message from the ciphers. We can see that the same message has been encrypted four times with different exponents and moduli. That is:

<center>
c<sub>i</sub> = m<sup>e<sub>i</sub></sup> mod n<sub>i</sub> for i &isin; {1,2,3,4}
</center>

### Solution

If we analyze all moduli we can notice that the first and fourth ones share a common factor. With that we can recover the other factor and retrieve <i>p</i> and <i>q</i> and consequently &#934;<i>(n)</i> = (<i>p</i>-1)(<i>q</i>-1).

With a simple python program or online calculator we can find that the GCD of ``modulus_list[0]`` and ``modulus_list[3]`` is:

111960225180138464064502577636803075288614408406337123570210191209344103731804
06217919066924474450204377977943388931820832436504741695416094988192576484719.

Now we can recover the other factor, given that <i>n</i> is the product of <i>p</i> and <i>q</i> and we already got one.

<center>
q<sub>1</sub> = n<sub>1</sub> &divide; q<sub>1</sub><br><br>
</center>

We find that <i>q</i> (or <i>p</i>) is:
 128426283428815957570404012930010100429807481441356932980421732
 938384128881898075944719623762195906062326995597676314075131761
 87065045811465165682366505527.

Now we can calculate &#934;<i>(n)</i> = (<i>p</i>-1)(<i>q</i>-1) =

1437863561173851953555227288144186840241294029543097691868696333
7640748044984671477624753395048410917316381170854926902992040545
0237443197994941951104067977670032084295928432560257385111396656
9762860750699464508848114596537161682511950547801742585870917793
15827489545838200564627426000886662495081502801551668.

The private key <i>d</i> is defined as:

<center>
d &equiv; e<sup>-1</sup> (mod &#934;(<i>n</i>))<br><br>
</center>

That is, we need to find the multiplicative inverse of <i>e</i>. The extended Euclidean Algorithm helps us do that as modifying it a bit we can obtain the definition of our private key:

<center>
ax + by = gcd(a,b)<br>
Taking a = e, b = &#934;(<i>n</i>): ex + &#934;(<i>n</i>)y = 1 (given that e and &#934;(<i>n</i>) must be coprime)<br>
Taking modulo &#934;(<i>n</i>) of all the equation: ex &equiv; 1 (mod &#934;(<i>n</i>))<br><br>
</center>

However, we come across a problem: phi and our modulus, 114194, are not coprime to each other, but share a factor of 2. To solve this problem we can rewrite our encryption method the following way:

<center>
m<sup>e</sup> mod n = m<sup>(e<sub>1</sub> &sdot; e<sub>2</sub>)</sup> mod n = (m<sup>e<sub>1</sub></sup>) <sup>e<sub>2</sub></sup> mod n = c <i>where e<sub>1</sub> will be 2 and e<sub>2</sub> the other factor, 57097</i><br><br>
</center>

Thus, we can use the normal extended Euclidean Algorithm with <i>e = 57097</i> and &#934;(<i>n</i>) to obtain <i>d</i>. We get that <i>d =
1044608620086038721568985816058794933535021413375085124549545381
0334621252500291741481205590136139083685671880278004498712941728
0790573608000914007281430614248219711870665837277475814697897345
3602347352746457559793485499745310677483549410185545373741379424
10281452508028694986099274181529321101957647822322797</i>.

I did this calculation using python's ``inverse(e, phi(n))``.

Once there, we just need to apply the formula to decrypt RSA ciphers:

<center>
c<sup>d</sup> mod n = m<br><br>
</center>

However, that is not all, for now we need to take the root of <i>m</i> to get the correct message (remember we left out <i>e<sub>2</sub></i> when calculating the value of <i>d</i>). Hence, if normally <i>m<sup>ed</sup> = m</i>, now we have that <i>m<sup>e<sub>1</sub> d e<sub>2</sub></sup> = m<sup>2</sup></i>. Therefore our formula will be:

<center>
&radic;(c<sup>d</sup> mod n) = m<br><br>
</center>

We need to remember to convert the cipher to base 10 though, as it's in base 16.

Then, we apply the ``long_to_bytes()`` function to <i>m</i> and we get our flag:
<center>
flag{Congratzzz_y0u_kn0w_ext3nded_GCD_WOw!!}
</center>

---

<center>
<i>Diego Bernal Adelantado</i>
</center>
