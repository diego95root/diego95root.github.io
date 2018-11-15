import numpy as np
import os, sys
import subprocess

#results = []
#testdir = os.getcwd()
#for f in os.listdir(testdir):
#    if f.endswith('.png') and f not in ["0.png", "1.png", "25.png", "26.png"]:
#        results.append(f)

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
	#os.system("zbarimg out.jpg")
	#result = subprocess.Popen("zbarimg ouit.jpg", stdout=subprocess.PIPE, stderr=subprocess.PIPE)
   
