# Copyright Security Onion Solutions LLC and/or licensed to Security Onion Solutions LLC under one
# or more contributor license agreements. Licensed under the Elastic License 2.0 as shown at 
# https://securityonion.net/license; you may not use this file except in compliance with the
# Elastic License 2.0.

{% from 'allowed_states.map.jinja' import allowed_states %}
{% if sls.split('.')[0] in allowed_states %}
{%   from 'vars/globals.map.jinja' import GLOBALS %}
{%   set kafka_external_certs = salt['pillar.get']('kafka:config:external') %}

kafka_group:
  group.present:
    - name: kafka
    - gid: 960

kafka_user:
  user.present:
    - name: kafka
    - uid: 960
    - gid: 960
    - home: /opt/so/conf/kafka
    - createhome: False

kafka_home_dir:
  file.absent:
    - name: /home/kafka

kafka_sbin_tools:
  file.recurse:
    - name: /usr/sbin
    - source: salt://kafka/tools/sbin
    - user: 960
    - group: 960
    - file_mode: 755

kafka_sbin_jinja_tools:
  file.recurse:
    - name: /usr/sbin
    - source: salt://kafka/tools/sbin_jinja
    - user: 960
    - group: 960
    - file_mode: 755
    - template: jinja
    - defaults:
        GLOBALS: {{ GLOBALS }}

kafka_log_dir:
  file.directory:
    - name: /opt/so/log/kafka
    - user: 960
    - group: 960
    - makedirs: True

kafka_data_dir:
  file.directory:
    - name: /nsm/kafka/data
    - user: 960
    - group: 960
    - makedirs: True

{%   for sc in ['server', 'client'] %}
kafka_kraft_{{sc}}_properties:
  file.managed:
    - source: salt://kafka/etc/{{sc}}.properties.jinja
    - name: /opt/so/conf/kafka/{{sc}}.properties
    - template: jinja
    - user: 960
    - group: 960
    - makedirs: True
    - show_changes: False
{%   endfor %}

{% if GLOBALS.is_manager and kafka_external_certs %}
{%   for external, values in kafka_external_certs.items() %}
custom_cert_dir_{{ external }}:
  file.directory:
    - name: /opt/so/conf/kafka/{{ external }}
    - user: 939
    - group: 939
    - makedirs: True

custom_cert_{{ external }}_properties:
  file.managed:
    - source: salt://kafka/etc/external.properties.jinja
    - name: /opt/so/conf/kafka/{{ external }}/{{ values.name }}.properties
    - template: jinja
    - mode: 600
    - user: 939
    - group: 939
    - makedirs: True
    - show_changes: False
    - defaults:
        external: {{ external }}
        values: {{ values }}
{%   endfor %}
{% endif %}

reset_quorum_on_changes:
  cmd.run:
    - name: rm -f /nsm/kafka/data/__cluster_metadata-0/quorum-state
    - onchanges:
      - file: /opt/so/conf/kafka/server.properties

{% else %}

{{sls}}_state_not_allowed:
  test.fail_without_changes:
    - name: {{sls}}_state_not_allowed

{% endif %}
