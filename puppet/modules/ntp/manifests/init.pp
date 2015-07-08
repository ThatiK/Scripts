class ntp( $ntpServerList = $common::data::ntpServerList) {
	package { ntp: ensure => present }
		file { "/etc/ntp.conf":
			owner	 => root,
			group	 => root,
			mode	=> 644,
			backup => false,
			source	=> "puppet:///modules/ntp/ntp.conf",
			require => Package["ntp"],
		}
		service { "ntpd":
			enable => true ,
			ensure => running,
			subscribe => [Package[ntp], File["/etc/ntp.conf"],],
		}
}
