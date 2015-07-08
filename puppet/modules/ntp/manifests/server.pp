class ntp::server ( $ntp_sources = '', $ntp_peers = $common::data::ntpServerList ) inherits ntp {

  File ['/etc/ntp.conf'] {
    content => template("ntp/server-ntp.conf.erb"),
  }
} # class ntp::server
