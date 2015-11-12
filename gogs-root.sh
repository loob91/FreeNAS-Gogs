#!/bin/tcsh
echo "FreeNAS Gogs installation script."
echo "This has been tested on:"
echo "    9.3-RELEASE-p5 FreeBSD 9.3-RELEASE-p5 #1"
echo "    f8ed4e8: Fri Dec 19 20:25:35 PST 2014"
echo
echo "Press any key to begin"
set jnk = $<

if ( -f /usr/locat/etc/rc.d/gogs ) then
    update()
else
    install()
endif

update () {
    echo "Updating Gogs..."
    echo
    # Stop Gogs service
    service gogs stop 
    compile()
    service gogs start
    echo "Update Done!"
}

install {
    # 3) Enable SSH
    echo "Enabling SSH"
    /usr/bin/sed -i '.bak' 's/sshd_enable="NO"/sshd_enable="YES"/g' /etc/rc.conf
    # Generate root keys &  Enable root login (with SSH keys). 
    echo "Enabling root login without password"
    echo "PermitRootLogin without-password" >> /etc/ssh/sshd_config
    # Start SSH
    echo "Starting SSH Service"
    /usr/sbin/service sshd start
    # 4) Update packages and upgrade any.
    echo "Updating packages"
    /usr/sbin/pkg update -f
    echo "Upgrading packages"
    /usr/sbin/pkg upgrade -y
    echo "Installing memcached, redis & go"
    /usr/sbin/pkg install -y memcached redis go git bash
    echo "Enabling & starting memcached & redis"
    echo memcached_enable="YES" >> /etc/rc.conf
    echo redis_enable="YES" >> /etc/rc.conf
    /usr/sbin/service memcached start
    /usr/sbin/service redis start
    # 5) Create user first; installing git will install a git user to 1001
    echo "Creating git user"
    setenv GITHOME /usr/home/git/
    mkdir -p $GITHOME
    if (! -d /home ) then
	    /bin/ln -s /usr/home /home
    endif
    pw add user -n git -u 913 -d $GITHOME -s /bin/tcsh -c "Gogs -  Go Git Service"
    chown -R git:git $GITHOME
    su - git -c "/usr/bin/ssh-keygen -b 2048 -N '' -f ~/.ssh/id_rsa -t rsa -q &"
    # 6) Get & compile gogs
    compile ()
    su - git -c "ln -s /usr/home/git/.ssh/ /usr/home/git/gogs/"
    # 7) Start up scripts
    echo gogs_enable="YES" >> /etc/rc.conf
    service gogs start
}

compile() {
    echo "Fetching gogs from Github"
    su - git -c "setenv GOPATH /usr/home/git/go; go get -u github.com/gogits/gogs"
    echo "Getting gogs compile tags"
    su - git -c "setenv GOPATH /usr/home/git/go; cd /home/git/go/src/github.com/gogits/gogs; go get -u -tags 'sqlite redis memcache cert' github.com/gogits/gogs"
    echo "Compiling gogs"
    su - git -c "setenv GOPATH /usr/home/git/go; cd /home/git/go/src/github.com/gogits/gogs; go build -tags 'sqlite redis memcache cert'"
    echo "Copying gogs build to git home"
    su - git -c "cp -R /usr/home/git/go/src/github.com/gogits/gogs /home/git/"
    # Change ownership of everything in the git directory
    chown -R git:git /usr/home/git/
     echo "Copying startup script to rc.d, enabling & starting gogs"
    #/usr/bin/sed 's/\/home\/git/\/home\/git\/gogs/g' /home/git/go/src/github.com/gogits/gogs/scripts/init/freebsd/gogs
    cp /home/git/go/src/github.com/gogits/gogs/scripts/init/freebsd/gogs /usr/local/etc/rc.d/
    sed -i -e 's/\/home\/git/\/home\/git\/gogs/g' /usr/local/etc/rc.d/gogs
    chmod +x /usr/local/etc/rc.d/gogs
}

echo 
echo
echo

echo "Gogs should be running on port 3000 on the following addresses:"
ifconfig | grep inet
