---
layout: post
title: "Square CTF 2018: Shredded write-up"
date: 2018-11-14
excerpt: "Reducing the 27! permutations to over 300 and cracking of a shredded QR code! Really fun and interesting challenge by Square CTF..."
tags: [CTF, QR, Python]
comments: true
feature: /assets/posts_details/SquareCTF/code.png
---

# Square CTF 2018: Shredded write-up

### First contact

We open the zip with ``jar xf shredded.jar`` and get a folder containing 27 vertical images like stripes. My first instinct was to put them together based on their filename (they were named ``1.png`` to ``27.png``). So I opened Photoshop CC and started gluing them together.

*Result of gluing the images together*

![Img](/assets/posts_details/SquareCTF/1st.png "img")

I saw that it looked like a QR code, so that was my task: I had to find some way of recovering the QR code and then read it to, presumably, get the flag.

### The reconstruction process

At first I thought about a basic brute-force approach. However, when I did the math I saw it wasn’t plausible. There were 27 images, so that would’ve been 27! possibilities, definitely a number too big for me to compute (besides not only did I need to do each permutation, but also create the main image and scan it to check if it contained a valid message).

So I thought about reducing the number of permutations. For that, I used the following facts:

* There were six completely white images, which must correspond to the left and right sides (3 on each).

We reduce thus the possibilities from 27! to 21! Still big, though.

* We try to recover the three big squares on the top corners and the left bottom one. However, I couldn't decide on anything, as the 1st and 7th frame could be swapped and same for 2,6 and 3,4,5.

Looking closely, though, I found that the white vertical lines on the inside of the squares could only be in one way, as there was one that had its left side slightly black. So that removes 4 images more. 17!

Then, I had a look at QR codes format:

![img](https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/QR_Code_Structure_Example_3.svg/400px-QR_Code_Structure_Example_3.svg.png)

I noticed that there had to be a white space between the squares and the central pattern of data. There were only two possible ways of doing this, so that removed two more possibilities, 15!

Besides, the format showed that we needed a specified pattern of alternating dots between the squares! Good! Now I knew the way in which 1,7 were to be placed. So far I have 13! possibilities. Besides, I knew that in the centre I needed to have an alternating pattern as well, so that made me have three possible frames for black and two for whites (see image below)

*Frames that have been discarded*

![Img](/assets/posts_details/SquareCTF/possib.png "img")

All in all, I managed to reduce 13! to the following:

* 3! for the frames number 6,7,8.
* 3! for the frames number 12,14,16.
* 2 for the frames number 13,15.
* 2 for the frames number 20,21,22.
* 2 for the frames number 18,24.

That means that there are 2<sup>3</sup> · 3!<sup>2</sup>  = 288 possibilities! Pretty good considering that we had 27!

Now the only thing needed was the code!

### Coding the burte-forcer

I finally came up with the following python script:

```py
import os
import subprocess
import itertools, sys

l1 = ["6.png", "7.png", "8.png"]

l2 = ["12.png", "14.png", "16.png"]

l3 = ["13.png", "15.png"]

l4 = ["18.png", "24.png"]

l5 = ["20.png", "21.png", "22.png"]

xx = 0

with open(os.devnull, "w") as f:
	for i1 in itertools.permutations(l1):
		for i2 in itertools.permutations(l2):
			for i3 in itertools.permutations(l3):
				for i4 in itertools.permutations(l4):
					for i5 in itertools.permutations(l5):
						s = "1.png 2.png 3.png 4.png 5.png " + " ".join(i1) + " 9.png 10.png 11.png " + i2[0] + " " + i3[0] + " " + i2[1] + " " + i3[1] + " " + i2[2] + " 17.png " + i4[0] + " 19.png " + " ".join(i5) + " 23.png " + i4[1] + " 25.png 26.png 27.png"
						os.system("""convert +append {} ouit.jpg""".format(s))
						result = subprocess.Popen(["zbarimg", "ouit.jpg"], stdout=subprocess.PIPE, stderr=f)
						val = result.communicate()[0]
						if val != "":
							print val
							sys.exit()
						print xx
						xx += 1
```

Once ran, I successfully get the flag pretty quickly! After only 8 attempts:

*Output of the script*

![Img](/assets/posts_details/SquareCTF/flag.png "img")

And here we have our QR code, which contains the following message:

![Img](/assets/posts_details/SquareCTF/code.png "img")

<center>
GOOD JOB. FLAG-80AD8BCF79
</center>

---

<center>
<i>Diego Bernal Adelantado</i>
</center>
