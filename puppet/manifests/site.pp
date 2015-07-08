node default {
	  include common,user-mngmt
	    class {'ntp':
	      ntpServerList => ['secondarynn.cloudwick.net']
	   }
#Rather than including user-mnmt as modules you can write that here itselt before node default and use same include statement

}
