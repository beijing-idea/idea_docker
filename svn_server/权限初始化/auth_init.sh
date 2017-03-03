#!/bin/bash
htpasswd -b /var/www/svn/passwd renyong idea_123
cat auth_add >> /var/www/svn/authz
