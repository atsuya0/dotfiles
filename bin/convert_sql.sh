#!/usr/bin/env bash

# sql to json
# $ cat example.sql | convert_sql.sh
#
# sql to terraform locals
# $ cat example.sql | convert_sql.sh --tf
#
# ```sql:example.sql
# CREATE TABLE IF NOT EXISTS `test`.`a` (
#   `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
#   `code` VARCHAR(45) NOT NULL COMMENT 'コード',
#   `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '生成日',
#   `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日',
#   PRIMARY KEY (`id`))
# ```

set -euCo pipefail

which jq > /dev/null || { echo 'Required jq command'; exit 1; }

function init() {
  in_table=0
  left_bracket_num=1
  right_bracket_num=1
  table='{"name": "", "db": "", "colmuns": []}'
}

init
tables='{"tables": []}'

while read -r line; do
  if [[ ${in_table} -eq 0 && ${line} =~ 'CREATE TABLE' ]]; then
    in_table=1
    table=$(echo ${table} | jq ".db |= \"$(echo ${line} | grep -o '`[^`]*`' | tr -d '`' | head -1)\"")
    table=$(echo ${table} | jq ".name |= \"$(echo ${line} | grep -o '`[^`]*`' | tr -d '`' | tail -1)\"")
  fi
  if [[ ${in_table} -eq 1 ]]; then
    left_bracket_num=$(expr ${left_bracket_num} + $(echo ${line} | grep -o '(' | tr -d '\n' | wc -m))
    right_bracket_num=$(expr ${right_bracket_num} + $(echo ${line} | grep -o ')' | tr -d '\n' | wc -m))
    if [[ ${right_bracket_num} -ge ${left_bracket_num} ]]; then
      tables=$(echo ${tables} | jq ".tables |= .+  [${table}]")
      init
    else
      column=$(echo ${line} | sed 's/^[[:space:]]*//' | cut -d' ' -f1 | grep -o '`[^`]*`' | tr -d '`') \
        && table=$(echo ${table} | jq ".colmuns |= .+  [\"${column}\"]")
    fi
  fi
done

[[ ${1-} == '--tf' ]] \
  && echo ${tables} | jq '.tables' | sed 's/"\([^"]*\)":/\1 =/' \
  || echo ${tables}
