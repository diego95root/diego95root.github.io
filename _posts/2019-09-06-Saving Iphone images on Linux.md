---
layout: post
title: "Saving Iphone images on Linux"
date: 2019-09-06
excerpt: ""
tags: [Iphone, Linux]
comments: true
feature:
---

# Saving Iphone images on Linux

This blog post explains how I managed to copy all of my Iphone images (more than 10.000) over to my Linux laptop running Debian. I spent so long that I decided to write it so that others can save a bit of their time. It can be divided in 3 parts:

1. A brief introduction
2. A failed attempt at using Shotwell to carry out my task (although the tips may be useful if you are trying to get it to work)
3. How I finally solved the problem with SMB and a Windows VM (useful as well to install Itunes and get a backup of the Iphone).

In case you just want to know how to copy your files I suggest you move on straight to the 3rd part.

## Introduction

I've always been an Apple fan and, as such, had a MacBook Air with an Iphone. However, recently the time to change my laptop came and, instead of getting a new Apple laptop, I decided to see new things and finally decided to buy a Dell XPS 13, specifically the 9380 model from 2019.

I had never had any problems with my pictures, I just connected my Iphone to my MacBook and it just copied everything. Now I had a problem, as Itunes wasn't supported on Linux.

## Failed attempt: Shotwell

I started reading posts about what applications to use and most people suggested Shotwell, which comes preinstalled on many Linux distros.

I must say that my experience with it wasn't too memorable, as I spent more time googling problems than actually copying my images and it would magically work only sometimes. Here are some tips I can give you in case you want to use this application:

* Connect your Iphone to the laptop unlocked, as apparently otherwise the application is unable to access it.
* Make sure the Iphone settings are correct so that it trusts the computer.
* Make sure the Iphone is not mounted on the file manager.
* Maybe a reboot of the Iphone magically solves something.

However, I couldn't find a solution to most of the problems I bumped into, neither installing packages nor following people's advice seemed to work.

*Error 1: The camera is locked by another application. How or why? I still don't know, I wasn't using the Iphone at all...*

![Img](/assets/posts_details/Iphone/Shotwell_error1.png)

*Error 2: Unable to fetch previews from the camera: Timeout reading to or writing from the port (-10). Another problem I didn't understand...*

![Img](/assets/posts_details/Iphone/Shotwell_error2.png)

Some other errors were along the lines of *Shotwell: Unable to fetch previews from the camera: Could not claim the USB device (-53)* or *Shtwell: Camera seems to be empty*

On top of that, I had to copy over 10.000 images. That meant that shotwell, which needs to first fetch all images before actually importing anything, took over 40 minutes to just finish loading everything.

*Fetching all images before actually doing any imports is slow*

![Img](/assets/posts_details/Iphone/Shotwell_importing.png)

Then, as if that weren't enough, once it started importing images it would suddenly stop (at like 5%) and I would have to repeat all the process again, hoping no problems would occurr (which they would).

At this point I decided to give up and research alternatives.

## The solution: SMB and a Windows VM

I created a Windows 10 VM using VMWare Workstation 15.1.0 and after configuring it installed Itunes. This proved to be useful as I could make a whole backup of my Iphone just in case.

### Accessing the images on the Windows VM

To copy the images what I did was simply open file manager! At first the Iphone seems to be empty, but I guess that's because it takes time to load all the internal storage (less than 3 minutes on my device). Then we just access the DCIM folder and we will get different folders named `1XXAPPLE`: these are our images split into different locations based on their date, being the largest `1XX` the most recent ones.

*Iphone initially appears to be empty*

![Img](/assets/posts_details/Iphone/FM_empty.png)

*Internal Storage turns up after a couple of minutes*

![Img](/assets/posts_details/Iphone/FM_internal.png)

*All folders with the images are inside DCIM*

![Img](/assets/posts_details/Iphone/FM_all.png)

I thought that at this stage I had succeeded in copying the images, but there was one last problem, though: their size. Each folder was about 3GB which meant that overall all the pictures would take up ~25GB. And I didn't want a VM to be taking that much space, so I had to think of something else.

*Problem: the size of the folders is too much*

![Img](/assets/posts_details/Iphone/FM_single.png)

### SMB to the rescue

I immediately thought: why not create a SMB share on my Linux host machine and then just upload the files directly there? That way I wouldn't have to save anything on the Windows VM, it would just be a bridge between the Iphone and my Linux machine.

The steps to set up SMB on Linux are the following:

1. Install Samba: `sudo apt-get install samba`
2. Create a user to authenticate with: `smbpasswd -a USERNAME`
3. Append the following to `/etc/samba/smb.conf` (chaning the username and the path to the directory you want to share):

    ```
    [Share]

    path = /home/diego/Share
    available = yes
    valid users = diego
    read only = no
    browsable = yes
    public = yes
    writable = yes
    ```

4. Restart SMB with: `sudo service smbd restart`.

Then, I created a test file under `/home/diego/Share` called `test.txt` and tried to access the share on my windows VM.

We should first make sure that the VM network mode is set to Bridged, as that will allow it to get an IP and be on the same network as the host.

*VM needs to be on Bridged mode*

![Img](/assets/posts_details/Iphone/Bridged.png)

Then, to access the shares on the Windows file manager we double-click on `This PC` and select `Add a network location`. We should first get our host IP address with `ifconfig`, on my case it was `192.168.1.24` and then input the location as: `\\192.168.1.24\Share` (Share is the name of the directory I'm sharing, yours could be different). If everything you did was right you should then see pop up a folder on the file manager with the share name and the test file:

*Accessing the directory on the Windows VM*

![Img](/assets/posts_details/Iphone/SMB.png)

Now it was easy, I just started copying the images straight into that folder with no memory problems! Besides, the transfer on my case was really fast, it copied all my images within ~45 minutes.

Note that you may have to adjust some settings on your Iphone so that the images are transfered in their original format, otherwise you may get errors during the transfer saying `A device attached to the system is not functioning`. To do so, just go to `Iphone Settings > Photos > Transfer to Mac or PC` and select `Keep originals`. That fixed my issue.

I hope you found this post useful, until next time!

---

Diego Bernal Adelantado
