𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
-------------------------------------


# Overview

[IrfanView](https://www.irfanview.com/) is an image viewer, editor, organiser and converter program for Microsoft Windows. It can also play video and audio files, and has some image creation and painting capabilities. IrfanView is free for non-commercial use; commercial use requires paid registration. [Wikipedia](https://en.wikipedia.org/wiki/IrfanView)

# Download Tool

The people at _irfanview.com_ made is complicated for someone to download the irfanview program using a script. The website requires that the __GET__ request contains an expirable token and that the referer comes from _irfanview.com_

## PowerShell

I initially wrote a Powershell script that downloads the IRFanView program to help this [dude on Reddit](https://www.reddit.com/r/PowerShell/comments/u3ge6a/download_files_from_fosshub_website).
You can get the script [here](https://github.com/arsscriptum/PowerShell.Sandbox/blob/main/Fosshub/Get-FosshubFile.ps1).

## C++ Program: irfanget

This project was basically an academic exercise, just to add this tool in my tool box.


## Dependencies

#### OpenSSL 1.1 / LibCrypto 3.0

The [Win32/Win64 OpenSSL Installation Project](https://slproweb.com/products/Win32OpenSSL.html) is dedicated to providing a simple installation of OpenSSL for Microsoft Windows. I

[Download Link](https://slproweb.com/download/Win64OpenSSL-1_1_1q.msi)

***Set Environment Variable*** LIBOPENSSL to installation root. (may have changed)

#### httplib : A C++11 single-file header-only cross platform HTTP/HTTPS library

From github.com/yhirose/cpp-httplib

***SSL support*** is available with CPPHTTPLIB_OPENSSL_SUPPORT. libssl and libcrypto should be linked. cpp-httplib currently supports only version 1.1.1 and 3.0.

#### jsmn : a minimalistic JSON parser in C

From [github.com/zserge/jsmn](https://github.com/zserge/jsmn)

##  x.fosshub

	Usage: getfh.exe [-h][-v][-w][-n][-p]<filepath>
	   -v          Verbose mode
	   -h          Help
	   -p          Path
	   -w          WhatIf: do not actually kill process.   Suggested use with -s.
	   -n          No banner


