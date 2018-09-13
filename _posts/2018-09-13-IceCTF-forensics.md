---
layout: post
title: "IceCTF 2018: Forensics write-ups"
date: 2018-09-02
excerpt: "Various write-ups from IceCTF forensics challenges"
tags: [IceCTF, CTF, Forensics, Photoshop, ZIP, File Headers, Python]
comments: true
feature: https://4.bp.blogspot.com/-C0CsO2IL0M4/V8Td0P8kh-I/AAAAAAAABrM/QDQy2LDL4TM6Az3it0nfnUptl8JOka5NQCLcB/s1600/icectf_banner_big.png
---

## Forensics 1. Modern Picasso {#forensics1}

**Challenge description**: Here's a rendition of some modern digital abstract art. Is it more than art though?

We get the following GIF to work with:

*Picasso.gif*

![Img](/assets/posts_details/IceCTF/forensics1/picasso.gif "Img")

And we immediately notice that there are black signs that seem to contain the flag. So our mission is

1. To decompose the GIF into different frames
2. To overlay the frames in order to get an image

The first part was easy, as just googling 'gif to png converter' showed a lot of websites that did it. I got 66 different images which now had to be merged. In order to do so, I decided to use Photoshop CC.

First of all, we add all images as different layers and then rasterize them in order to be able to merge them into one single image.

*Steps followed*

![Img](/assets/posts_details/IceCTF/forensics1/1.png "Img")

![Img](/assets/posts_details/IceCTF/forensics1/2.png "Img")

![Img](/assets/posts_details/IceCTF/forensics1/3.png "Img")

![Img](/assets/posts_details/IceCTF/forensics1/4.png "Img")

And then we get the final image, from which we can deduce the flag:

*Result from merging*

![Img](/assets/posts_details/IceCTF/forensics1/out.png "Img")

``
IceCTF{wow_fast}
``

## Forensics 2. Hardshells {#forensics2}

**Challenge description**: After a recent hack, a laptop was seized and subsequently analyzed. The victim of the hack? An innocent mexican restaurant. During the investigation they found this suspicous file. Can you find any evidence that the owner of this laptop is the culprit?

We download the file, and check what it is:

```console
diego@MacBook-Air:~/downloads/IceCTF$ file hardshells.zip
hardshells.zip: Zip archive data, at least v1.0 to extract
```

So it's a zip! As it is password protected we can use fcrackzip to crack it open. After a few minutes we get that the password is ``tacos``.

Once extracted, we navigate to the new directory and find a new file, called ``d``.

```console
diego@MacBook-Air:~/downloads/IceCTF$ file hardshells/d
hardshells/d: Minix filesystem, V1, 30 char names, 20 zones
```

Minix is a linux file system, so I mount it into my linux VM to see what it contains with the following command:

```sh
mount /home/parallels/Downloads/d /mnt
```

Then, after navigating to the /mnt directory I find yet another file, called ``dat``. However, the ``file`` command gave me no clue, as the output was just ``data``. That's when I decided to look at the file with a hexadecimal editor, Hex Fiend.

*File header*

![Img](/assets/posts_details/IceCTF/forensics2/header.png "Img")

We can see the first few bytes are ``89 50 55 47 0D 0A 1A 0A``, which reminded me of a PNG header (the header of PNGs is ``89 50 4E 47 0D 0A 1A 0A``). So we just need to change the third byte, ``55``, to be ``4E``. Again, we check the new modified file with the ``file`` command:

```
dat: PNG image data, 1920 x 1080, 8-bit/color RGBA, non-interlaced
```

Looks like we found something!! Let's rename the file to ``dat.png``.

*Dat.png*

![Img](/assets/posts_details/IceCTF/forensics2/dat.png "Img")

On the bottom left side we can see the flag:

``
IceCTF{look_away_i_am_hacking}
``

## Forensics 3. Lost in the Forest {#forensics3}

**Challenge description**: You've rooted a notable hacker's system and you're sure that he has hidden something juicy on there. Can you find his secret?

So this time we have a file system. Upon inspecting it I come across an image named ``clue`` in the home directory, but I don't find anything interest on it. Then, I notice another odd file called ``hzpxbsklqvboyou``. Its contents are encrypted:

```
8NHY25mYthGfs5ndwx2Zk1lcaFGc4pWdVZFQoJmT8NHY25mYthGfs5ndwx2Zk1lcaFGc4pWdVZFQoJmT8NHY25mYthGfs5ndwx2Zk1lcaFGc4pWdVZFQoJmT8NHY25mYthGfs5ndwx2Zk1lcaFGc4pWdVZFQoJmT8NHY25mYthGfs5ndwx2Zk1lcaFGc4pWdVZFQoJmT
```

So looks like I'll have to keep searching... There is a ``.bash_history``!

*Files found*

![Img](/assets/posts_details/IceCTF/forensics3/file.png "Img")

I'm going to inspect the contents of the ``.bash_history``. There were many lines, but only two insteresting ones:

```
wget https://gist.githubusercontent.com/Glitch-is/bc49ee73e5413f3081e5bcf5c1537e78/raw/c1f735f7eb36a20cb46b9841916d73017b5e46a3/eRkjLlksZp
cd Downloads
./tool.py ../secret > ../hzpxbsklqvboyou
```

Looks like the supposed hacker downloaded a script and then used it to encode some sort of secret and renamed it to the file I found earlier. Let's reverse it!

First of all, I get the file to check the contents:

```py
#!/usr/bin/python3
import sys
import base64

def encode(filename):
    with open(filename, "r") as f:
        s = f.readline().strip()
        return base64.b64encode((''.join([chr(ord(s[x])+([5,-1,3,-3,2,15,-6,3,9,1,-3,-5,3,-15] * 3)[x]) for x in range(len(s))])).encode('utf-8')).decode('utf-8')[::-1]*5

if __name__ == "__main__":
    print(encode(sys.argv[1])
```

I'll have to write a function to decode the ``hzpxbsklqvboyou`` file and then hopefully get the flag. Simple.

```py
def decode(filename):
    with open(filename, "r") as f:
        file = base64.b64decode(f.read()[:40][::-1].encode('utf-8')).decode('utf-8')
        li = []
        for x in range(len(file)):
            u = chr(ord(file[x]) - ([5,-1,3,-3,2,15,-6,3,9,1,-3,-5,3,-15] * 3)[x])
            li.append(u)
        return ''.join(li)
```

Then, running the script to decode the file we get our flag!

```console
diego@MacBook-Air:~/downloads/IceCTF/fs/home/hkr$ python Pictures/tool.py hzpxbsklqvboyou
IceCTF{good_ol_history_lesson}
```

---
<center><i>Diego Bernal Adelantado</i></center>
