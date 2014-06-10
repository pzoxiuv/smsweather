#!/bin/bash

getmail

for f in /home/alex/Programming/smsweather/mail/new/*
do
	lua /home/alex/Programming/smsweather/smsweather.lua $f
	rm $f
done
