#!/bin/bash

getmail

if [ "$(ls -A /home/alex/Programming/smsweather/mail/new)" ]; then
	for f in /home/alex/Programming/smsweather/mail/new/*
	do
		lua /home/alex/Programming/smsweather/smsweather.lua $f &>>/home/alex/Programming/smsweather/luaerrs
		rm $f
	done
fi
