#!/usr/bin/env bash

# sql to terraform locals
# $ cat example.sql | convert_sql.sh --tf -i ignore_columns.json
#
# ```sql:example.sql
# CREATE TABLE IF NOT EXISTS `test`.`a` (
#   `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
#   `code` VARCHAR(45) NOT NULL COMMENT 'コード',
#   `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日',
#   `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日',
#   PRIMARY KEY (`id`))
#
# CREATE TABLE IF NOT EXISTS `test`.`b` (
#   `id` BIGINT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID' ,
#   `number` BIGINT(20) UNSIGNED NOT NULL COMMENT '番号',
#   `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日',
#   `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日',
#   PRIMARY KEY (`id`),
#   INDEX `number_INDEX` (`number` ASC))
# ENGINE = InnoDB;
# ```
#
# ```json:ignore_columns.json
# {
#   "db1": {
#     "table1": [
#       "col1"
#     ]
#   },
#   "db2": {
#     "table1": [
#       "col1",
#       "col2"
#     ]
#   }
# }
# ```

set -euCo pipefail

which jq > /dev/null || { echo 'Required jq command'; exit 1; }

function init_table() {
  in_table=0
  left_bracket_num=1
  right_bracket_num=1
  table='{"schema": "", "table": "", "colmuns": []}'
}

while (( $# > 0 )); do
  case $1 in
    '-i'|'--ignore-cols-path' )
      [[ -z $2 || $2 =~ ^-+ ]] && exit 1
      [[ -f $2 ]] || exit 1
      ignore_columns=$(cat $2)
      shift 2
    ;;
    '-t'|'--tf' )
      terraform=1
      shift 1
    ;;
  esac
done

tables='[]'
init_table

while read -r line; do
  if [[ ${in_table} -eq 0 && ${line} =~ 'CREATE TABLE' ]]; then
    in_table=1
    schema_name=$(echo ${line} | grep -o '`[^`]*`' | tr -d '`' | head -1)
    table=$(echo ${table} | jq ".schema |= \"${schema_name}\"")
    table_name=$(echo ${line} | grep -o '`[^`]*`' | tr -d '`' | tail -1)
    table=$(echo ${table} | jq ".table |= \"${table_name}\"")
  fi
  [[ ${in_table} -eq 0 ]] && continue
  left_bracket_num=$(expr ${left_bracket_num} + $(echo ${line} | grep -o '(' | tr -d '\n' | wc -m))
  right_bracket_num=$(expr ${right_bracket_num} + $(echo ${line} | grep -o ')' | tr -d '\n' | wc -m))
  if [[ ${right_bracket_num} -ge ${left_bracket_num} ]]; then
    tables=$(echo ${tables} | jq ". |= .+  [${table}]")
    init_table
  else
    column=$(echo ${line} | sed 's/^[[:space:]]*//' | cut -d' ' -f1 | grep -o '`[^`]*`' | tr -d '`' || echo '')
    [[ -z ${column} ]] && continue
    [[ -n ${ignore_columns-} && $(echo ${ignore_columns} | jq ".${schema_name}.${table_name}") != 'null' \
      && -n $(echo ${ignore_columns} | jq ".${schema_name}.${table_name}[] | select(. == \"${column}\")") ]] && continue
    table=$(echo ${table} | jq ".colmuns |= .+  [\"${column}\"]")
  fi
done

[[ ${terraform-} -eq 1 ]] \
  && echo ${tables} | jq | sed 's/"\([^"]*\)":/\1 =/' \
  || echo ${tables}
