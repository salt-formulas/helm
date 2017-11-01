{%- from slspath + "/map.jinja" import config, constants with context %}

include:
  - .client_installed

{%- if "repos" in config %}
repos_managed:
  helm_repos.managed:
    - present: 
        {{ config.repos | yaml(false) | indent(8) }}
    - exclusive: true
    - helm_home: {{ config.helm_home }}
    - require:
      - sls: {{ slspath }}.client_installed
{%- endif %}

repos_updated:
  helm_repos.updated:
    - helm_home: {{ config.helm_home }}
    - require:
      - sls: {{ slspath }}.client_installed