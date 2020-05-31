---
layout: post
title: "Intigriti Easter XSS challenge solution"
date: 2020-04-20
excerpt: "Come and see my writeup on one of the mindblowing XSS that Intigriti creates for the fun (and frustration) of hackers..."
tags: [Bug Bounty, XSS]
categories: [Bug Bounty]
comments: true
feature: /assets/posts_details/IntigritiEaster/sourcecode.png
---

# Intigriti Easter XSS challenge solution

This blog post will go over how I managed to solve the Intigriti Easter challenge, which took definitely way too long. Even though I spent more than 2 days on it, the alert box popping up was very much worth the effort, so gratifying! But enough, let's dive in!

## Challenge description

*Main page of the challenge*

![Img](/assets/posts_details/IntigritiEaster/description.png)

First of all, as always, I took a look at the challenge requirements:

- Needs to be on that page and on that domain (so no local files with iframes as in previous challenges).
- Doesn't have user interaction.
- Needs to bypass CSP (without any doubt the trickiest one).

*JS source code*

```js
var hash = document.location.hash.substr(1);
if(hash){
  displayReason(hash);
}
document.getElementById("reasons").onchange = function(e){
  if(e.target.value != "")
    displayReason(e.target.value);
}
function reasonLoaded () {
    var reason = document.getElementById("reason");
    reason.innerHTML = unescape(this.responseText);
}
function displayReason(reason){
  window.location.hash = reason;
  var xhr = new XMLHttpRequest();
  xhr.addEventListener("load", reasonLoaded);
  xhr.open("GET",`./reasons/${reason}.txt`);
  xhr.send();
}
```

## 1st part: code injection

Checking the source code it's evident from `document.location.hash.substr(1)` and `window.location.hash` we need to use the hash part of the URL to deliver our payload. We can see inside the `displayReason` function there is a GET request to `./reasons/${reason}.txt`, which meant that we could control where we sent the XHR. However, using for instance `https://challenge.intigriti.io/#aaaa<>` as URL resulted in the following response:

*Filtering of HTML characters in `https://challenge.intigriti.io/#aaaa<>`*

![Img](/assets/posts_details/IntigritiEaster/filtering.png)

It looked like the application was filtering the `<>` characters to prevent the injection. I also tried url encoding them and other characters and nothing, an interesting thing though was the `/`, when encoded into `%2f` resulted in the apache default error page which was then rendered! This was a clue that we somehow needed to inject something in a page and then use the `reason.innerHTML = unescape(this.responseText);` to execute the payload.

*Filtering of HTML characters in `https://challenge.intigriti.io/#..%2faaaa<>`*

![Img](/assets/posts_details/IntigritiEaster/404.png)

## 2nd part: injection point

At this point I had a pretty clear idea of what I had to do: get a page where I could reflect double url-encoded HTML characters to then inject into the main page:

1. Send `%253c` as payload
2. Injected page reflects it as `%3c`
3. Main page decodes that as `<` and renders the payload.

I spent a great deal of time looking for it when I realised I had always had it in front of me: I was in an Apache server so `server-status` could potentially give something interesting, as I knew that some Apache pages had content injections into their HTML pages (for instance, this Hackerone report shows an example: https://hackerone.com/reports/134388).

However, there were some tweaks I had to make to the URL. First of all, we need to go back to the root directory, as in the XHR we make the call to `/reasons/${reason}.txt`. Secondly, we need to get rid of the extension, which can easily be done by appending `?`.

*Reflection: `https://challenge.intigriti.io/#../server-status?%253Ch1%253Ea%253C%252Fh1%253E`*

![Img](/assets/posts_details/IntigritiEaster/reflection.png)

Cool! Now I just change that into a javascript payload and done! I quickly double encoded `<img src=x onerror=alert(1)>` and clicked refresh but to my frustration I had forgotten something: CSP.

*Blocking of inline javascript due to CSP*

![Img](/assets/posts_details/IntigritiEaster/csp.png)

## 3rd part: CSP bypass

I checked the header and saw that the page had the CSP policy set to `default-src 'self'`, which meant that the page was allowed to only load resources from https://challenge.intigriti.io.

*CSP policy in place*

![Img](/assets/posts_details/IntigritiEaster/csp-policy.png)

From here on I was really frustrated, as I didn't have much experience with CSP bypasses, so I decided to turn to the hints and deduced that we needed to use an iframe. Seemed like a good start. After trying combinations of possible payloads I looked at the documentation of the iframe and found the `srcdoc` attribute.

According to the documentation, the `srcdoc` attribute overrides the `src` attribute and specifies the HTML content to show inside the iframe. But most importantly, the iframe with the `srcdoc` attribute is not cross domain, meaning that the content will be treated as coming from the same domain as the parent-page. Just what we need!

At this point I knew what had to be done, just not how to do it. So I kept digging and after many hours it dawned on me: I had had it in front of me all this time! When visiting `https://challenge.intigriti.io/aa` for example we would get `404 - 'File "aa" was not found in this folder.'` as a response. If we look at it closely, that response is valid javascript we can inject into: a subtraction of an integer minus a string! Hence, I could inject something via the filename to have `404 - 'File "'-alert(1)-'" was not found in this folder.'` as a response because none of those characters were actually filtered!

Hence, I tried to use `<script src=https://challenge.intigriti.io/'-alert(document.domain)-'></script>` as the `srcdoc` value and so the payload (before double encoding it) was: `<iframe srcdoc="<script src=https://challenge.intigriti.io/'-alert(document.domain)-'></script>"></iframe>`; which bypassed the CSP because the script was loaded from the same domain. Genius challenge!

I put everything back together and got the following URL:

```
https://challenge.intigriti.io/#../server-status?%253Ciframe%2520srcdoc%253D%2522%253Cscript%2520src%253Dhttps%253A%252F%252Fchallenge.intigriti.io%252F%2527-alert%2528document.domain%2529-%2527%253E%253C%252Fscript%253E%2522%253E%253C%252Fiframe%253E%2520
```

Then I finally submitted it and to my pleasure got the precious alert box!

*XSS triggered!*

![Img](/assets/posts_details/IntigritiEaster/xss.png)

# Afterthoughts

It was a challenging problem but getting the alert box was well worth the many hours I put into, I learnt a ton of things on my way to it. In fact, even if they were not usefult in the end, I learnt a lot from these two resources, which talk about how CSP can be bypassed via iframes, they are worth a read:

- [How to trick CSP in letting you run whatever you want](https://lab.wallarm.com/how-to-trick-csp-in-letting-you-run-whatever-you-want-73cb5ff428aa/)
- [A Novel CSP Bypass Using data: URI](https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2019/april/a-novel-csp-bypass-using-data-uri/)

Cheers to Intigriti for putting up such amazing challenges. Without a doubt I'm going to save the content injection trick for my bug hunting!

See you next time!

---

Diego Bernal Adelantado
