{%- macro view_twin_strategy(twin_strategy) -%}
  {%- if twin_strategy != 'allow' -%}
    {%- set table_relation = api.Relation.create(
        identifier=generate_alias_name_impl(model.name, config.get('file', validator=validation.any[basestring]), model),
        schema=generate_schema_name_impl(target.root_path, config.get('root_path', validator=validation.any[basestring]), model),
        database=generate_database_name_impl(target.datalake, config.get('datalake', validator=validation.any[basestring]), model),
        type='table') -%}
    {{ adapter.drop_relation(table_relation) }}
  {%- endif -%}
{%- endmacro -%}

{%- macro table_twin_strategy(twin_strategy, table_relation) -%}
  {%- if twin_strategy in ['prevent', 'clone'] -%}
    {%- set view_relation = api.Relation.create(
        identifier=generate_alias_name_impl(model.name, config.get('alias', validator=validation.any[basestring]), model),
        schema=generate_schema_name_impl(target.schema, config.get('schema', validator=validation.any[basestring]), model),
        database=generate_database_name_impl(target.database, config.get('database', validator=validation.any[basestring]), model),
        type='view') -%}
    {%- if twin_strategy == 'prevent' -%}
      {{ adapter.drop_relation(view_relation) }}
    {%- elif twin_strategy == 'clone' -%}
      {%- set sql_view -%}
        select *
        from {{ render_with_format_clause(table_relation) }}
      {%- endset -%}
      {% call statement('clone_view') -%}
        {{ create_view_as(view_relation, sql_view) }}
      {%- endcall %}
    {%- endif -%}
  {%- endif -%}
{%- endmacro -%}
