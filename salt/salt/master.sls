# Copyright Security Onion Solutions LLC and/or licensed to Security Onion Solutions LLC under one
# or more contributor license agreements. Licensed under the Elastic License 2.0 as shown at
# https://securityonion.net/license; you may not use this file except in compliance with the
# Elastic License 2.0.

{% from 'allowed_states.map.jinja' import allowed_states %}
{% if sls in allowed_states %}

include:
  - salt.minion
{%   if salt['pillar.get']('hypervisor:nodes', {} ) %}
  - salt.cloud
{% endif %}

hold_salt_master_package:
  module.run:
    - pkg.hold:
      - name: salt-master

# prior to 2.4.30 this engine ran on the manager with salt-minion
# this has changed to running with the salt-master in 2.4.30
remove_engines_config:
  file.absent:
    - name: /etc/salt/minion.d/engines.conf
    - source: salt://salt/files/engines.conf
    - watch_in:
      - service: salt_minion_service

checkmine_engine:
  file.managed:
    - name: /etc/salt/engines/checkmine.py
    - source: salt://salt/engines/master/checkmine.py
    - makedirs: True

pillarWatch_engine:
  file.managed:
    - name: /etc/salt/engines/pillarWatch.py
    - source: salt://salt/engines/master/pillarWatch.py

engines_config:
  file.managed:
    - name: /etc/salt/master.d/engines.conf
    - source: salt://salt/files/engines.conf

salt_master_service:
  service.running:
    - name: salt-master
    - enable: True
    - watch:
      - file: checkmine_engine
      - file: pillarWatch_engine
      - file: engines_config
    - order: last

# we need to managed adding the following to salt-master config if there are hypervisors
#reactor:
  #- salt/cloud/*/creating':
  #- salt/cloud/*/requesting
#  - 'salt/cloud/*/deploying':
#    - /opt/so/saltstack/default/salt/reactor/createEmptyPillar.sls
##  - 'salt/cloud/*/created':
##    - /opt/so/saltstack/default/salt/reactor/setSalt.sls
##    - /opt/so/saltstack/default/salt/reactor/setHostname.sls
##    - /opt/so/saltstack/default/salt/reactor/sominion.sls
#  - 'setup/so-minion':
#    - /opt/so/saltstack/default/salt/reactor/sominion_setup.sls
#    - /opt/so/saltstack/default/salt/reactor/virtUpdate.sls
#  - 'salt/cloud/*/destroyed':
#    - /opt/so/saltstack/default/salt/reactor/virtReleaseHardware.sls
#    - /opt/so/saltstack/default/salt/reactor/deleteKey.sls


{% else %}

{{sls}}_state_not_allowed:
  test.fail_without_changes:
    - name: {{sls}}_state_not_allowed

{% endif %}
