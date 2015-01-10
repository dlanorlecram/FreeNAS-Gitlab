Gitlab on FreeNAS
==============

Scripts to get GitLab working in FreeNAS. If you prefer to do each step by hand [a tutorial is posted on the FreeNAS forums](https://forums.freenas.org/index.php?threads/how-to-gitlab-on-freenas-9-3.26347/)

Instructions for script use:

1\. From FreeNAS GUI create a new jail.

2\. From FreeNAS shell change directories to path that contains the new jail.

	freenas# jls
		JID  IP Address      Hostname                      Path
		42  -               gitlab_1                      /mnt/keg/jails/gitlab_1
		43  -               gitlab_2                      /mnt/keg/jails/gitlab_2
		44  -               gitlab_3                      /mnt/keg/jails/gitlab_3
		45  -               gitlab_4                      /mnt/keg/jails/gitlab_4
		46  -               gitlab_5                      /mnt/keg/jails/gitlab_5
		47  -               gitlab_6                      /mnt/keg/jails/gitlab_6
	freenas # cd /mnt/keg/jails/gitlab_6

If the jail is the last one started, this one line will parse out the path and change to it.
    
	cd `jls | awk '{ print $4 }' | tail -n 1`
	
3\. Clone the FreeNAS-Git scripts & change directories to the one created by the clone.

	git clone https://github.com/jedediahfrey/FreeNAS-Gitlab.git
	cd FreeNAS-Gitlab/
	
4\. Edit gitlab.sql and gitlab_git.sh with the desired mysql git user password. (Placeholder: $password)

	freenas# grep '$password' *
		gitlab.sql:CREATE USER 'git'@'localhost' IDENTIFIED BY '$password';
		gitlab_git.sh:sed -i '.bak' "s/secure password/\$password/g" config/database.yml

Easiest way to do this is with from the command line with sed, replacing '````newpass````' with your desired password. You can also edit it in vi, nano or any other installed editors.

    sed -i '.bak' 's/$password/newpass/g' gitlab.sql
	sed -i '.bak' 's/$password/newpass/g' gitlab_git.sh
	
5\. Execute a shell within the jail. Using the same JID from above:

    jexec 47 tcsh
	
Or if the jail was the last one started:

    jexec `jls | awk '{ print $1 }' | tail -n 1` tcsh
	
6\. Change directories to  /FreeNAS-Gitlab (created in step 2). [The .bak files were created in step 4 they should still contain $password as the password.]

    freenas# jexec 47 tcsh
    root@gitlab_6:/ # cd FreeNAS-Gitlab/
    root@gitlab_6:/FreeNAS-Gitlab # pwd
    /FreeNAS-Gitlab
    root@gitlab_6:/FreeNAS-Gitlab # ls
    .git                    README.md               gitlab.sql.bak          gitlab_git.sh.bak
    LICENSE                 gitlab.sql              gitlab_git.sh           gitlab_root.sh

7\. Enable execution bit and run gitlab_root.sh

	chmod +x *.sh
	./gitlab_root.sh
	
8\. The script will prompt you 2 times. Once for securing mysql and once entering your password again

If everything goes correctly the last lines before the prompt returns should be: 

    The GitLab Unicorn web server with pid 76597 is running.
    The GitLab Sidekiq job dispatcher with pid 76656 is running.
    GitLab and all its components are up and running.
    Performing sanity check on nginx configuration:
    nginx: the configuration file /usr/local/etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /usr/local/etc/nginx/nginx.conf test is successful
    Starting nginx.

