#
# sshkeys puppet module
# https://github.com/artem-sidorenko/puppet-sshkeys
#
# Copyright (C) 2016 Frank Wall github@moov.de
# Copyright (C) 2014-2016 Artem Sidorenko artem@2realities.com
#
# See the COPYRIGHT file at the top-level directory of this distribution.
#
define sshkeys::key (
  $key_name = undef,
  $key      = undef,
  $options  = undef,
  $type     = undef,
  $user     = undef,
  $host     = $sshkeys::host,
) {
  if ( !$user or !$key_name ) {
    fail( 'user and key_name should be defined')
  }

  if ( !$key and !$type ) {
    # hiera lookup in the key list if both key and type are not defined
    $keys_hash = hiera_hash('sshkeys::keys',undef)
    if ( !$keys_hash or !$keys_hash[$key_name] or !$keys_hash[$key_name]['key'] or !$keys_hash[$key_name]['type'] ) {
      fail ( "cannot find the key ${key_name} for ${user}@${host} via hiera in the sshkeys::keys namespace" )
    }
    $fin_key = $keys_hash[$key_name]['key']
    $fin_type = $keys_hash[$key_name]['type']
    $fin_options = $keys_hash[$key_name]['options']
  } elsif ( $key and $type ) {
    $fin_key = $key
    $fin_type = $type
    $fin_options = $options
  } else {
    fail ('either key and type both should be defined or both should be absent')
  }

  ssh_authorized_key { "${key_name}_at_${user}@${host}":
    ensure  => present,
    user    => $user,
    key     => $fin_key,
    options => $fin_options,
    type    => $fin_type,
  }
}
