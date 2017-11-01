{%- from slspath + "/map.jinja" import config, constants with context %}

include:
  - .kubectl_installed

{%- set binary_source = "https://storage.googleapis.com/kubernetes-helm/helm-v" + 
                        config.version + "-" + config.flavor + ".tar.gz" %}

{%- set binary_source = config.get(
      "download_url", 
      "https://storage.googleapis.com/kubernetes-helm" +
      "/helm-v" + config.version + "-" + config.flavor + ".tar.gz"
    ) %}

{{ constants.helm.tmp }}:
  file.directory:
    - user: root
    - group: root
  archive.extracted:
    - source: {{ binary_source }}
    - source_hash: {{ config.download_hash }}
    - archive_format: tar
    {%- if grains['saltversioninfo'] < [2016, 11] %}
    - tar_options: v
    {%- else %}
    - options: v
    {%- endif %}
    - onlyif:
        - test "{{ config.version }}" -eq "canary" || test ! -e {{ constants.helm.tmp }}/{{ config.flavor }}/helm
    - require:
      - file: {{ constants.helm.tmp }}

{{ config.bin }}:
  file.copy:
    - source: {{ constants.helm.tmp }}/{{ config.flavor }}/helm
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - archive: {{ constants.helm.tmp }}
    - unless: cmp -s {{ config.bin }} {{ constants.helm.tmp }}/{{ config.flavor }}/helm

prepare_client:
  cmd.run:
    - name: {{ constants.helm.cmd }} init --client-only --home {{ config.helm_home }}
    - unless: test -d {{ config.helm_home }}
    - require:
      - file: {{ config.bin }}
