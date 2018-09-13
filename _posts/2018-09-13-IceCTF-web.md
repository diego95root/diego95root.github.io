---
layout: post
title: "IceCTF 2018: Web write-ups"
date: 2018-09-02
excerpt: "Various write-ups from IceCTF web challenges"
tags: [IceCTF, CTF, Robots, Laravel, CSS]
comments: true
feature: https://4.bp.blogspot.com/-C0CsO2IL0M4/V8Td0P8kh-I/AAAAAAAABrM/QDQy2LDL4TM6Az3it0nfnUptl8JOka5NQCLcB/s1600/icectf_banner_big.png
---

## Web 1. Toke Relaunch {#web1}

**Challenge description**: We've relaunched our famous website, Toke! Hopefully no one will hack it again and take it down like the last time.

Once we access the static webpage we're presented with a button that does nothing and some text.

*Index.html*

![Img](/assets/posts_details/IceCTF/web1/initial.png "Img")

I had a look at the html and some js files, but found nothing on them. So that's when I started checking if there were any common files on the web server, like ``.htaccess``, ``.htpasswd``, ``sitemap.xml`` or ``robots.txt``. And it turned out there was a robots.txt file present:

```
User-agent: *
Disallow: /secret_xhrznylhiubjcdfpzfvejlnth.html
```

Curl'ing the file present on it (https://static.icec.tf/toke/secret_xhrznylhiubjcdfpzfvejlnth.html) gave us the flag:

``
IceCTF{what_are_these_robots_doing_here}
``

## Web 2. Lights out {#web2}

**Challenge description**: Help! We're scared of the dark!

Again we get a static webpage, this time with nothing on it, just a question.

*Index.html*

![Img](/assets/posts_details/IceCTF/web2/initial.png "Img")

So let's inspect the html:

```html
<!doctype html>
<html>
    <head>
        <meta charset="utf-8" />
        <title>Lights out!</title>
        <link rel="stylesheet" href="main.css" />
    </head>
    <body>
        <div class="alert alert-danger">Who turned out the lights?!?!</div>
        <summary>
        <div class="clearfix">
            <i data-hide="true"></i>
            <strong data-show="true">
            <small></small>
            </strong>
            <small></small>
        </div>
        </summary>
    </body>
</html>
```

Apparently there is nothing on it, so I'll also have a look at the css file. However, I'm going to use Chrome's inspect, as it lets me have a look at each element separately.

{% capture images %}
    /assets/posts_details/IceCTF/web2/1.png
    /assets/posts_details/IceCTF/web2/2.png
{% endcapture %}
{% include gallery images=images cols=2 %}
{% capture images %}
    /assets/posts_details/IceCTF/web2/3.png
    /assets/posts_details/IceCTF/web2/4.png
{% endcapture %}
{% include gallery images=images caption="Styles of .clearfix and tags: i, strong and small" cols=2 %}

So from there we can reverse the flag and get:

``
IceCTF{styles_turned_the_lights}
``

## Web 3. Friðfinnur {#web3}

**Challenge description**: Eve wants to make the hottest new website for job searching on the market! An avid PHP developer she decided to use the hottest new framework, Laravel! I don't think she knew how to deploy websites at this scale however....

In this third challenge we get a website which lists jobs available on the market. We can see different pages:

*Index.html*

![Img](/assets/posts_details/IceCTF/web3/initial.png "Img")

*Jobs.html*

![Img](/assets/posts_details/IceCTF/web3/jobs.png "Img")

And now inside each job we get some textareas to post data to the server.

*Job panel*

![Img](/assets/posts_details/IceCTF/web3/in_jobs.png "Img")

I spent much time thinking the vulnerability was there, when I accidentally came across an invalid path that threw an exception and, surprisingly, the flag as well:

*Debug exception*

![Img](/assets/posts_details/IceCTF/web3/exception.png "Img")

So the flag is ``IceCTF{you_found_debug}``.


---
<center><i>Diego Bernal Adelantado</i></center>
