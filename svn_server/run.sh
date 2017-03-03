#!/bin/bash
service sshd start & exec apachectl -D FOREGROUND
