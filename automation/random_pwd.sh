#!/bin/bash
#### Generate random password linux systems ####
random32=$(LC_CTYPE=C tr -dc 'a-zA-Z0-9&+@!' < /dev/urandom | fold -w 32 | head -n 1) && echo $random32
