class user-mngmt{
        group {'admin':
        ensure => present,
        gid => 1001,
        }

	group {'dev1':
	ensure => present,
	gid => 1002,
	}
	
	group {'dev2':
	ensure => present,
	gid => 1003,
	}
	
	user {"karthik":
	uid => '10001',
	groups => 'dev1',
	comment => 'karthik is a dev user',
	home => '/home/karthik',
	ensure => present,
	managehome => true,
	}
}
